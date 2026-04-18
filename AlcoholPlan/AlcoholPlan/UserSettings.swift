import SwiftUI
import Combine

enum Gender: String, CaseIterable, Identifiable {
    case male = "Male"
    case female = "Female"
    var id: String { self.rawValue }
    
    var rFactor: Double {
        switch self {
        case .male: return 0.68
        case .female: return 0.55
        }
    }
}

struct CountryLaw: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let enName: String
    let flag: String
    let duiLimit: Double // 酒后驾驶标准 BAC %
    let dwiLimit: Double? // 醉酒驾驶标准 BAC % (如果有)
    
    var isZeroTolerance: Bool { duiLimit <= 0.01 }
    
    var duiLimitString: String {
        return String(format: "DUI %.3f%%", duiLimit)
    }
    
    static let allCountries: [CountryLaw] = [
        CountryLaw(name: "中国", enName: "China", flag: "🇨🇳", duiLimit: 0.02, dwiLimit: 0.08),
        CountryLaw(name: "丹麦", enName: "Denmark", flag: "🇩🇰", duiLimit: 0.05, dwiLimit: nil),
        CountryLaw(name: "德国", enName: "Germany", flag: "🇩🇪", duiLimit: 0.05, dwiLimit: nil),
        CountryLaw(name: "法国", enName: "France", flag: "🇫🇷", duiLimit: 0.05, dwiLimit: nil),
        CountryLaw(name: "意大利", enName: "Italy", flag: "🇮🇹", duiLimit: 0.05, dwiLimit: nil),
        CountryLaw(name: "西班牙", enName: "Spain", flag: "🇪🇸", duiLimit: 0.05, dwiLimit: nil),
        CountryLaw(name: "英国", enName: "UK", flag: "🇬🇧", duiLimit: 0.08, dwiLimit: nil),
        CountryLaw(name: "美国", enName: "USA", flag: "🇺🇸", duiLimit: 0.08, dwiLimit: nil),
        CountryLaw(name: "加拿大", enName: "Canada", flag: "🇨🇦", duiLimit: 0.05, dwiLimit: 0.08),
        CountryLaw(name: "澳大利亚", enName: "Australia", flag: "🇦🇺", duiLimit: 0.05, dwiLimit: nil),
        CountryLaw(name: "日本", enName: "Japan", flag: "🇯🇵", duiLimit: 0.03, dwiLimit: nil),
        CountryLaw(name: "韩国", enName: "South Korea", flag: "🇰🇷", duiLimit: 0.03, dwiLimit: nil),
        CountryLaw(name: "俄罗斯", enName: "Russia", flag: "🇷🇺", duiLimit: 0.03, dwiLimit: nil),
        CountryLaw(name: "挪威", enName: "Norway", flag: "🇳🇴", duiLimit: 0.02, dwiLimit: nil),
        CountryLaw(name: "瑞典", enName: "Sweden", flag: "🇸🇪", duiLimit: 0.02, dwiLimit: nil),
        CountryLaw(name: "捷克", enName: "Czechia", flag: "🇨🇿", duiLimit: 0.001, dwiLimit: nil),
        CountryLaw(name: "沙特", enName: "Saudi Arabia", flag: "🇸🇦", duiLimit: 0.001, dwiLimit: nil)
    ]
    
    static let `default` = allCountries[0] // 中国 default
}

enum Persona: String, CaseIterable, Identifiable {
    case martin = "Martin"
    case nikolaj = "Nikolaj"
    case tommy = "Tommy"
    case peter = "Peter"
    case clara = "Clara"
    case elena = "Elena"
    case maya = "Maya"
    case sofia = "Sofia"
    
    var id: String { self.rawValue }
    
    var zhName: String {
        switch self {
        case .martin: return "马丁"
        case .nikolaj: return "尼古拉"
        case .tommy: return "汤米"
        case .peter: return "彼得"
        case .clara: return "克拉拉"
        case .elena: return "埃琳娜"
        case .maya: return "玛雅"
        case .sofia: return "索菲亚"
        }
    }
    
    var displayBilingualName: String {
        "\(zhName) / \(rawValue.uppercased())"
    }
    
    var avatarImageName: String {
        switch self {
        case .martin: return "persona_martin"
        case .nikolaj: return "persona_nikolaj"
        case .tommy: return "persona_tommy"
        case .peter: return "persona_peter"
        case .clara: return "persona_clara"
        case .elena: return "persona_elena"
        case .maya: return "persona_maya"
        case .sofia: return "persona_sofia"
        }
    }
    
