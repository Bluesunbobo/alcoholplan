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
    @Published var persona: Persona
    
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
    @Published var peakBACTime: Date? = nil
    @Published var safeDate: Date? = nil
    
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
    private var recentQuoteTexts: [String] = [] // History for deduplication
    
    private let context = PersistenceController.shared.container.viewContext
    
    init(defaultWeight: Double, defaultGender: Gender, defaultCountry: CountryLaw, defaultRate: MetabolicRate = .medium, defaultPersona: Persona = .martin) {
        self.weight = defaultWeight
        self.gender = defaultGender
        self.country = defaultCountry
        self.metabolicRate = defaultRate
        self.persona = defaultPersona
        
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
                self.peakBACTime = nil
                self.safeDate = nil
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
        
        let hoursUntilSafe = (totalPotentialPeak - country.duiLimit) / beta
        let calculatedSafeDate = hoursUntilSafe > 0 ? firstDrinkTime.addingTimeInterval(hoursUntilSafe * 3600) : nil
        
        let lastDrinkTime = drinks.last!.timestamp
        let timeSinceLast = now.timeIntervalSince(lastDrinkTime) / 3600.0
        let newIsSoberingDown = (timeSinceLast > 0.75) && finalBAC > 0
        
        let updates = {
            self.bacPercentage = finalBAC
            self.totalAlcoholGrams = totalAlcoholMassGrams
            self.totalLiquidVolumeML = self.drinks.map { $0.volumeML }.reduce(0, +)
            self.isSoberingDown = newIsSoberingDown
            self.soberDate = finalBAC > 0.0001 ? calculatedSoberDate : nil
            self.safeDate = (totalPotentialPeak > self.country.duiLimit) ? calculatedSafeDate : nil
            
            if let session = self.activeSession {
                if finalBAC > session.peakBAC {
                    session.peakBAC = finalBAC
                }
            }
            
            self.syncSimulation()
            
            let points = self.getTrajectoryPoints()
            self.peakBACTime = points.max(by: { $0.bac < $1.bac })?.time
            
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
        peakBACTime = nil
        safeDate = nil
        refreshQuote()
    }
    
    func updateStateLabels(forBAC: Double? = nil) {
        let targetBAC = forBAC ?? bacPercentage
        let stateRange = QuotesDB.shared.getStateRange(for: targetBAC, in: country, isSoberingDown: forBAC == nil ? isSoberingDown : false, persona: persona)
        
        self.currentStateNameZh = stateRange.stateNameZh
        self.currentStateNameEn = stateRange.stateNameEn
    }
    
    func refreshQuote(forBAC: Double? = nil) {
        let targetBAC = forBAC ?? bacPercentage
        let stateRange = QuotesDB.shared.getStateRange(for: targetBAC, in: country, isSoberingDown: forBAC == nil ? isSoberingDown : false, persona: persona)
        
        updateStateLabels(forBAC: targetBAC)
        
        self.currentAvatarImage = stateRange.avatarImage
        
        // Anti-repeat logic: Filter candidates against recently shown quotes
        let candidates = stateRange.quotes.isEmpty ? QuotesDB.shared.neutralQuotes : stateRange.quotes
        var filtered = candidates.filter { !recentQuoteTexts.contains($0.quote) }
        
        // If pool is too small and everything was filtered out, just exclude the very last one
        if filtered.isEmpty && !candidates.isEmpty {
            if let last = recentQuoteTexts.last {
                filtered = candidates.filter { $0.quote != last }
            }
        }
        
        // Fallback: use unfiltered if needed
        let pool = filtered.isEmpty ? candidates : filtered
        
        if let newQuote = pool.randomElement() {
            self.currentQuote = newQuote
            
            // Update history
            recentQuoteTexts.append(newQuote.quote)
            if recentQuoteTexts.count > 8 { // Keep last 8 for variety
                recentQuoteTexts.removeFirst()
            }
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
