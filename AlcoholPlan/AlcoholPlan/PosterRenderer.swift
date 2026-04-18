import SwiftUI
import UIKit
import CoreData

@MainActor
class PosterRenderer {
    static let shared = PosterRenderer()
    
    /// Renders a poster from session data and presents the share sheet.
    func shareSessionPoster(session: DrinkSession, brain: AlcoholBrain, userSettings: UserSettings) {
        let data = prepareData(from: session, brain: brain, userSettings: userSettings)
        let posterView = SharePosterView(sessionData: data, userSettings: userSettings)
            .environment(\.colorScheme, .dark)
        
        let renderer = ImageRenderer(content: posterView)
        renderer.scale = 2.0
        
        if let image = renderer.uiImage {
            presentShareSheet(with: image)
        }
    }
    
    /// Overload for sharing the CURRENT active session from dashboard
    func shareLiveSession(brain: AlcoholBrain, userSettings: UserSettings) {
        let images = createLivePosterImages(brain: brain, userSettings: userSettings)
        if let first = images.first {
            presentShareSheet(with: first)
        }
    }
    
    /// Returns rendered UIImages for a historical session
    func createHistoricalPosterImages(session: DrinkSession, brain: AlcoholBrain, userSettings: UserSettings) -> [UIImage] {
        var images: [UIImage] = []
        
        let data = prepareData(from: session, brain: brain, userSettings: userSettings)
        let posterView = SharePosterView(sessionData: data, userSettings: userSettings)
            .environment(\.colorScheme, .dark)
        
        let renderer = ImageRenderer(content: posterView)
        renderer.scale = 2.0
        
        if let img = renderer.uiImage {
            images.append(img)
        }
        
        // Generate Heatmap for the year of that session
        let calendar = Calendar.current
        let sessionYear = session.startTime.map { calendar.component(.year, from: $0) } ?? calendar.component(.year, from: Date())
        
        let heatmapData = createHeatmapData(targetYear: sessionYear)
        let heatmapView = HeatmapPosterView(data: heatmapData)
            .environment(\.colorScheme, .dark)
            
        let hmRenderer = ImageRenderer(content: heatmapView)
        hmRenderer.scale = 2.0
        
        if let hmImg = hmRenderer.uiImage {
            images.append(hmImg)
        }
        
        return images
    }
    
    /// Returns rendered UIImages [Live Poster, Heatmap Poster] for preview purposes
    func createLivePosterImages(brain: AlcoholBrain, userSettings: UserSettings) -> [UIImage] {
        var images: [UIImage] = []
        
        let drinks = brain.drinks
        if !drinks.isEmpty {
            let trajectory = brain.getTrajectoryPoints()
            let peakBAC = trajectory.map { $0.bac }.max() ?? brain.bacPercentage
            let totalAlcohol = drinks.map { $0.volumeML * $0.abv * 0.789 }.reduce(0, +)
            
            let peakDP = trajectory.max(by: { $0.bac < $1.bac })
            let peakTimeString = peakDP?.time.formatted(date: .omitted, time: .shortened) ?? "--:--"
            
            var detailsMap: [String: (vol: Double, abv: Double)] = [:]
            for d in drinks {
                let name = getDrinkName(for: d.abv)
                let key = "\(name)_\(d.abv)"
                if let existing = detailsMap[key] {
                    detailsMap[key] = (existing.vol + d.volumeML, d.abv)
                } else {
                    detailsMap[key] = (d.volumeML, d.abv)
                }
            }
            let drinksDetail = detailsMap.map { (key, value) -> PosterDrinkDetail in
                let name = String(key.split(separator: "_").first ?? "Drink")
                return PosterDrinkDetail(name: name, abv: value.abv, volumeML: value.vol)
            }.sorted { $0.volumeML > $1.volumeML }
            
            let data = PosterSessionData(
                dateString: Date().formatted(date: .abbreviated, time: .shortened).uppercased(),
                avatarImage: brain.currentAvatarImage,
                statusZh: brain.currentStateNameZh,
                statusEn: brain.currentStateNameEn,
                peakBAC: peakBAC,
                drinksDetail: drinksDetail,
                totalAlcohol: totalAlcohol,
                peakTime: peakTimeString,
                quoteZh: brain.currentQuote.quote,
                quoteEn: brain.currentQuote.translation,
                trajectory: trajectory
            )
            
            let posterView = SharePosterView(sessionData: data, userSettings: userSettings)
                .environment(\.colorScheme, .dark)
            
            let renderer = ImageRenderer(content: posterView)
            renderer.scale = 2.0
            
            if let img = renderer.uiImage {
                images.append(img)
            }
        }
        
        // Generate Heatmap
        let heatmapData = createHeatmapData(targetYear: nil)
        let heatmapView = HeatmapPosterView(data: heatmapData)
            .environment(\.colorScheme, .dark)
            
        let hmRenderer = ImageRenderer(content: heatmapView)
        hmRenderer.scale = 2.0
        
        if let hmImg = hmRenderer.uiImage {
            images.append(hmImg)
        }
        
        return images
    }
    
    private var activeSaver: ImageSaver?
    