    var zhPersonaType: String {
        switch self {
        case .martin: return "哲学探索者"
        case .nikolaj: return "克制平衡者"
        case .tommy: return "当下主义者"
        case .peter: return "数据理性者"
        case .clara: return "感性共鸣者"
        case .elena: return "独立清醒者"
        case .maya: return "自由灵魂者"
        case .sofia: return "社交仪式者"
        }
    }
    
    var enPersonaType: String {
        switch self {
        case .martin: return "THE PHILOSOPHER"
        case .nikolaj: return "THE BALANCER"
        case .tommy: return "THE PRESENTIST"
        case .peter: return "THE ANALYST"
        case .clara: return "THE RESONATOR"
        case .elena: return "THE OBSERVER"
        case .maya: return "THE FREE SPIRIT"
        case .sofia: return "THE RITUALIST"
        }
    }
    
    var zhDescription: String {
        switch self {
        case .martin: return "追求 0.05% 黄金点，相信适量酒精能让人活得更真实。"
        case .nikolaj: return "工作日戒断，周末有节制地放松，划清酒精与工作的边界。"
        case .tommy: return "不设目标，随遇而安，只为享受此时此刻的真实感。"
        case .peter: return "科学记录每一次摄入，用精准数字理解身体的酒精反应。"
        case .clara: return "酒是打开情感的钥匙，每一杯都与一段亲密关系有关。"
        case .elena: return "喝酒，但始终保持一部分自我在场，享受微醺而非沉睡。"
        case .maya: return "不在乎规则，只在乎纯粹感受，饮酒是一种自由宣言。"
        case .sofia: return "酒是庆典的语言，重视场合与仪式感，好酒必须分享。"
        }
    }
    
    var enDescription: String {
        switch self {
        case .martin: return "Chasing the 0.05% gold point, believing that moderated alcohol allows for a more authentic existence."
        case .nikolaj: return "Abstinent on weekdays, disciplined relaxation on weekends, drawing clear lines between duty and pleasure."
        case .tommy: return "Driven by the present, moving with the flow to savor the raw honesty of the current moment."
        case .peter: return "Recording every intake with scientific precision to master the body's reaction to every drop."
        case .clara: return "Alcohol is the catalyst for empathy, where every glass marks another shared human connection."
        case .elena: return "Drinking while staying partially present, savoring the haze without losing the self."
        case .maya: return "Indifferent to rules and standard metrics, drinking as a pure declaration of spiritual freedom."
        case .sofia: return "Alcohol is the language of celebration, prioritizing the ritual and the joy of shared experience."
        }
    }
    
    var gender: Gender {
        switch self {
        case .martin, .nikolaj, .tommy, .peter: return .male
        case .clara, .elena, .maya, .sofia: return .female
        }
    }
}

enum MetabolicRate: String, CaseIterable, Identifiable {
    case slow = "慢"
    case medium = "标准"
    case fast = "快"
    
    var id: String { self.rawValue }
    var value: Double {
        switch self {
        case .slow: return 0.012
        case .medium: return 0.015
        case .fast: return 0.020
        }
    }
    
    var displayName: String {
        switch self {
        case .slow: return "Slow / 慢速"
        case .medium: return "Standard / 标准"
        case .fast: return "Fast / 快速"
        }
    }
    
    var description: String {
        switch self {
        case .slow: return "Lower metabolic rate / 代谢较慢"
        case .medium: return "Average metabolic rate / 平均代谢"
        case .fast: return "Higher metabolic rate / 代谢较快"
        }
    }
}

class UserSettings: ObservableObject {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @Published var hasSeenCinematicIntro: Bool = false
    @AppStorage("defaultWeight") var defaultWeight: Double = 70.0
    @AppStorage("defaultGender") var defaultGenderStore: String = Gender.male.rawValue
    @AppStorage("defaultCountryName") var defaultCountryName: String = CountryLaw.default.name
    @AppStorage("persona") var personaStore: String = Persona.martin.rawValue
    @AppStorage("metabolicRate") var metabolicRateStore: String = MetabolicRate.medium.rawValue
    
    var defaultGender: Gender {
        get { Gender(rawValue: defaultGenderStore) ?? .male }
        set { defaultGenderStore = newValue.rawValue }
    }
    
    var selectedCountry: CountryLaw {
        get { CountryLaw.allCountries.first(where: { $0.name == defaultCountryName }) ?? .default }
        set { defaultCountryName = newValue.name }
    }
    
    var selectedPersona: Persona {
        get { Persona(rawValue: personaStore) ?? .martin }
        set { personaStore = newValue.rawValue }
    }
    
    var selectedMetabolicRate: MetabolicRate {
        get { MetabolicRate(rawValue: metabolicRateStore) ?? .medium }
        set { metabolicRateStore = newValue.rawValue }
    }
}
