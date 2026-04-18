import SwiftUI
import Combine
import CoreData

extension Notification.Name {
    static let drinkSessionChanged = Notification.Name("drinkSessionChanged")
}

struct DrinkEntryData {
    let timestamp: Date
    let abv: Double
    let volumeML: Double
}

class AlcoholBrain: ObservableObject {
    // User Settings bindings
    @Published var weight: Double
    @Published var gender: Gender
    @Published var country: CountryLaw
    @Published var metabolicRate: MetabolicRate
    
    @Published var pendingABV: Double = 0.05 {
        didSet { syncSimulation() }
    }
    @Published var pendingVolumeML: Double = 0.0 {
        didSet { syncSimulation() }
    }
    @Published var pendingTargetBAC: Double = 0.0
    @Published var pendingHangoverScore: Int16 = 0
    
    @Published var displayBACString: String = "0.000" {
        didSet {
            if let val = Double(displayBACString) {
                updateStateLabels(forBAC: val)
            }
        }
    }
    @Published var isInputFocused: Bool = false
    
    @Published var bacPercentage: Double = 0.0
    @Published var totalAlcoholGrams: Double = 0.0
    @Published var totalLiquidVolumeML: Double = 0.0
    @Published var isSoberingDown: Bool = false
    @Published var soberDate: Date? = nil
    
    var isSimulating: Bool {
        pendingVolumeML > 0 || isInputFocused
    }
    
    @Published var currentQuote: Quote = QuotesDB.shared.neutralQuotes[0]
    @Published var currentStateNameEn: String = "The Sober"
    @Published var currentStateNameZh: String = "清醒如水"
    @Published var currentAvatarImage: String = "personality_sober"
    
    var activeSession: DrinkSession?
    var drinks: [DrinkEntryData] = []
    
    private var timer: AnyCancellable?
    private var quoteTimer: AnyCancellable?
    
    private let context = PersistenceController.shared.container.viewContext
    
    init(defaultWeight: Double, defaultGender: Gender, defaultCountry: CountryLaw, defaultRate: MetabolicRate = .medium) {
        self.weight = defaultWeight
        self.gender = defaultGender
        self.country = defaultCountry
        self.metabolicRate = defaultRate
        
        loadActiveSession()
        startTimers()
    }
    