    /// Helper to save image to photo library with completion
    func saveImageToPhotos(_ image: UIImage, completion: @escaping (Bool, Error?) -> Void) {
        let saver = ImageSaver { [weak self] success, error in
            completion(success, error)
            self?.activeSaver = nil
        }
        self.activeSaver = saver
        UIImageWriteToSavedPhotosAlbum(image, saver, #selector(ImageSaver.didFinishSavingWithError), nil)
    }
    
    private func prepareData(from session: DrinkSession, brain: AlcoholBrain, userSettings: UserSettings) -> PosterSessionData {
        let entries = session.entries as? Set<DrinkEntry> ?? []
        let drinkData = entries.compactMap { e -> DrinkEntryData? in
            guard let ts = e.timestamp else { return nil }
            return DrinkEntryData(timestamp: ts, abv: e.abv, volumeML: e.volumeML)
        }.sorted(by: { $0.timestamp < $1.timestamp })
        
        // Use session.startTime and session.endTime for trajectory calculation
        let refTime = session.endTime ?? Date()
        let trajectory = AlcoholBrain.calculateTrajectory(
            drinks: drinkData,
            weight: userSettings.defaultWeight,
            gender: userSettings.defaultGender,
            metabolicRate: userSettings.selectedMetabolicRate,
            referenceTime: refTime
        )
        
        let peakBAC = session.peakBAC
        let totalAlcohol = session.totalAlcoholGrams
        let peakDP = trajectory.max(by: { $0.bac < $1.bac })
        let peakTimeString = peakDP?.time.formatted(date: .omitted, time: .shortened) ?? "--:--"
        
        var detailsMap: [String: (vol: Double, abv: Double)] = [:]
        let rawEntries = session.entries as? Set<DrinkEntry> ?? []
        for e in rawEntries {
            let name = e.drinkType == "Drink" || e.drinkType == nil ? getDrinkName(for: e.abv) : e.drinkType!
            let key = "\(name)_\(e.abv)"
            if let existing = detailsMap[key] {
                detailsMap[key] = (existing.vol + e.volumeML, e.abv)
            } else {
                detailsMap[key] = (e.volumeML, e.abv)
            }
        }
        let drinksDetail = detailsMap.map { (key, value) -> PosterDrinkDetail in
            let name = String(key.split(separator: "_").first ?? "Drink")
            return PosterDrinkDetail(name: name, abv: value.abv, volumeML: value.vol)
        }.sorted { $0.volumeML > $1.volumeML }
        
        let stateRange = QuotesDB.shared.getStateRange(for: peakBAC, in: userSettings.selectedCountry, isSoberingDown: false)
        let randomQuote = stateRange.quotes.randomElement() ?? QuotesDB.shared.neutralQuotes.randomElement()!
        
        return PosterSessionData(
            dateString: session.startTime?.formatted(date: .abbreviated, time: .shortened).uppercased() ?? "RECORDED SESSION",
            avatarImage: stateRange.avatarImage,
            statusZh: stateRange.stateNameZh,
            statusEn: stateRange.stateNameEn,
            peakBAC: peakBAC,
            drinksDetail: drinksDetail,
            totalAlcohol: totalAlcohol,
            peakTime: peakTimeString,
            quoteZh: randomQuote.quote,
            quoteEn: randomQuote.translation,
            trajectory: trajectory
        )
    }
    
    private func createHeatmapData(targetYear: Int? = nil) -> HeatmapData {
        let request: NSFetchRequest<DrinkSession> = DrinkSession.fetchRequest()
        
        let calendar = Calendar.current
        let currentYear = targetYear ?? calendar.component(.year, from: Date())
        let startOfYear = calendar.date(from: DateComponents(year: currentYear, month: 1, day: 1))!
        
        var dates = [Date]()
        var currentDate = startOfYear
        while calendar.component(.year, from: currentDate) == currentYear {
            dates.append(currentDate)
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDay
        }
        
        let context = PersistenceController.shared.container.viewContext
        var sessionCount = 0
        var maxBAC = 0.0
        var heatmapMap: [Date: Double] = [:]
        
        if let results = try? context.fetch(request) {
            for s in results {
                if let startTime = s.startTime, calendar.component(.year, from: startTime) == currentYear {
                    sessionCount += 1
                    if s.peakBAC > maxBAC { maxBAC = s.peakBAC }
                    let date = calendar.startOfDay(for: startTime)
                    heatmapMap[date] = (heatmapMap[date] ?? 0) + s.totalAlcoholGrams
                }
            }
        }
        
        var days: [HeatmapDay] = []
        for d in dates {
             days.append(HeatmapDay(date: d, bac: heatmapMap[d] ?? 0.0)) // Reusing 'bac' payload field to hold grams
        }
        
        let q = QuotesDB.shared.neutralQuotes.randomElement()!
        
        return HeatmapData(
            year: "\(currentYear)",
            totalDrinks: sessionCount,
            highestBAC: maxBAC,
            favoriteDrink: "",
            days: days,
            quoteZh: q.quote,
            quoteEn: q.translation
        )
    }
    
    private func presentShareSheet(with image: UIImage) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }
        
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = rootViewController.view
            popover.sourceRect = CGRect(x: rootViewController.view.bounds.midX, y: rootViewController.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        rootViewController.present(activityVC, animated: true)
    }
}

/// Assistant class to handle UIImageWriteToSavedPhotosAlbum callbacks
class ImageSaver: NSObject {
    var completion: ((Bool, Error?) -> Void)?
    
    init(completion: @escaping (Bool, Error?) -> Void) {
        self.completion = completion
    }
    
    @objc func didFinishSavingWithError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        completion?(error == nil, error)
    }
}

// Global Helper to infer drink name from ABV
fileprivate func getDrinkName(for abv: Double) -> String {
    let pct = abv * 100
    if pct < 8.0 { return "啤酒" }
    else if pct < 18.0 { return "红/白葡萄酒" }
    else if pct < 30.0 { return "清酒/烧酒" }
    else { return "烈酒/洋酒" }
}
