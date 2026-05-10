import SwiftUI
import UIKit
import CoreData
import Photos

@MainActor
class PosterRenderer {
    static let shared = PosterRenderer()
    
    private var activeSaver: ImageSaver?
    
    enum PosterSaveError: Error {
        case permissionDenied
        case unknown
        
        var localizedDescription: String {
            switch self {
            case .permissionDenied: return "Permission Denied"
            case .unknown: return "Unknown Saving Error"
            }
        }
    }
    
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
    
    /// Returns rendered UIImages for a past session
    /// Note: Obsoleted by granular methods but kept for compatibility
    func createHistoricalPosterImages(session: DrinkSession, brain: AlcoholBrain, userSettings: UserSettings) -> [UIImage] {
        var images: [UIImage] = []
        if let s = renderHistoricalSessionPoster(session: session, brain: brain, userSettings: userSettings) { images.append(s) }
        
        let calendar = Calendar.current
        let year = calendar.component(.year, from: session.startTime ?? Date())
        if let h = renderAnnualHeatmapPoster(targetYear: year) { images.append(h) }
        
        return images
    }

    /// 2b. MEDIUM: Render a summary report for a HISTORICAL session
    func renderHistoricalSessionPoster(session: DrinkSession, brain: AlcoholBrain, userSettings: UserSettings) -> UIImage? {
        let data = prepareData(from: session, brain: brain, userSettings: userSettings)
        let posterView = SharePosterView(sessionData: data, userSettings: userSettings)
            .environment(\.colorScheme, .dark)
        
        let renderer = ImageRenderer(content: posterView)
        renderer.scale = 2.0
        return renderer.uiImage
    }
    
    /// Returns rendered UIImages [Moment, Live Session, Heatmap] for preview
    /// Note: Obsoleted by granular methods but kept for compatibility if needed.
    func createLivePosterImages(brain: AlcoholBrain, userSettings: UserSettings) -> [UIImage] {
        var images: [UIImage] = []
        if let m = renderMomentPoster(brain: brain, userSettings: userSettings) { images.append(m) }
        if let s = renderSessionSummaryPoster(brain: brain, userSettings: userSettings) { images.append(s) }
        if let h = renderAnnualHeatmapPoster(targetYear: nil) { images.append(h) }
        return images
    }

    /// 1. FAST: Render the immediate BAC Moment Snapshot
    func renderMomentPoster(brain: AlcoholBrain, userSettings: UserSettings) -> UIImage? {
        let persona = userSettings.selectedPersona
        let momentData = BACMomentData(
            timestamp: Date(),
            bacValue: brain.bacPercentage,
            stateZh: brain.currentStateNameZh,
            stateEn: brain.currentStateNameEn,
            quoteZh: brain.currentQuote.quote,
            quoteEn: brain.currentQuote.translation,
            personaName: persona.rawValue,
            personaZhName: persona.zhName,
            personaAvatarImage: persona.avatarImageName
        )
        let momentView = BACMomentPosterView(data: momentData)
            .environment(\.colorScheme, .dark)
        
        let renderer = ImageRenderer(content: momentView)
        renderer.scale = 2.0
        return renderer.uiImage
    }

    /// 2. MEDIUM: Render the session summary report
    func renderSessionSummaryPoster(brain: AlcoholBrain, userSettings: UserSettings) -> UIImage? {
        let drinks = brain.drinks
        guard !drinks.isEmpty else { return nil }
        
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
        return renderer.uiImage
    }

    /// 3. SLOW: Render the heavy annual heatmap
    func renderAnnualHeatmapPoster(targetYear: Int? = nil) -> UIImage? {
        let heatmapData = createHeatmapData(targetYear: targetYear)
        let heatmapView = HeatmapPosterView(data: heatmapData)
            .environment(\.colorScheme, .dark)
            
        let renderer = ImageRenderer(content: heatmapView)
        renderer.scale = 2.0
        return renderer.uiImage
    }
    
    /// Helper to save image to photo library with permission check and guidance
    func saveImageToPhotos(_ image: UIImage, completion: @escaping (Bool, PosterSaveError?) -> Void) {
        checkPhotoLibraryPermission { [weak self] authorized in
            guard let self = self else { return }
            
            if authorized {
                // Proceed with saving
                let saver = ImageSaver { [weak self] success, error in
                    completion(success, error != nil ? .unknown : nil)
                    self?.activeSaver = nil
                }
                self.activeSaver = saver
                UIImageWriteToSavedPhotosAlbum(image, saver, #selector(ImageSaver.didFinishSavingWithError), nil)
            } else {
                // Show guidance alert
                self.showPermissionAlert()
                completion(false, .permissionDenied)
            }
        }
    }
    
    /// Checks photo library authorization status specifically for adding photos
    private func checkPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        
        switch status {
        case .authorized, .limited:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { newStatus in
                DispatchQueue.main.async {
                    completion(newStatus == .authorized || newStatus == .limited)
                }
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    /// Public method to check and guide at App Startup
    func checkAndRequestStartupPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        
        if status == .notDetermined {
            // Silently trigger the system prompt for new users
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { _ in }
        } else if status == .denied || status == .restricted {
            // Show the guidance alert for those who denied it before
            // We dispatch slightly to avoid UI presentation conflicts during startup
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.showPermissionAlert()
            }
        }
    }
    
    /// Presents a dual-language alert to guide the user to Settings
    private func showPermissionAlert() {
        guard let topVC = getTopViewController() else { return }
        
        let alert = UIAlertController(
            title: "需要相册权限\nPhoto Access Required",
            message: "请在系统设置中允许《微醺志》访问相册，以便保存你的精彩时刻。\nPlease enable photo access in Settings to save your moments.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "取消 / Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "去设置 / Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        
        topVC.present(alert, animated: true)
    }

    /// Robust helper to find the currently visible view controller
    func getTopViewController(base: UIViewController? = nil) -> UIViewController? {
        let base = base ?? UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?.rootViewController
        
        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)
        } else if let tab = base as? UITabBarController {
            return getTopViewController(base: tab.selectedViewController)
        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
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
        
        let stateRange = QuotesDB.shared.getStateRange(for: peakBAC, in: userSettings.selectedCountry, isSoberingDown: false, persona: userSettings.selectedPersona)
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
