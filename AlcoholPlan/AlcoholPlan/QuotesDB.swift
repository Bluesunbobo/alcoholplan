import Foundation

struct Quote {
    let quote: String
    let translation: String
    let type: QuoteType
}

enum QuoteType {
    case philosophic
    case scientific
    case warning
    case neutral
}

struct StateRange {
    let minBAC: Double
    let maxBAC: Double
    let stateNameZh: String
    let stateNameEn: String
    let avatarImage: String
    let quotes: [Quote]
    let isCritical: Bool
}

class QuotesDB {
    static let shared = QuotesDB()
    
    let neutralQuotes: [Quote] = [
        Quote(quote: "葡萄酒是被水聚拢的阳光。", translation: "Wine is sunlight, held together by water. (Galileo)", type: .neutral),
        Quote(quote: "节制是美德，但不如勇气更有趣。", translation: "Moderation is a virtue, but less fun than courage.", type: .neutral),
        Quote(quote: "最好的对话发生在第三杯之后，第五杯之前。", translation: "The best conversations happen after the third glass and before the fifth.", type: .neutral),
        Quote(quote: "生命太短暂，不该用来假装清醒。", translation: "Life is too short to pretend to be sober.", type: .neutral),
        Quote(quote: "他们开始喝酒，是为了活得更好。后来他们发现，那只是另一种活法。", translation: "They started drinking to live better. Then they found it was just another way of living.", type: .neutral),
        Quote(quote: "在某些夜晚，你需要的不是答案，而是陪伴。", translation: "On some nights, you don't need answers, just company.", type: .neutral),
        Quote(quote: "不是每一杯都值得喝。但每一杯都值得记住。", translation: "Not every glass is worth drinking, but every glass is worth remembering.", type: .neutral),
        Quote(quote: "喝了再写，醒了再改。人生也该如此。", translation: "Write drunk, edit sober. Maybe life is the same. (Hemingway)", type: .neutral),
        Quote(quote: "喝酒不能解决问题。但它能让你暂时不在乎那个问题。这有时候也是一种解法。", translation: "Drinking doesn't solve problems. But it makes you stop caring for a while.", type: .neutral)
    ]
    
    private func getPersonaQuotes(for persona: Persona) -> PersonaQuotes {
        switch persona {
        case .martin: return QuotesDBData.martin
        case .nikolaj: return QuotesDBData.nikolaj
        case .tommy: return QuotesDBData.tommy
        case .peter: return QuotesDBData.peter
        case .clara: return QuotesDBData.clara
        case .elena: return QuotesDBData.elena
        case .maya: return QuotesDBData.maya
        case .sofia: return QuotesDBData.sofia
        }
    }
    
    func getStateRange(for bac: Double, in country: CountryLaw, isSoberingDown: Bool, persona: Persona) -> StateRange {
        let pQuotes = getPersonaQuotes(for: persona)
        
        if isSoberingDown {
            return StateRange(minBAC: 0, maxBAC: 1.0, stateNameZh: "清醒倒计时", stateNameEn: "Sobering Up", avatarImage: "personality_sobering", quotes: [
                Quote(quote: "酒精会离开。它带走的东西，有时不会回来。", translation: "Alcohol leaves. What it takes away sometimes doesn't come back.", type: .philosophic),
                Quote(quote: "你的肝脏正在以约 0.015% 每小时的速度处理它。", translation: "Your liver is processing it at about 0.015% per hour.", type: .scientific),
                Quote(quote: "等待，也是一种选择。", translation: "Waiting is also a choice.", type: .philosophic)
            ], isCritical: false)
        }
        
        if bac <= 0.001 {
            return StateRange(minBAC: 0.0, maxBAC: 0.001, stateNameZh: "清醒如水", stateNameEn: "The Sober", avatarImage: "personality_sober", quotes: [
                Quote(quote: "我们生来就缺少一点什么。", translation: "We are born missing something. (Skårderud)", type: .philosophic),
                Quote(quote: "今晚，你想成为哪个版本的自己？", translation: "Which version of yourself do you want to be tonight?", type: .philosophic),
                Quote(quote: "还没开始。或者，已经结束了。", translation: "It hasn't started yet. Or, it's already over.", type: .philosophic)
            ], isCritical: false)
        }
        
        // Zero Tolerance is still important if driving, but we just merge it elegantly into the warning layer if possible.
        // Actually, let's keep it but make it an isolated check without dropping quotes entirely.
        if country.isZeroTolerance && bac >= 0.001 && bac < 0.020 {
            return StateRange(minBAC: 0.001, maxBAC: 1.0, stateNameZh: "零容忍区域", stateNameEn: "Zero Tolerance Zone", avatarImage: "personality_sober", quotes: [
                Quote(quote: "你选择的国家/地区对任何可检测酒精实行零容忍。在这里，任何饮酒后驾车均违法。", translation: "Your region imposes zero tolerance on alcohol. Any driving after drinking is illegal.", type: .warning)
            ], isCritical: true)
        }
        
        if bac >= 0.100 {
            return StateRange(minBAC: 0.100, maxBAC: 1.0, stateNameZh: "过度醉酒", stateNameEn: "Highly Intoxicated", avatarImage: "personality_druk", quotes: pQuotes.p100_up, isCritical: true)
        }
        
        if bac >= 0.080 {
            return StateRange(minBAC: 0.080, maxBAC: 0.099, stateNameZh: "边界之上", stateNameEn: "Over the Line", avatarImage: "personality_drifter", quotes: pQuotes.p080_100, isCritical: true)
        }
        
        if bac >= 0.070 {
            return StateRange(minBAC: 0.070, maxBAC: 0.079, stateNameZh: "沉醉时分", stateNameEn: "The Druk", avatarImage: "personality_drifter", quotes: pQuotes.p070_080, isCritical: true)
        }
        
        if bac >= 0.055 {
            return StateRange(minBAC: 0.055, maxBAC: 0.069, stateNameZh: "微醺在场区", stateNameEn: "Noticeably There", avatarImage: "personality_sensual", quotes: pQuotes.p020_060, isCritical: false)
        }
        
        if bac >= 0.045 {
            return StateRange(minBAC: 0.045, maxBAC: 0.0549, stateNameZh: "哲学黄金点", stateNameEn: "The Philosophic Gold Point", avatarImage: "personality_philosopher", quotes: pQuotes.p050, isCritical: false)
        }
        
        if bac >= 0.035 {
            return StateRange(minBAC: 0.035, maxBAC: 0.0449, stateNameZh: "渐入佳境", stateNameEn: "Settling In", avatarImage: "personality_sensual", quotes: pQuotes.p020_060, isCritical: false)
        }
        
        if bac >= 0.020 {
            return StateRange(minBAC: 0.020, maxBAC: 0.0349, stateNameZh: "微醺助兴点", stateNameEn: "The Sensual Sweet Spot", avatarImage: "personality_sensual", quotes: pQuotes.p025, isCritical: false)
        }
        
        return StateRange(minBAC: 0.001, maxBAC: 0.019, stateNameZh: "刚刚开始", stateNameEn: "Just Starting", avatarImage: "personality_sensual", quotes: [
            Quote(quote: "第一杯之后，世界的边缘变得柔软了一点点。", translation: "After the first glass, the edges of the world got a little bit softer.", type: .philosophic),
            Quote(quote: "酒精正在进入你的血液。", translation: "Alcohol is entering your blood.", type: .scientific)
        ], isCritical: false)
    }
}