    private func loadActiveSession() {
        let request: NSFetchRequest<DrinkSession> = DrinkSession.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \DrinkSession.startTime, ascending: false)]
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            if let lastSession = results.first {
                if lastSession.endTime == nil {
                    // It's still active
                    self.activeSession = lastSession
                    if let entriesSet = lastSession.entries as? Set<DrinkEntry> {
                        self.drinks = entriesSet.compactMap {
                            guard let ts = $0.timestamp else { return nil }
                            return DrinkEntryData(timestamp: ts, abv: $0.abv, volumeML: $0.volumeML)
                        }.sorted(by: { $0.timestamp < $1.timestamp })
                    }
                }
            }
        } catch {
            print("Failed to fetch session: \(error)")
        }
        recalculateBAC()
    }
    
    func startTimers() {
        timer = Timer.publish(every: 15.0, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            self?.recalculateBAC()
        }
        
        quoteTimer = Timer.publish(every: 90.0, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            self?.refreshQuote()
        }
        refreshQuote()
    }
    
    func recalculateBAC() {
        guard !drinks.isEmpty else {
            let updates = {
                self.bacPercentage = 0.0
                self.totalAlcoholGrams = 0.0
                self.totalLiquidVolumeML = 0.0
                self.isSoberingDown = false
                self.syncSimulation()
                self.soberDate = nil
            }
            if Thread.isMainThread { updates() } else { DispatchQueue.main.async(execute: updates) }
            return
        }
        
        let now = Date()
        let beta = metabolicRate.value
        let firstDrinkTime = drinks.first!.timestamp
        
        var potentialTotalBAC = 0.0
        var totalAlcoholMassGrams = 0.0
        
        for drink in drinks {
            let pureAlcoholML = drink.volumeML * drink.abv
            
            let alcoholMassGramsForDrink = pureAlcoholML * 0.789
            totalAlcoholMassGrams += alcoholMassGramsForDrink
            
            let peakBACForDrink = alcoholMassGramsForDrink / (weight * gender.rFactor * 10)
            let elapsed = now.timeIntervalSince(drink.timestamp) / 3600.0
            
            if elapsed >= 0 {
                let absorptionRatio = min(1.0, elapsed / 0.75)
                potentialTotalBAC += peakBACForDrink * absorptionRatio
            }
        }
        
        let totalElapsedSinceStart = now.timeIntervalSince(firstDrinkTime) / 3600.0
        let rawBAC = potentialTotalBAC - (beta * totalElapsedSinceStart)
        let finalBAC = max(0, rawBAC)
        
        let totalPotentialPeak = totalAlcoholMassGrams / (weight * gender.rFactor * 10)
        let hoursUntilSober = totalPotentialPeak / beta
        let calculatedSoberDate = firstDrinkTime.addingTimeInterval(hoursUntilSober * 3600)
        
        let lastDrinkTime = drinks.last!.timestamp
        let timeSinceLast = now.timeIntervalSince(lastDrinkTime) / 3600.0
        let newIsSoberingDown = (timeSinceLast > 0.75) && finalBAC > 0
        
        let updates = {
            self.bacPercentage = finalBAC
            self.totalAlcoholGrams = totalAlcoholMassGrams
            self.totalLiquidVolumeML = self.drinks.map { $0.volumeML }.reduce(0, +)
            self.isSoberingDown = newIsSoberingDown
            self.soberDate = finalBAC > 0.0001 ? calculatedSoberDate : nil
            
            if let session = self.activeSession {
                if finalBAC > session.peakBAC {
                    session.peakBAC = finalBAC
                }
            }
            
            self.syncSimulation()
            
            if !self.isInputFocused && self.pendingVolumeML <= 0 {
                self.displayBACString = String(format: "%.3f", finalBAC)
                self.refreshQuote()
            }
            
            if finalBAC <= 0.0001 && !self.drinks.isEmpty && timeSinceLast > 1.0 {
                self.closeSession()
            }
        }
        
        if Thread.isMainThread {
            updates()
        } else {
            DispatchQueue.main.async(execute: updates)
        }
    }
    
    // MARK: - Simulation Math
    func syncSimulation() {
        let beta = metabolicRate.value
        let addedAlcoholGrams = pendingVolumeML * pendingABV * 0.789
        let addedBAC = addedAlcoholGrams / (weight * gender.rFactor * 10)
        
        // Compensate for metabolic loss during the 0.75h absorption period
        // Actual peak = (current + added) - (beta * 0.75)
        let totalPotentialBAC = bacPercentage + addedBAC
        pendingTargetBAC = max(0, totalPotentialBAC - (beta * 0.75))
        
        if !isInputFocused {
            displayBACString = String(format: "%.3f", pendingTargetBAC)
        }
    }
    
    func commitSimulation() {
        // Finalize simulation state and refresh heavy UI elements (quotes/status names)
        self.refreshQuote(forBAC: pendingTargetBAC)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    func validateBACInput() {
        // 限制输入的小数位数不超过3位
        let filteredString = displayBACString
            .replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)
        
        // 确保只有一个小数点
        let components = filteredString.components(separatedBy: ".")
        var limitedString = components[0]
        if components.count > 1 {
            // 严格限制小数位数不超过3位
            let decimalPart = components[1]
            if decimalPart.count > 3 {
                // 如果超过3位，只保留前3位
                limitedString += "." + String(decimalPart.prefix(3))
            } else {
                limitedString += "." + decimalPart
            }
        }
        
        if limitedString != displayBACString {
            displayBACString = limitedString
        }
    }
    
    func applyTargetBACFromInput() {
        if let targetBAC = Double(displayBACString) {
            let beta = metabolicRate.value
            let compensation = beta * 0.75
            
            // Re-calculate volume needed to reach targetBAC as the ACTUAL PEAK
            // Expected Peak = (CurrentBAC + AddedBAC) - Compensation
            let adjustedTargetAdded = max(0, targetBAC - bacPercentage + compensation)
            let newVol = (adjustedTargetAdded * weight * gender.rFactor * 10) / (pendingABV * 0.789)
            
            // Temporary detach of auto-sync to avoid circular state updates
            let wasFocused = isInputFocused
            isInputFocused = true
            pendingVolumeML = min(max(0, newVol), 2000)
            
            // Recalculate pending target with compensation for UI display
            let actualAddedBAC = (pendingVolumeML * pendingABV * 0.789) / (weight * gender.rFactor * 10)
            pendingTargetBAC = max(0, bacPercentage + actualAddedBAC - compensation)
            
            isInputFocused = wasFocused
            
            // Ensure display string shows the compensated target peak
            displayBACString = String(format: "%.3f", pendingTargetBAC)
            
            commitSimulation()
        } else if !isInputFocused {
            displayBACString = String(format: "%.3f", pendingTargetBAC)
        }
    }

    
    func logDrink() {
        addDrink()
    }
    
    func addDrink() {
        guard pendingVolumeML > 0 && pendingABV > 0 else { return }
        
        let now = Date()
        
        if activeSession == nil {
            let session = DrinkSession(context: context)
            session.id = UUID()
            session.startTime = now
            session.peakBAC = pendingTargetBAC
            session.totalVolumeML = pendingVolumeML
            session.totalAlcoholGrams = pendingVolumeML * pendingABV * 0.789
            self.activeSession = session
        }
        
        guard let session = activeSession else { return }
        
        let entry = DrinkEntry(context: context)
        entry.id = UUID()
        entry.timestamp = now
        entry.abv = pendingABV
        entry.volumeML = pendingVolumeML
        entry.drinkType = "Drink" // Can be expanded
        
        session.addToEntries(entry)
        session.totalVolumeML += pendingVolumeML
        session.totalAlcoholGrams += pendingVolumeML * pendingABV * 0.789
        
        // Sync hangover score from Ledger to session
        if pendingHangoverScore > 0 {
            session.hangoverScore = pendingHangoverScore
        }
        
        drinks.append(DrinkEntryData(timestamp: now, abv: pendingABV, volumeML: pendingVolumeML))
        
        do {
            try context.save()
        } catch {
            print("Failed to save drink: \(error)")
        }
        
        pendingVolumeML = 0.0
        pendingHangoverScore = 0
        recalculateBAC()
        refreshQuote()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        // Notify other views (e.g. History @FetchRequest) that session data changed
        NotificationCenter.default.post(name: .drinkSessionChanged, object: nil)
    }
    
    // MARK: - Session Deletion (called from History tab)
    func deleteSession(_ session: DrinkSession) {
        // If deleting the currently active session, clear in-memory state
        if let active = activeSession, active.id == session.id {
            activeSession = nil
            drinks.removeAll()
        }
        
        // Delete from Core Data
        context.delete(session)
        do {
            try context.save()
        } catch {
            print("Failed to delete session: \(error)")
        }
        
        // Recalculate everything — BAC, units, quotes, display string
        recalculateBAC()
        refreshQuote()
        objectWillChange.send()
        
        // Notify @FetchRequest-based views
        NotificationCenter.default.post(name: .drinkSessionChanged, object: nil)
    }
    
    // MARK: - Reload from Core Data
    func reloadFromCoreData() {
        loadActiveSession()
        refreshQuote()
    }
    
    private func closeSession() {
        if let session = activeSession {
            session.endTime = Date()
            do {
                try context.save()
            } catch {
                print("Failed to save ended session: \(error)")
            }
        }
        activeSession = nil
        drinks.removeAll()
        bacPercentage = 0.0
        totalAlcoholGrams = 0.0
        totalLiquidVolumeML = 0.0
        isSoberingDown = false
        refreshQuote()
    }
    
    func updateStateLabels(forBAC: Double? = nil) {
        let targetBAC = forBAC ?? bacPercentage
        let stateRange = QuotesDB.shared.getStateRange(for: targetBAC, in: country, isSoberingDown: forBAC == nil ? isSoberingDown : false)
        
        self.currentStateNameZh = stateRange.stateNameZh
        self.currentStateNameEn = stateRange.stateNameEn
    }
    
    func refreshQuote(forBAC: Double? = nil) {
        let targetBAC = forBAC ?? bacPercentage
        let stateRange = QuotesDB.shared.getStateRange(for: targetBAC, in: country, isSoberingDown: forBAC == nil ? isSoberingDown : false)
        
        updateStateLabels(forBAC: targetBAC)
        
        self.currentAvatarImage = stateRange.avatarImage
        
        if let newQuote = stateRange.quotes.randomElement() {
            self.currentQuote = newQuote
        } else {
            self.currentQuote = QuotesDB.shared.neutralQuotes.randomElement()!
        }
    }
    
    func setABV(_ target: Double) {
        self.pendingABV = target
    }
    
    func calculateMetabolicEnd() -> String {
        guard let endDate = soberDate else { return "--:--" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: endDate)
    }
    
    var timePeriod: String {
        guard let endDate = soberDate else { return "" }
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: endDate)
        return hour < 12 ? "AM" : "PM"
    }
    
    static func calculateTrajectory(
        drinks: [DrinkEntryData],
        weight: Double,
        gender: Gender,
        metabolicRate: MetabolicRate,
        referenceTime: Date = Date()
    ) -> [(time: Date, bac: Double, isPredicted: Bool)] {
        var points: [(Date, Double, Bool)] = []
        guard !drinks.isEmpty else { return points }
        
        let beta = metabolicRate.value
        let firstDrinkTime = drinks.first!.timestamp
        let totalAlcoholMassGrams = (drinks.map { $0.volumeML * $0.abv * 0.789 }.reduce(0, +))
        let totalPotentialPeak = totalAlcoholMassGrams / (weight * gender.rFactor * 10)
        let hoursUntilSober = totalPotentialPeak / beta
        let soberDateFinal = firstDrinkTime.addingTimeInterval(hoursUntilSober * 3600)
        
        var current = firstDrinkTime
        // Loop from first drink until soberDateFinal
        while current <= soberDateFinal.addingTimeInterval(3600) { // Add 1 hour buffer
            var potentialBACAtT = 0.0
            for drink in drinks {
                let elapsed = current.timeIntervalSince(drink.timestamp) / 3600.0
                if elapsed >= 0 {
                    let ratio = min(1.0, elapsed / 0.75)
                    let peakForDrink = (drink.volumeML * drink.abv * 0.789) / (weight * gender.rFactor * 10)
                    potentialBACAtT += peakForDrink * ratio
                }
            }
            
            let elapsedTotal = current.timeIntervalSince(firstDrinkTime) / 3600.0
            let finalBACAtT = max(0, potentialBACAtT - (beta * elapsedTotal))
            
            points.append((current, finalBACAtT, current > referenceTime))
            
            if finalBACAtT <= 1e-6 && current > referenceTime { break }
            current = current.addingTimeInterval(600) // 10 min steps
            
            // Safety break to prevent infinite loops
            if points.count > 500 { break }
        }
        return points
    }
    
    func getTrajectoryPoints() -> [(time: Date, bac: Double, isPredicted: Bool)] {
        return AlcoholBrain.calculateTrajectory(
            drinks: self.drinks,
            weight: self.weight,
            gender: self.gender,
            metabolicRate: self.metabolicRate,
            referenceTime: Date()
        )
    }
}
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
        Quote(quote: "Ernest Hemingway 说：写醉，改清醒。也许生活也是一样。", translation: "Write drunk, edit sober. Maybe life is the same.", type: .neutral),
        Quote(quote: "喝酒不能解决问题。但它能让你暂时不在乎那个问题。这有时候也是一种解法。", translation: "Drinking doesn't solve problems. But it makes you stop caring for a while.", type: .neutral)
    ]
    
    struct StateRange {
        let minBAC: Double
        let maxBAC: Double
        let stateNameZh: String
        let stateNameEn: String
        let avatarImage: String
        let quotes: [Quote]
        let isCritical: Bool
    }
    
    // Based on PRD 4.2 Table
    func getStateRange(for bac: Double, in country: CountryLaw, isSoberingDown: Bool) -> StateRange {
        
        if isSoberingDown {
            return StateRange(minBAC: 0, maxBAC: 1.0, stateNameZh: "清醒倒计时", stateNameEn: "Sobering Up", avatarImage: "personality_sobering", quotes: [
                Quote(quote: "酒精会离开。它带走的东西，有时不会回来。", translation: "Alcohol leaves. What it takes away sometimes doesn't come back.", type: .philosophic),
                Quote(quote: "你的肝脏正在以约 0.015% 每小时的速度处理它。", translation: "Your liver is processing it at about 0.015% per hour.", type: .scientific),
                Quote(quote: "等待，也是一种选择。", translation: "Waiting is also a choice.", type: .philosophic)
            ], isCritical: false)
        }
        
        if bac < 0.001 {
            return StateRange(minBAC: 0.0, maxBAC: 0.001, stateNameZh: "清醒如水", stateNameEn: "The Sober", avatarImage: "personality_sober", quotes: [
                Quote(quote: "我们生来就缺少一点什么。", translation: "We are born missing something. (Skårderud)", type: .philosophic),
                Quote(quote: "今晚，你想成为哪个版本的自己？", translation: "Which version of yourself do you want to be tonight?", type: .philosophic),
                Quote(quote: "还没开始。或者，已经结束了。", translation: "It hasn't started yet. Or, it's already over.", type: .philosophic)
            ], isCritical: false)
        }
        
        if country.isZeroTolerance && bac >= 0.001 {
            return StateRange(minBAC: 0.001, maxBAC: 1.0, stateNameZh: "零容忍区域", stateNameEn: "Zero Tolerance Zone", avatarImage: "personality_sober", quotes: [
                Quote(quote: "你选择的国家/地区对任何可检测酒精实行零容忍。在这里，任何饮酒后驾车均违法。", translation: "Your region imposes zero tolerance on alcohol. Any driving after drinking is illegal.", type: .warning)
            ], isCritical: true)
        }
        
        let dwiLimit = country.dwiLimit ?? 1.0
        // unused duiLimit removed
        
        if bac >= 0.150 {
            return StateRange(minBAC: 0.150, maxBAC: 1.0, stateNameZh: "过度醉酒", stateNameEn: "Highly Intoxicated", avatarImage: "personality_druk", quotes: [
                Quote(quote: "这个水平存在医疗风险。请确保身边有人陪伴。", translation: "Medical risk present. Ensure someone is with you.", type: .warning),
                Quote(quote: "BAC 0.15% 以上：意识障碍和呼吸抑制风险显著上升。", translation: "High risk of impaired consciousness and respiratory depression.", type: .scientific),
                Quote(quote: "有些梦，还是不醒比较好。", translation: "Some dreams are better left uninterrupted.", type: .philosophic)
            ], isCritical: true)
        }
        
        if bac >= 0.100 {
            return StateRange(minBAC: 0.100, maxBAC: 0.149, stateNameZh: "沉醉时分", stateNameEn: "The Druk", avatarImage: "personality_druk", quotes: [
                Quote(quote: "在某个时刻，我们不再是在庆祝，而是在逃跑。", translation: "At some point, we are no longer celebrating, but running away.", type: .philosophic),
                Quote(quote: "平衡感明显受影响。记忆出现空白的可能性在上升。", translation: "Balance is notably impaired. Risk of memory blackout is rising.", type: .scientific),
                Quote(quote: "宇宙在模糊中变得清晰。", translation: "The universe becomes clear in the blur.", type: .philosophic)
            ], isCritical: true)
        }
        
        if bac >= dwiLimit || bac >= 0.081 {
            return StateRange(minBAC: 0.081, maxBAC: 0.099, stateNameZh: "边界之上", stateNameEn: "Over the Line", avatarImage: "personality_drifter", quotes: [
                Quote(quote: "这不是评判。这只是一个事实：你现在不适合驾车。", translation: "This isn't a judgment. It's a fact: you are not fit to drive now.", type: .warning),
                Quote(quote: "边界的另一边是法律，不是感受。", translation: "On the other side of the boundary is the law, not feelings.", type: .warning),
                Quote(quote: "漂浮的灵魂，需要一个港湾。", translation: "A floating soul needs a harbor.", type: .philosophic)
            ], isCritical: true)
        }
        
        if bac >= 0.051 {
            return StateRange(minBAC: 0.051, maxBAC: 0.080, stateNameZh: "明显感受", stateNameEn: "Noticeably There", avatarImage: "personality_drifter", quotes: [
                Quote(quote: "你感觉很好。这不是假的。但它也不会持续太久。", translation: "You feel great. It's not fake. But it won't last long.", type: .philosophic),
                Quote(quote: "什么是青春？一场梦。什么是爱？梦的内容。", translation: "What is youth? A dream. What is love? The content of the dream. (Kierkegaard)", type: .philosophic),
                Quote(quote: "协调能力开始轻微下降。请不要开车。", translation: "Coordination is slightly down. Please don't drive.", type: .warning)
            ], isCritical: false)
        }
        
        if bac >= 0.050 {
            return StateRange(minBAC: 0.050, maxBAC: 0.0509, stateNameZh: "哲学黄金点", stateNameEn: "The Philosophic Gold Point", avatarImage: "personality_philosopher", quotes: [
                Quote(quote: "人类血液中天生缺少 0.05% 的酒精。今晚，你补上了。", translation: "Humans are born lacking 0.05% alcohol. Tonight, you made it up.", type: .philosophic),
                Quote(quote: "感受是主观的，身体是诚实的。", translation: "Feelings are subjective, the body is honest.", type: .scientific)
            ], isCritical: false)
        }
        
        if bac >= 0.031 {
            return StateRange(minBAC: 0.031, maxBAC: 0.049, stateNameZh: "渐入佳境", stateNameEn: "Settling In", avatarImage: "personality_sensual", quotes: [
                Quote(quote: "丹麦人把这叫做 'hyggelig'——舒适、温暖、完全在场。", translation: "The Danes call this 'hyggelig' — cozy, warm, fully present.", type: .philosophic),
                Quote(quote: "对话开始变得有趣了。", translation: "The conversation is starting to get interesting.", type: .philosophic)
            ], isCritical: false)
        }
        
        if bac >= 0.020 {
            return StateRange(minBAC: 0.020, maxBAC: 0.030, stateNameZh: "微醺助性点", stateNameEn: "The Sensual Sweet Spot", avatarImage: "personality_sensual", quotes: [
                Quote(quote: "你开始比五分钟前更像你自己了。", translation: "You are starting to feel more like yourself than five minutes ago.", type: .philosophic),
                Quote(quote: "触碰变得更真实。声音更清晰。", translation: "Touch becomes more real. Sounds become clearer.", type: .scientific)
            ], isCritical: false)
        }
        
        return StateRange(minBAC: 0.001, maxBAC: 0.019, stateNameZh: "刚刚开始", stateNameEn: "Just Starting", avatarImage: "personality_sensual", quotes: [
            Quote(quote: "第一杯之后，世界的边缘变得柔软了一点点。", translation: "After the first glass, the edges of the world got a little bit softer.", type: .philosophic),
            Quote(quote: "酒精正在进入你的血液。", translation: "Alcohol is entering your blood.", type: .scientific)
        ], isCritical: false)
    }
}
