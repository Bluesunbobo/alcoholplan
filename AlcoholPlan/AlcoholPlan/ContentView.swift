import SwiftUI
import CoreData
import Charts

import UIKit

// MARK: - Color Extensions (Stitch Midnight Tavern Theme)
extension Color {
    static let surfaceDim = Color(hex: "#161310")
    static let surfaceContainerLowest = Color(hex: "#1a1714")
    static let surfaceContainerLow = Color(hex: "#1e1b18")
    static let surfaceContainer = Color(hex: "#231f1c")
    static let surfaceContainerHighest = Color(hex: "#383431")
    static let primary = Color(hex: "#ffb960")
    static let primaryContainer = Color(hex: "#c8862a")
    static let tertiary = Color(hex: "#ffb3b4")
    static let error = Color(hex: "#ffb4ab")
    
    static let warning = Color(hex: "#BA7517")
    static let surface = Color(hex: "#161310")
    
    static let onSurface = Color(hex: "#e9e1dc")
    static let onSurfaceVariant = Color(hex: "#d6c3b1")
    static let onPrimary = Color(hex: "#472a00")
    
    // Druk Cinematic Palette
    static let ivoryWarm  = Color(red: 0.97, green: 0.93, blue: 0.85)
    static let amberGold  = Color(red: 0.85, green: 0.65, blue: 0.30)
    static let silverGray = Color(red: 0.80, green: 0.80, blue: 0.82)
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct GlassCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.surfaceContainerHighest.opacity(0.4))
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.05), lineWidth: 1))
    }
}

extension View {
    func glassCard() -> some View {
        modifier(GlassCardModifier())
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Main App Structure
struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var brain: AlcoholBrain
    @StateObject var userSettings: UserSettings
    @State private var selectedTab = 0
    
    init() {
        let settings = UserSettings()
        _userSettings = StateObject(wrappedValue: settings)
        _brain = StateObject(wrappedValue: AlcoholBrain(
            defaultWeight: settings.defaultWeight,
            defaultGender: settings.defaultGender,
            defaultCountry: settings.selectedCountry,
            defaultRate: settings.selectedMetabolicRate,
            defaultPersona: settings.selectedPersona
        ))
    }

    var body: some View {
        Group {
            if !userSettings.hasCompletedOnboarding {
                InitialSetupView(userSettings: userSettings, brain: brain)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else if !userSettings.hasSeenCinematicIntro {
                CinematicIntroView(userSettings: userSettings)
                    .transition(.opacity)
            } else {
                TabView(selection: $selectedTab) {
                    DashboardView(brain: brain, userSettings: userSettings, selectedTab: $selectedTab)
                        .tabItem {
                            Label("LEDGER 记录", systemImage: "wineglass")
                        }
                        .tag(0)
                    
                    CurveView(brain: brain, userSettings: userSettings)
                        .tabItem {
                            Label("CURVE 曲线", systemImage: "waveform.path.ecg")
                        }
                        .tag(1)
                    
                    HistoryView(brain: brain, userSettings: userSettings)
                        .tabItem {
                            Label("HISTORY 历史", systemImage: "doc.text.fill")
                        }
                        .tag(2)
                    
                    SettingsView(userSettings: userSettings, brain: brain)
                        .tabItem {
                            Label("PROFILE 设定", systemImage: "person.fill")
                        }
                        .tag(3)
                }
                .preferredColorScheme(.dark)
                .tint(.primary)
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.8), value: userSettings.hasCompletedOnboarding)
        .animation(.easeInOut(duration: 1.0), value: userSettings.hasSeenCinematicIntro)
        .onAppear {
            setupTabBarAppearance()
        }
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor(Color.surfaceDim.opacity(0.8))
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().unselectedItemTintColor = UIColor(Color.onSurface.opacity(0.4))
    }
}

struct BilingualTabLabel: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
            Text(title)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .tracking(1.0)
                .textCase(.uppercase)
            Text(subtitle)
                .font(.system(size: 9, design: .monospaced))
        }
    }
}

// MARK: - Dashboard View (Tavern UI)
struct DashboardView: View {
    @ObservedObject var brain: AlcoholBrain
    @ObservedObject var userSettings: UserSettings
    @State private var showSettings = false
    @FocusState private var isBACFocused: Bool
    @State private var showingPreview = false
    @State private var previewImages: [UIImage] = []
    @State private var showingShareOptions = false
    @State private var showingHistorySelection = false
    @Binding var selectedTab: Int
    
    var body: some View {
        ZStack {
            Color.surfaceDim.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 32) {
                    Group {
                        dashboardHeader
                        currentPersonaDisplay
                        bacDisplayCard
                        quoteCard
                        inputCard
                        SettingsJurisdictionSection(userSettings: userSettings, brain: brain)
                        bentoStatsGrid
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 120)
                .onTapGesture {
                    hideKeyboard()
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(userSettings: UserSettings(), brain: brain)
        }
        .sheet(isPresented: $showingPreview) {
            if !previewImages.isEmpty {
                PosterPreviewSheet(images: previewImages)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
        .confirmationDialog("SHARE POSTER / 分享海报", isPresented: $showingShareOptions, titleVisibility: .visible) {
            Button("分享当前场次 / CURRENT SESSION") {
                generateLivePoster()
            }
            Button("从历史中选择 / FROM HISTORY") {
                selectedTab = 2 // Switch to History Tab
            }
            Button("取消 / CANCEL", role: .cancel) { }
        }
        .confirmationDialog("GO TO HISTORY / 前往历史", isPresented: $showingHistorySelection, titleVisibility: .visible) {
            Button("前往历史场次 / VIEW HISTORY") {
                selectedTab = 2
            }
            Button("取消 / CANCEL", role: .cancel) { }
        } message: {
            Text("当前暂无进行中的记录。您可以前往历史页面分享过去的场次。\nNo active records. You can share past sessions from the History tab.")
        }
    }
    
    private func generateLivePoster() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            let imgs = PosterRenderer.shared.createLivePosterImages(brain: brain, userSettings: userSettings)
            if !imgs.isEmpty {
                self.previewImages = imgs
                self.showingPreview = true
            }
        }
    }
    
    // MARK: Header Components
    private var dashboardHeader: some View {
        HStack(alignment: .bottom) {
            HStack(alignment: .bottom, spacing: 12) {
                // Character Avatar in Header
                Image(userSettings.selectedPersona.avatarImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.primary.opacity(0.2), lineWidth: 1))
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Druk")
                        .font(.system(size: 24, weight: .bold, design: .serif).italic())
                        .foregroundColor(.primary)
                    
                    Text(userSettings.selectedPersona.zhName)
                        .font(.system(size: 10, design: .monospaced))
                        .tracking(1.5)
                        .foregroundColor(.onSurface.opacity(0.6))
                }
            }
            
            Spacer()
            
            Button(action: { 
                if brain.drinks.isEmpty {
                    self.showingHistorySelection = true
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } else {
                    self.showingShareOptions = true
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                    Text("SHARE / 分享")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.primary.opacity(brain.drinks.isEmpty ? 0.05 : 0.1))
                .foregroundColor(.primary.opacity(brain.drinks.isEmpty ? 0.4 : 1.0))
                .clipShape(Capsule())
            }
        }
        .padding(.top, 16)
    }
    
    // MARK: Current Persona Display (Non-interactive)
    private var currentPersonaDisplay: some View {
        HStack {
            Spacer()
            HStack(spacing: 8) {
                Text("CURRENT PERSONA: \(userSettings.selectedPersona.rawValue.uppercased())")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .tracking(1.5)
                Text("/ 当前人格: \(userSettings.selectedPersona.zhName)")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
            }
            .foregroundColor(.onSurface.opacity(0.5))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.surfaceContainerHighest.opacity(0.3))
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.05), lineWidth: 1)
                    )
            )
            Spacer()
        }
        .padding(.top, 8)
    }
    
    // MARK: BAC Display Card (Redesigned per reference design)
    private var bacDisplayCard: some View {
        VStack(spacing: 20) {
                // Context Annotation
                if brain.bacPercentage > 0 || brain.isSimulating {
                    HStack(spacing: 6) {
                        Text(brain.isSimulating ? "摄入后预估" : "当前实时估算")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(brain.isSimulating ? .warning : .primary)
                        Text(brain.isSimulating ? "/ PREDICTIVE" : "/ REAL-TIME")
                            .font(.system(size: 11, design: .monospaced))
                            .opacity(0.6)
                    }
                    .foregroundColor(brain.isSimulating ? .warning : .primary.opacity(0.4))
                    .tracking(1.5)
                }
                
                // Large BAC Value
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    TextField("0.000", text: Binding(
                        get: { formatBACForDisplay(brain.displayBACString) },
                        set: { newValue in
                            let filtered = filterBACInput(newValue)
                            brain.displayBACString = filtered
                        }
                    ))
                    .font(.system(size: 72, weight: .bold, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                    .focused($isBACFocused)
                    .keyboardType(.decimalPad)
                    .foregroundColor(.primary)
                    .onChange(of: isBACFocused) { focused in
                        brain.isInputFocused = focused
                        if !focused {
                            brain.applyTargetBACFromInput()
                        }
                    }
                    
                    Text("%")
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary.opacity(0.8))
                }
                .frame(maxWidth: .infinity)
                
                // Status Name
                HStack(spacing: 8) {
                    Text(brain.currentStateNameZh)
                        .font(.system(size: 18, weight: .medium, design: .serif))
                        .foregroundColor(.primary)
                    Text(brain.currentStateNameEn)
                        .font(.system(size: 16, weight: .regular, design: .serif).italic())
                        .foregroundColor(.primary.opacity(0.85))
                }
                
                // Separator
                Rectangle()
                    .fill(Color.primary.opacity(0.15))
                    .frame(width: 60, height: 1)
                    .padding(.vertical, 4)
                
                // Quote
                Text("\u{201C}\(brain.currentQuote.quote)\u{201D}")
                    .font(.system(size: 16, weight: .regular, design: .serif).italic())
                    .foregroundColor(.onSurface.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                
                Text("\"\(brain.currentQuote.translation)\"")
                    .font(.system(size: 12, weight: .regular, design: .serif).italic())
                    .foregroundColor(.onSurfaceVariant.opacity(0.45))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .textCase(.uppercase)
                
                // Predict Volume Button
                HStack {
                    Spacer()
                    Button(action: {
                        isBACFocused = false
                        brain.applyTargetBACFromInput()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "function")
                                .font(.system(size: 11, weight: .semibold))
                            Text("PREDICT VOLUME")
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            Text("/")
                                .font(.system(size: 10))
                                .opacity(0.6)
                            Text("预测饮酒量")
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        }
                        .tracking(1.0)
                        .foregroundColor(.surfaceDim)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(Color.primary)
                        )
                    }
                    Spacer()
                }
            }
            .padding(.vertical, 40)
            .padding(.horizontal, 24)
        .animation(.easeInOut(duration: 0.8), value: brain.currentAvatarImage)
        .padding(.horizontal, 28)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.surfaceContainerLow)
                
                // Warm amber radial glow behind BAC number
                RadialGradient(
                    colors: [
                        Color.primary.opacity(0.12 * min(1.0, brain.bacPercentage * 10)),
                        Color.clear
                    ],
                    center: .top,
                    startRadius: 20,
                    endRadius: 250
                )
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            }
        )
    }
    
    // MARK: BAC Input Helpers
    private func formatBACForDisplay(_ value: String) -> String {
        // Ensure 3 decimal places for display
        if let doubleValue = Double(value) {
            return String(format: "%.3f", doubleValue)
        }
        return value
    }
    
    private func filterBACInput(_ input: String) -> String {
        // Only allow digits and single decimal point
        var result = ""
        var hasDecimal = false
        var decimalCount = 0
        
        for char in input {
            if char.isNumber {
                if hasDecimal {
                    if decimalCount < 3 {
                        result.append(char)
                        decimalCount += 1
                    }
                } else {
                    // Limit integer part to 3 digits
                    if result.count < 3 {
                        result.append(char)
                    }
                }
            } else if char == "." && !hasDecimal {
                hasDecimal = true
                result.append(char)
            }
        }
        
        return result
    }
    
    // MARK: Add Drink Header
    private var quoteCard: some View {
        HStack {
            Text("Add Drink ")
                .font(.system(size: 18, weight: .semibold, design: .serif).italic())
            Text("/ 记录饮酒")
                .font(.system(size: 14, weight: .regular, design: .serif).italic())
                .foregroundColor(.onSurface.opacity(0.6))
            Spacer()
        }
        .padding(.top, 8)
    }
    
    // MARK: Input Card
    private var inputCard: some View {
        VStack(spacing: 28) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    drinkChip(emoji: "🍺", zh: "啤酒", en: "Beer", abv: 0.05)
                    drinkChip(emoji: "🍷", zh: "葡萄酒", en: "Wine", abv: 0.12)
                    drinkChip(emoji: "🥃", zh: "威士忌", en: "Whisky", abv: 0.40)
                    drinkChip(emoji: "🍶", zh: "白酒", en: "Baijiu", abv: 0.52)
                    drinkChip(emoji: "🍸", zh: "鸡尾酒", en: "Cocktail", abv: 0.12)
                    drinkChip(emoji: "🍶", zh: "米酒", en: "Rice Wine", abv: 0.05)
                    drinkChip(emoji: "🍵", zh: "黄酒", en: "Yellow Wine", abv: 0.15)
                    drinkChip(emoji: "🥂", zh: "香槟", en: "Champagne", abv: 0.11)
                }
                .padding(.horizontal, 4)
            }
            
            sliderHeader(titleEn: "Alcohol By Volume", titleZh: "酒精浓度 (ABV)", value: String(format: "%.1f %%", brain.pendingABV * 100))
                .foregroundColor(.primary.opacity(0.8))
            
            Slider(value: $brain.pendingABV, in: 0.01...0.70, step: 0.01, onEditingChanged: { editing in
                if !editing {
                    brain.commitSimulation()
                }
            })
                .tint(.primary)
            
            sliderHeader(titleEn: "Serving Amount", titleZh: "饮酒量", value: String(format: "%.0f ml", brain.pendingVolumeML))
                .foregroundColor(.primary.opacity(0.8))
            
            Slider(value: $brain.pendingVolumeML, in: 0...1000, step: 10, onEditingChanged: { editing in
                if !editing {
                    brain.commitSimulation()
                }
            })
                .tint(.primary)
            
            // MARK: Hangover Score Selector
            hangoverScoreSelector
            
            Button(action: {
                brain.logDrink()
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }) {
                HStack(spacing: 10) {
                    Text("CONFIRM POUR")
                    Text("确认摄入")
                }
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .tracking(2.0)
                .textCase(.uppercase)
                .foregroundColor(.surfaceDim)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color.primary)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .disabled(brain.pendingVolumeML <= 0)
            .opacity(brain.pendingVolumeML <= 0 ? 0.5 : 1.0)
        }
        .padding(24)
        .glassCard()
    }
    
    private func drinkChip(emoji: String, zh: String, en: String, abv: Double) -> some View {
        let isSelected = brain.pendingABV == abv
        
        return Button(action: { brain.pendingABV = abv }) {
            VStack(spacing: 6) {
                Text(emoji)
                    .font(.system(size: 28))
                Text(en)
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .tracking(1.0)
                    .textCase(.uppercase)
                    .foregroundColor(isSelected ? .primary : .onSurfaceVariant.opacity(0.6))
                Text(zh)
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(.onSurfaceVariant.opacity(0.4))
            }
            .frame(width: 88)
            .padding(.vertical, 12)
            .background(isSelected ? Color.primary.opacity(0.1) : Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(isSelected ? Color.primary : Color.white.opacity(0.05), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func sliderHeader(titleEn: String, titleZh: String, value: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(titleEn)
                    .font(.system(size: 11, design: .monospaced))
                    .tracking(2.0)
                    .textCase(.uppercase)
                    .foregroundColor(.onSurfaceVariant.opacity(0.6))
                Text(titleZh)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(.primary.opacity(0.9))
            }
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(.primary)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.2), value: value)
        }
    }
    
    // MARK: Hangover Score Selector
    private var hangoverScoreSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("HANGOVER FEELING")
                        .font(.system(size: 11, design: .monospaced))
                        .tracking(2.0)
                        .textCase(.uppercase)
                        .foregroundColor(.onSurfaceVariant.opacity(0.6))
                    Text("宿醉感")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(.primary.opacity(0.9))
                }
                Spacer()
                if brain.pendingHangoverScore > 0 {
                    Button(action: { brain.pendingHangoverScore = 0 }) {
                        Text("CLEAR 清除")
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundColor(.onSurfaceVariant.opacity(0.5))
                    }
                }
            }
            
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { score in
                    let isActive = Int16(score) <= brain.pendingHangoverScore
                    Button(action: {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                            brain.pendingHangoverScore = Int16(score)
                        }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }) {
                        VStack(spacing: 4) {
                            Text("🥴")
                                .font(.system(size: 24))
                                .opacity(isActive ? 1.0 : 0.2)
                                .grayscale(isActive ? 0 : 1.0)
                                .scaleEffect(isActive ? 1.1 : 1.0)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isActive ? Color.primary.opacity(0.1) : Color.clear)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(isActive ? Color.primary.opacity(0.3) : Color.white.opacity(0.05), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    // MARK: Bento Stats Grid
    private var bentoStatsGrid: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 32) {
                Image(systemName: "timelapse")
                    .font(.title2)
                    .foregroundColor(Color.primary.opacity(0.6))
                
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("EXPECTED SOBER")
                            .font(.system(size: 11, design: .monospaced))
                            .tracking(2.0)
                            .opacity(0.4)
                        Text("预计清醒")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(.primary.opacity(0.9))
                    }
                    
                    Text(brain.calculateMetabolicEnd())
                        .font(.system(size: 22, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(20)
            .glassCard()
            
            VStack(alignment: .leading, spacing: 32) {
                Image(systemName: "drop.fill")
                    .font(.title2)
                    .foregroundColor(Color.primary.opacity(0.6))
                
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("SESSION TOTAL")
                            .font(.system(size: 11, design: .monospaced))
                            .tracking(2.0)
                            .opacity(0.4)
                        Text("总计摄入")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(.primary.opacity(0.9))
                    }
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(Int(brain.totalLiquidVolumeML))")
                            .font(.system(size: 26, weight: .bold, design: .monospaced))
                            .foregroundColor(.primary)
                            .contentTransition(.numericText())
                        Text("ml")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.primary)
                        Text("本次摄入 / TOTAL INTAKE")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.onSurface.opacity(0.6))
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(20)
            .glassCard()
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - Curve View (Enhanced per Stitch Design)
struct CurveView: View {
    @ObservedObject var brain: AlcoholBrain
    @ObservedObject var userSettings: UserSettings
    
    var body: some View {
        ZStack {
            Color.surfaceDim.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 32) {
                    Group {
                        curveHeader
                        estimatedBACStatusCard
                        enhancedCurveChart
                        soberingTimeSection
                        legalSafetySection
                        statsBentoGrid
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 120)
            }
        }
    }
    
    private var curveHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .bottom) {
                Text("清醒曲线 ")
                    .font(.system(size: 32, weight: .semibold, design: .serif).italic())
                Text("/ The Sobriety Curve")
                    .font(.system(size: 24, weight: .regular, design: .serif).italic())
                    .foregroundColor(.onSurface.opacity(0.6))
                
                Spacer()
            }
            Text("实时血液酒精估算与代谢恢复预测 / Real-time blood alcohol estimation and metabolic recovery projection.")
                .font(.system(size: 18, weight: .regular, design: .serif).italic())
                .foregroundColor(.primary.opacity(0.85))
                .lineSpacing(4)
        }
        .padding(.top, 16)
    }
    
    private var estimatedBACStatusCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("预计 BAC / ESTIMATED BAC")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary.opacity(0.9))
                    Text("系统状态 / STATUS")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.primary.opacity(0.6))
                }
                
                Spacer()
                
                Text(brain.isSoberingDown ? "代谢中 | Metabolizing" : "吸收中 | Absorbing")
                    .font(.system(size: 12, design: .monospaced))
                    .tracking(1.0)
                    .foregroundColor(.primary.opacity(0.8))
            }
            
            HStack(alignment: .firstTextBaseline, spacing: -4) {
                Text(String(format: "%.3f", brain.bacPercentage))
                    .font(.system(size: 56, weight: .bold, design: .monospaced))
                    .tracking(-2.0)
                    .foregroundColor(.primary)
                Text("%")
                    .font(.system(size: 40, weight: .bold, design: .monospaced))
                    .foregroundColor(.primary.opacity(0.6))
            }
        }
        .padding(24)
        .glassCard()
    }
    
    private var enhancedCurveChart: some View {
        EnhancedCurveChartCard(brain: brain)
    }
    
    private var soberingTimeSection: some View {
        VStack(spacing: 12) {
            Text("预计清醒时间 / ESTIMATED SOBRIETY IN")
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .tracking(2.0)
                .textCase(.uppercase)
                .foregroundColor(.primary.opacity(0.9))
            
            if brain.bacPercentage > 0 {
                Text(soberingTimeText)
                    .font(.system(size: 28, weight: .bold, design: .serif).italic())
                    .foregroundColor(.onSurface)
            } else {
                Text("--:-- / Already Sober")
                    .font(.system(size: 28, weight: .bold, design: .serif).italic())
                    .foregroundColor(.onSurface.opacity(0.4))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
    
    private var soberingTimeText: String {
        guard let soberDate = brain.soberDate else { return "--:-- / Already Sober" }
        let remainingHours = max(0, soberDate.timeIntervalSince(Date()) / 3600.0)
        let hoursInt = Int(remainingHours) 
        
        if hoursInt <= 1 {
            return "1-2 小时后 / Hours Later"
        } else if hoursInt <= 4 {
            return "\(hoursInt)-\(hoursInt + 2) 小时后 / Hours Later"
        } else {
            return "\(max(1, hoursInt - 1))-\(hoursInt + 1) 小时后 / Hours Later"
        }
    }
    
    private var legalSafetySection: some View {
        HStack(spacing: 16) {
            Image(systemName: "shield.checkered")
                .font(.title3)
                .foregroundColor(Color.primary.opacity(0.6))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("距离法定安全 / DISTANCE TO SAFETY")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .tracking(2.0)
                    .textCase(.uppercase)
                    .foregroundColor(.primary.opacity(0.9))
                
                if brain.bacPercentage > brain.country.duiLimit {
                    let timeToLegal = (brain.bacPercentage - brain.country.duiLimit) / brain.metabolicRate.value
                    let hours = Int(timeToLegal)
                    let minutes = Int((timeToLegal - Double(hours)) * 60)
                    Text("\(hours)h \(minutes)m")
                        .font(.system(size: 18, weight: .semibold, design: .monospaced))
                        .foregroundColor(.warning)
                } else {
                    Text("已达标 / Safe")
                        .font(.system(size: 18, weight: .semibold, design: .monospaced))
                        .foregroundColor(.onSurface.opacity(0.6))
                }
            }
            
            Spacer()
        }
        .padding(20)
        .glassCard()
    }
    
    private var statsBentoGrid: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 32) {
                Image(systemName: "drop.fill")
                    .font(.title2)
                    .foregroundColor(Color.primary.opacity(0.6))
                
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("总摄入 / TOTAL INTAKE")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .tracking(2.0)
                            .foregroundColor(.primary.opacity(0.9))
                    }
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(Int(brain.totalLiquidVolumeML))")
                            .font(.system(size: 24, design: .monospaced))
                            .foregroundColor(.onSurface)
                            .contentTransition(.numericText())
                        Text("ml")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.onSurface.opacity(0.6))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .glassCard()
            
            VStack(alignment: .leading, spacing: 32) {
                Image(systemName: "waveform.path.ecg")
                    .font(.title2)
                    .foregroundColor(Color.primary.opacity(0.6))
                
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("峰值强度 / PEAK INTENSITY")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .tracking(2.0)
                            .foregroundColor(.primary.opacity(0.9))
                    }
                    
                    if let session = brain.activeSession,
                       let startTime = session.startTime {
                        Text(startTime.formatted(date: .omitted, time: .shortened))
                            .font(.system(size: 18, design: .monospaced))
                            .foregroundColor(.onSurface)
                    } else {
                        Text("--:--")
                            .font(.system(size: 18, design: .monospaced))
                            .foregroundColor(.onSurface.opacity(0.4))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .glassCard()
        }
    }
}

// MARK: - Enhanced Chart Component
struct EnhancedCurveChartCard: View {
    @ObservedObject var brain: AlcoholBrain
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            chartHeader
            chartContent
            chartFooter
        }
        .padding(24)
        .glassCard()
    }
    
    private var chartHeader: some View {
        Text("BAC TIMELINE / 浓度变化轴")
            .font(.system(size: 13, weight: .bold, design: .monospaced))
            .tracking(2.0)
            .foregroundColor(.primary.opacity(0.9))
    }
    
    @ViewBuilder
    private var chartContent: some View {
        let data = brain.getTrajectoryPoints()
        if data.isEmpty {
            VStack(spacing: 16) {
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 48))
                    .foregroundColor(.primary.opacity(0.2))
                Text("No data available / 无可用数据")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.onSurfaceVariant)
            }
            .frame(height: 250)
        } else {
            Chart {
                ForEach(data, id: \.time) { dp in
                    LineMark(
                        x: .value("Time", dp.time),
                        y: .value("BAC", dp.bac)
                    )
                    .interpolationMethod(.monotone)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.primary, .primaryContainer],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .lineStyle(StrokeStyle(lineWidth: 2.5))
                    
                    AreaMark(
                        x: .value("Time", dp.time),
                        y: .value("BAC", dp.bac)
                    )
                    .interpolationMethod(.monotone)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color.primary.opacity(0.3),
                                Color.primary.opacity(0.1),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .opacity(dp.isPredicted ? 0.5 : 1.0)
                }
                
                RuleMark(x: .value("Now", Date()))
                    .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                    .foregroundStyle(Color.white.opacity(0.6))
                    .annotation(position: .top) {
                        VStack(spacing: 2) {
                            Text("NOW")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                            Circle()
                                .fill(Color.white)
                                .frame(width: 6, height: 6)
                                .shadow(color: .white.opacity(0.5), radius: 4)
                        }
                    }
                
                RuleMark(y: .value("Golden Point", 0.05))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [6, 4]))
                    .foregroundStyle(Color.primary.opacity(0.4))
                    .annotation(position: .top, alignment: .trailing) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 8))
                                .foregroundColor(.primary.opacity(0.6))
                            Text("0.05% 哲学黄金点 / PHILOSOPHICAL POINT")
                                .font(.system(size: 11, weight: .bold, design: .serif).italic())
                                .foregroundColor(.primary)
                        }
                        .padding(.trailing, 4)
                        .padding(.bottom, 2)
                    }
                
                RuleMark(y: .value("DUI", brain.country.duiLimit))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .foregroundStyle(Color.warning.opacity(0.5))
                    .annotation(position: .top, alignment: .trailing) {
                        HStack(spacing: 6) {
                            Text("\(brain.country.flag) \(brain.country.name) DUI")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                            Text(String(format: "%.3f%%", brain.country.duiLimit))
                                .font(.system(size: 11, design: .monospaced))
                        }
                        .foregroundColor(.warning.opacity(0.8))
                        .padding(.trailing, 4)
                        .padding(.bottom, 2)
                    }
                
                if let dwiLimit = brain.country.dwiLimit {
                    RuleMark(y: .value("DWI", dwiLimit))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [2, 2]))
                        .foregroundStyle(Color.error.opacity(0.5))
                        .annotation(position: .top, alignment: .trailing) {
                            HStack(spacing: 6) {
                                Text("\(brain.country.name) DWI")
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                Text(String(format: "%.3f%%", dwiLimit))
                                    .font(.system(size: 11, design: .monospaced))
                            }
                            .foregroundColor(.error.opacity(0.8))
                            .padding(.trailing, 4)
                            .padding(.bottom, 2)
                        }
                }
            }
            .chartXAxis {
                AxisMarks(preset: .aligned, position: .bottom, values: .automatic(desiredCount: 5)) { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [4])).foregroundStyle(Color.onSurface.opacity(0.08))
                    AxisValueLabel(format: .dateTime.hour().minute(), centered: true)
                        .foregroundStyle(Color.onSurface)
                        .font(.system(size: 11, design: .monospaced))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 6)) { value in
                    AxisGridLine().foregroundStyle(Color.onSurface.opacity(0.05))
                    AxisValueLabel {
                        if let val = value.as(Double.self) {
                            Text(String(format: "%.2f", val))
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundStyle(Color.onSurface)
                        }
                    }
                }
            }
            .frame(height: 280)
            .animation(.easeInOut(duration: 0.5), value: brain.bacPercentage)
        }
    }
    
    @ViewBuilder
    private var chartFooter: some View {
        let data = brain.getTrajectoryPoints()
        if !data.isEmpty {
            VStack(spacing: 12) {
                HStack {
                    Text("00:00")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.onSurfaceVariant.opacity(0.6))
                    
                    Spacer()
                    
                    Text("当前 / NOW")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .tracking(1.0)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if let lastTime = data.last?.time {
                        Text(lastTime.formatted(date: .omitted, time: .shortened))
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.onSurfaceVariant.opacity(0.4))
                    } else {
                        Text("00:00")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.onSurfaceVariant.opacity(0.4))
                    }
                }
            }
        }
    }
}

// MARK: - History View
struct HistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var brain: AlcoholBrain
    @ObservedObject var userSettings: UserSettings
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \DrinkSession.startTime, ascending: false)],
        animation: .default
    ) private var sessions: FetchedResults<DrinkSession>
    @State private var showingPreview = false
    @State private var previewImages: [UIImage] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.surfaceDim.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 32) {
                        historyHeader
                        HistoryHeatMapGrid(sessions: sessions)
                        
                        if sessions.isEmpty {
                            emptyStateView
                        } else {
                            HistoryTimelineView(sessions: sessions, brain: brain, userSettings: userSettings, onDelete: { session in
                                deleteSession(session)
                            }, onShare: { session in
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                    let imgs = PosterRenderer.shared.createHistoricalPosterImages(session: session, brain: brain, userSettings: userSettings)
                                    if !imgs.isEmpty {
                                        self.previewImages = imgs
                                        self.showingPreview = true
                                    }
                                }
                            })
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 120)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingPreview) {
                if !previewImages.isEmpty {
                    PosterPreviewSheet(images: previewImages)
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                }
            }
        }
    }
    
    private var historyHeader: some View {
        HStack(alignment: .bottom) {
            Text("Past Encounters")
                .font(.system(size: 18, weight: .regular, design: .serif).italic())
                .foregroundColor(.onSurfaceVariant.opacity(0.6))
        }
        .padding(.top, 16)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 48))
                .foregroundColor(.primary.opacity(0.3))
            Text("暂无回忆 / No nights recorded.")
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(.onSurfaceVariant)
            Text("开始记录你的第一杯酒吧 / Start logging your first drink")
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.onSurfaceVariant.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 100)
    }
    
    private func deleteSession(_ session: DrinkSession) {
        withAnimation(.easeInOut(duration: 0.3)) {
            brain.deleteSession(session)
        }
    }
}

struct SettingsHeaderView: View {
    var body: some View {
        HStack(alignment: .bottom) {
            Text("Settings ")
                .font(.system(size: 24, weight: .semibold, design: .serif).italic())
            Text(" / 设定")
                .font(.system(size: 18, weight: .regular, design: .serif).italic())
                .foregroundColor(.onSurface.opacity(0.6))
            Spacer()
        }
        .padding(.top, 16)
    }
}

struct HistoryHeatMapGrid: View {
    var sessions: FetchedResults<DrinkSession>
    
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    
    private var dailyAlcoholData: [Date: Double] {
        var data = [Date: Double]()
        let calendar = Calendar.current
        
        for session in sessions {
            guard let startTime = session.startTime else { continue }
            if calendar.component(.year, from: startTime) == selectedYear {
                let date = calendar.startOfDay(for: startTime)
                
                let existingValue = data[date] ?? 0
                data[date] = existingValue + session.totalAlcoholGrams
            }
        }
        
        return data
    }
    
    private func getIntensityLevel(for grams: Double) -> Int {
        if grams <= 0 { return 0 }
        if grams < 20 { return 1 }
        if grams < 50 { return 2 }
        if grams < 100 { return 3 }
        return 4
    }
    
    private func getColor(for level: Int) -> Color {
        switch level {
        case 0:
            return Color.primary.opacity(0.05)
        case 1:
            return Color.primary.opacity(0.25)
        case 2:
            return Color.primary.opacity(0.5)
        case 3:
            return Color.primary.opacity(0.75)
        default:
            return Color.primary.opacity(1.0)
        }
    }
    
    private var yearDates: [Date] {
        let calendar = Calendar.current
        let startOfYear = calendar.date(from: DateComponents(year: selectedYear, month: 1, day: 1))!
        var dates = [Date]()
        
        var currentDate = startOfYear
        while calendar.component(.year, from: currentDate) == selectedYear {
            dates.append(currentDate)
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDay
        }
        
        return dates
    }
    
    private var sessionCountForYear: Int {
        let calendar = Calendar.current
        return sessions.filter { session in
            if let start = session.startTime {
                return calendar.component(.year, from: start) == selectedYear
            }
            return false
        }.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .bottom) {
                HStack(spacing: 8) {
                    Button(action: { selectedYear -= 1 }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    Text("\(selectedYear) 饮酒频率 / VINTAGE FREQUENCY")
                        .font(.system(size: 10, design: .monospaced))
                        .tracking(2.0)
                        .foregroundColor(.onSurfaceVariant.opacity(0.6))
                    Button(action: { selectedYear += 1 }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(selectedYear < Calendar.current.component(.year, from: Date()) ? .primary : .onSurfaceVariant.opacity(0.3))
                    }
                    .disabled(selectedYear >= Calendar.current.component(.year, from: Date()))
                }
                Spacer()
                Text("\(sessionCountForYear) 场次 / SESSIONS")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.primary)
            }
            
            let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 26)
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(0..<yearDates.count, id: \.self) { index in
                    let date = yearDates[index]
                    let alcoholGrams = dailyAlcoholData[date] ?? 0
                    let intensityLevel = getIntensityLevel(for: alcoholGrams)
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(getColor(for: intensityLevel))
                        .aspectRatio(1, contentMode: .fill)
                        .help("\(date.formatted(date: .abbreviated, time: .omitted)): \(String(format: "%.1f", alcoholGrams))g")
                }
            }
            
            HStack {
                Spacer()
                Text("轻微 / LIGHT")
                    .font(.system(size: 8, design: .monospaced))
                    .foregroundColor(.onSurfaceVariant.opacity(0.4))
                HStack(spacing: 4) {
                    ForEach(0..<5, id: \.self) { level in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(getColor(for: level))
                            .frame(width: 8, height: 8)
                    }
                }
                Text("酣畅 / HEAVY")
                    .font(.system(size: 8, design: .monospaced))
                    .foregroundColor(.onSurfaceVariant.opacity(0.4))
            }
        }
        .padding(24)
        .glassCard()
    }
}

struct HistoryTimelineView: View {
    var sessions: FetchedResults<DrinkSession>
    @ObservedObject var brain: AlcoholBrain
    @ObservedObject var userSettings: UserSettings
    var onDelete: (DrinkSession) -> Void
    var onShare: (DrinkSession) -> Void
    
    var body: some View {
        let sessionsArray = Array(sessions)
        return VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(sessionsArray.enumerated()), id: \.element.objectID) { index, session in
                HStack(alignment: .top, spacing: 0) {
                    enhancedTimelineDot(isFirst: index == 0)
                    
                    VStack {
                        SwipeToDeleteCard(session: session, brain: brain, userSettings: userSettings, onDelete: {
                            onDelete(session)
                        }, onShare: {
                            onShare(session)
                        })
                        
                        if index < sessionsArray.count - 1 {
                            enhancedQuoteBlock(index: index)
                        }
                    }
                    .padding(.bottom, index == sessionsArray.count - 1 ? 0 : 16)
                }
            }
        }
    }
    
    private func enhancedTimelineDot(isFirst: Bool) -> some View {
        ZStack(alignment: .top) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.primary.opacity(0.5),
                            Color.primary.opacity(0.15),
                            Color.primary.opacity(0.02),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 1)
            
            Circle()
                .fill(isFirst ? Color.primary : Color.primary.opacity(0.4))
                .frame(width: isFirst ? 10 : 8, height: isFirst ? 10 : 8)
                .overlay(
                    Circle()
                        .stroke(Color.surfaceDim, lineWidth: 2)
                )
                .shadow(color: isFirst ? Color.primary.opacity(0.6) : .clear, radius: 6)
                .offset(y: 16)
        }
        .frame(width: 32)
    }
    
    private func enhancedQuoteBlock(index: Int) -> some View {
        let quoteIndex = index % max(1, QuotesDB.shared.neutralQuotes.count)
        let quote = QuotesDB.shared.neutralQuotes[quoteIndex]
        
        return VStack(spacing: 8) {
            Text("\"" + quote.quote + "\"")
                .font(.system(size: 16, weight: .regular, design: .serif).italic())
                .foregroundColor(.onSurfaceVariant.opacity(0.5))
            
            Text("\"" + quote.translation + "\"")
                .font(.system(size: 13, weight: .regular, design: .serif).italic())
                .foregroundColor(.onSurfaceVariant.opacity(0.3))
            
            Text("- Druk")
                .font(.system(size: 9, design: .monospaced))
                .tracking(0.3)
                .textCase(.uppercase)
                .opacity(0.25)
        }
        .multilineTextAlignment(.center)
        .padding(.vertical, 36)
        .padding(.horizontal, 16)
    }
}

struct SwipeToDeleteCard: View {
    let session: DrinkSession
    @ObservedObject var brain: AlcoholBrain
    @ObservedObject var userSettings: UserSettings
    let onDelete: () -> Void
    let onShare: () -> Void
    @State private var offset: CGFloat = 0
    @State private var showingDelete = false
    
    var body: some View {
        ZStack(alignment: .trailing) {
            // Delete confirmation button (revealed on swipe)
            if showingDelete {
                HStack(spacing: 0) {
                    Spacer()
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            offset = -UIScreen.main.bounds.width
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            onDelete()
                        }
                    }) {
                        VStack(spacing: 6) {
                            Image(systemName: "trash.fill")
                                .font(.system(size: 18))
                            Text("DELETE")
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .tracking(1.5)
                            Text("删除")
                                .font(.system(size: 8, design: .monospaced))
                        }
                        .foregroundColor(.white)
                        .frame(width: 80)
                        .frame(maxHeight: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.error.opacity(0.9))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            
            // Main card
            HistorySessionCard(session: session, brain: brain, userSettings: userSettings, onShare: onShare)
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if value.translation.width < 0 {
                                // Limit swipe to reveal delete button width
                                offset = max(value.translation.width, -90)
                            } else if showingDelete {
                                // Allow swiping back to dismiss
                                offset = min(value.translation.width - 90, 0)
                            }
                        }
                        .onEnded { value in
                            if value.translation.width < -50 {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                    offset = -90
                                    showingDelete = true
                                }
                            } else {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                    offset = 0
                                    showingDelete = false
                                }
                            }
                        }
                )
        }
        .onAppear {
            offset = 0
            showingDelete = false
        }
        .onChange(of: session.objectID) { _ in
            offset = 0
            showingDelete = false
        }
    }
}

struct HistorySessionCard: View {
    var session: DrinkSession
    @ObservedObject var brain: AlcoholBrain
    @ObservedObject var userSettings: UserSettings
    let onShare: () -> Void
    
    private var formattedDate: String {
        guard let date = session.startTime else { return "--" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date).uppercased()
    }
    
    private var occasionTag: String {
        session.occasionTag ?? "朋友聚会"
    }
    
    private var hangoverScore: Int16 {
        session.hangoverScore
    }
    
    private var sortedEntries: [DrinkEntry] {
        guard let entriesSet = session.entries as? Set<DrinkEntry> else { return [] }
        return entriesSet.sorted { ($0.timestamp ?? Date.distantPast) < ($1.timestamp ?? Date.distantPast) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    if session.startTime != nil {
                        Text(formattedDate)
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.primary.opacity(0.7))
                            .tracking(1.5)
                            .textCase(.uppercase)
                        
                        Text(occasionTag)
                            .font(.system(size: 10, design: .monospaced))
                            .tracking(1.2)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 3)
                            .background(Color.primary.opacity(0.12))
                            .clipShape(Capsule())
                    }
                }
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 8) {
                        Button(action: {
                            onShare()
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 14))
                                .foregroundColor(.primary.opacity(0.6))
                                .padding(8)
                                .background(Circle().fill(Color.primary.opacity(0.08)))
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Text(String(format: "%.3f%%", session.peakBAC))
                            .font(.system(size: 26, weight: .bold, design: .monospaced))
                            .foregroundColor(.primary)
                            .contentTransition(.numericText())
                    }
                    
                    Text("峰值 BAC / PEAK BAC")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(.onSurface.opacity(0.4))
                        .tracking(1.2)
                        .textCase(.uppercase)
                }
            }
            
            Divider().background(Color.white.opacity(0.08))
            
            drinkLogSection
            
            Divider().background(Color.white.opacity(0.08))
            
            enhancedHangoverRow
            
            if let location = session.location, !location.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.primary.opacity(0.4))
                    Text(location)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.onSurfaceVariant.opacity(0.6))
                        .lineLimit(1)
                }
                .padding(.top, 4)
            }
            
            if let note = session.note, !note.isEmpty {
                Text(note)
                    .font(.system(size: 11, design: .serif).italic())
                    .foregroundColor(.onSurfaceVariant.opacity(0.5))
                    .lineLimit(2)
                    .padding(.top, 4)
            }
        }
        .padding(20)
        .background(Color.surfaceContainerLow)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.05), lineWidth: 1))
    }
    
    private var enhancedHangoverRow: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: "face.dashed")
                    .font(.system(size: 11))
                    .foregroundColor(.onSurfaceVariant.opacity(0.6))
                Text("宿醉感 / Hangover")
                    .font(.system(size: 10, design: .monospaced))
                    .tracking(2.0)
                    .textCase(.uppercase)
                    .foregroundColor(.primary.opacity(0.7))
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                ForEach(1...5, id: \.self) { index in
                    let isActive = Int16(index) <= session.hangoverScore
                    
                    Button(action: {
                        updateHangoverScore(Int16(index))
                    }) {
                        Text("🥴")
                            .font(.system(size: 18))
                            .opacity(isActive ? 1.0 : 0.15)
                            .grayscale(isActive ? 0 : 1.0)
                            .scaleEffect(isActive ? 1.1 : 1.0)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                if session.hangoverScore == 0 {
                    Text("-")
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(.onSurfaceVariant.opacity(0.25))
                }
            }
        }
    }
    
    private func updateHangoverScore(_ score: Int16) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // If clicking the same score, maybe reset to 0? Or just stay.
        // Let's implement toggle behavior for the same score.
        let newScore = (session.hangoverScore == score) ? 0 : score
        
        session.hangoverScore = newScore
        
        do {
            try session.managedObjectContext?.save()
            // Optional: Notify if needed, but FetchRequest should pick it up automatically
        } catch {
            print("Failed to save hangover score: \(error)")
        }
    }
    
    private var drinkLogSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Drink Log / 饮酒明细")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .tracking(2.0)
                .textCase(.uppercase)
                .foregroundColor(.onSurface.opacity(0.4))
            
            if sortedEntries.isEmpty {
                Text("暂无详细数据 / No details")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.onSurface.opacity(0.2))
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(sortedEntries, id: \.self) { entry in
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(Int(entry.volumeML))ml")
                                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                                    .foregroundColor(.primary)
                                
                                Text(String(format: "%.1f%%", entry.abv * 100))
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundColor(.primary.opacity(0.6))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color.primary.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
                            )
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @ObservedObject var userSettings: UserSettings
    @ObservedObject var brain: AlcoholBrain
    @State private var showAboutSheet = false
    @State private var showPrivacySheet = false
    
    var body: some View {
        ZStack {
            Color.surfaceDim.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 48) {
                    Group {
                        SettingsHeaderView()
                        SettingsPersonaSection(userSettings: userSettings, brain: brain)
                        SettingsBiometricsSection(userSettings: userSettings, brain: brain)
                        SettingsMetabolismSection(userSettings: userSettings, brain: brain)
                        SettingsFooterView(userSettings: userSettings, showAboutSheet: $showAboutSheet, showPrivacySheet: $showPrivacySheet)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 120)
            }
        }
        .sheet(isPresented: $showAboutSheet) {
            AboutDrukSheet()
        }
        .sheet(isPresented: $showPrivacySheet) {
            PrivacyView()
        }
    }
}

struct SettingsPersonaSection: View {
    @ObservedObject var userSettings: UserSettings
    @ObservedObject var brain: AlcoholBrain
    
    private var displayPersonas: [Persona] {
        let isMale = userSettings.defaultGender == .male
        return isMale ? [.martin, .nikolaj, .tommy, .peter] : [.clara, .elena, .maya, .sofia]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .bottom) {
                Text("人格档案 / The Persona")
                    .font(.system(size: 20, weight: .semibold, design: .serif).italic())
                Spacer()
                Text("身份选择")
                    .font(.system(size: 10, design: .monospaced))
                    .tracking(2.0)
                    .foregroundColor(.onSurface.opacity(0.4))
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(displayPersonas) { p in
                    let isSelected = userSettings.personaStore == p.rawValue
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            userSettings.personaStore = p.rawValue
                            brain.persona = p
                            brain.refreshQuote()
                        }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }) {
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(isSelected ? Color.primary.opacity(0.1) : Color.clear)
                                    .frame(width: 68, height: 68)
                                
                                Image(p.avatarImageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                                    .grayscale(isSelected ? 0 : 1.0)
                                    .opacity(isSelected ? 1.0 : 0.6)
                                    .scaleEffect(isSelected ? 1.1 : 1.0)
                            }
                            .overlay(
                                Circle()
                                    .strokeBorder(isSelected ? Color.primary.opacity(0.6) : Color.clear, lineWidth: 2)
                                    .frame(width: 68, height: 68)
                            )
                            
                            VStack(spacing: 2) {
                                Text(p.zhName)
                                    .font(.system(size: 11, weight: .bold, design: .serif))
                                    .foregroundColor(isSelected ? .primary : .onSurface.opacity(0.6))
                                
                                Text(p.rawValue.uppercased())
                                    .font(.system(size: 8, design: .monospaced))
                                    .tracking(1.0)
                                    .foregroundColor(isSelected ? .primary.opacity(0.6) : .onSurface.opacity(0.3))
                            }
                        }
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(isSelected ? Color.surfaceContainerHighest.opacity(0.4) : Color.clear)
                                .background(.ultraThinMaterial)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(
                                    isSelected ? Color.primary.opacity(0.3) : Color.white.opacity(0.05),
                                    lineWidth: 1
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .onChange(of: userSettings.personaStore) { newValue in
                brain.refreshQuote()
            }
            
            // Dynamic Bilingual Description Preview (Settings Interoperability)
            if let persona = Persona(rawValue: userSettings.personaStore) {
                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Text(persona.zhPersonaType)
                            .font(.system(size: 13, weight: .bold, design: .serif).italic())
                            .foregroundColor(.primary)
                        Text("/")
                            .font(.system(size: 10))
                            .opacity(0.2)
                        Text(persona.enPersonaType)
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.primary.opacity(0.6))
                    }
                    
                    VStack(spacing: 6) {
                        Text(persona.zhDescription)
                            .font(.system(size: 13, weight: .regular, design: .serif).italic())
                            .foregroundColor(.onSurface.opacity(0.8))
                        
                        Text(persona.enDescription.uppercased())
                            .font(.system(size: 9, design: .monospaced))
                            .tracking(1.0)
                            .foregroundColor(.onSurface.opacity(0.4))
                            .lineSpacing(2)
                    }
                    .multilineTextAlignment(.center)
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(Color.surfaceContainerLow.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .opacity))
                .id("settings-desc-\(persona.rawValue)")
            }
        }
    }
    
    private func personaGradient(for persona: Persona) -> LinearGradient {
        switch persona {
        case .martin:
            return LinearGradient(colors: [Color(hex: "#8B4513"), Color(hex: "#D2691E")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .nikolaj:
            return LinearGradient(colors: [Color(hex: "#2F4F4F"), Color(hex: "#556B2F")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .tommy:
            return LinearGradient(colors: [Color(hex: "#1C1C1C"), Color(hex: "#363636")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .peter:
            return LinearGradient(colors: [Color(hex: "#4682B4"), Color(hex: "#5F9EA0")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .clara:
            return LinearGradient(colors: [Color(hex: "#8B008B"), Color(hex: "#9932CC")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .elena:
            return LinearGradient(colors: [Color(hex: "#CD853F"), Color(hex: "#DEB887")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .maya:
            return LinearGradient(colors: [Color(hex: "#FF6347"), Color(hex: "#FF4500")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .sofia:
            return LinearGradient(colors: [Color(hex: "#DB7093"), Color(hex: "#FF69B4")], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

struct SettingsBiometricsSection: View {
    @ObservedObject var userSettings: UserSettings
    @ObservedObject var brain: AlcoholBrain
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .bottom) {
                Text("生物特征 / The Anatomy")
                    .font(.system(size: 20, weight: .semibold, design: .serif).italic())
                Spacer()
                Text("生物指标")
                    .font(.system(size: 10, design: .monospaced))
                    .tracking(2.0)
                    .foregroundColor(.onSurface.opacity(0.4))
            }
            
            VStack(spacing: 24) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("体重 / Weight")
                            .font(.system(size: 10, design: .monospaced))
                            .tracking(2.0)
                            .textCase(.uppercase)
                            .foregroundColor(.onSurfaceVariant.opacity(0.6))
                        
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(String(format: "%.0f", userSettings.defaultWeight))
                                .font(.system(size: 28, weight: .bold, design: .monospaced))
                                .foregroundColor(.primary)
                                .contentTransition(.numericText())
                            Text("kg")
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundColor(.onSurface.opacity(0.6))
                        }
                    }
                    
                    Spacer()
                    
                    Slider(value: $userSettings.defaultWeight, in: 30...200, step: 1)
                        .frame(width: 150)
                        .tint(.primary)
                        .onChange(of: userSettings.defaultWeight) { _ in
                            brain.weight = userSettings.defaultWeight
                            brain.recalculateBAC()
                        }
                }
                
                Divider().background(Color.white.opacity(0.06))
                
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("性别 / Gender")
                            .font(.system(size: 10, design: .monospaced))
                            .tracking(2.0)
                            .textCase(.uppercase)
                            .foregroundColor(.onSurfaceVariant.opacity(0.6))
                        
                        HStack(spacing: 12) {
                            ForEach(Gender.allCases, id: \.self) { g in
                                let isSelected = userSettings.defaultGender == g
                                
                                Button(action: { userSettings.defaultGenderStore = g.rawValue }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: g == .male ? "person.fill" : "person.dress.fill")
                                        Text(g == .male ? "男性 / Male" : "女性 / Female")
                                            .font(.system(size: 11, design: .monospaced))
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(isSelected ? Color.primary.opacity(0.15) : Color.primary.opacity(0.04))
                                    .foregroundColor(isSelected ? .primary : .onSurface.opacity(0.6))
                                    .clipShape(Capsule())
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    
                    Spacer()
                }
                .onChange(of: userSettings.defaultGenderStore) { _ in
                    brain.gender = userSettings.defaultGender
                    brain.recalculateBAC()
                }
            }
        }
        .padding(24)
        .glassCard()
    }
}

struct SettingsJurisdictionSection: View {
    @ObservedObject var userSettings: UserSettings
    @ObservedObject var brain: AlcoholBrain
    @State private var showCountryPicker = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .bottom) {
                Text("法律管辖区 / Jurisdiction")
                    .font(.system(size: 20, weight: .semibold, design: .serif).italic())
                Spacer()
                Text("地区设置")
                    .font(.system(size: 10, design: .monospaced))
                    .tracking(2.0)
                    .foregroundColor(.onSurface.opacity(0.4))
            }
            
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "globe")
                        .font(.title3)
                        .foregroundColor(.primary.opacity(0.6))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(userSettings.selectedCountry.name)
                            .font(.system(size: 16, weight: .semibold, design: .monospaced))
                            .foregroundColor(.primary)
                        Text("\(userSettings.selectedCountry.flag) \(userSettings.selectedCountry.duiLimitString)")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.onSurfaceVariant.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    Button(action: { showCountryPicker = true }) {
                        Text("修改 / Change")
                            .font(.system(size: 10, design: .monospaced))
                            .tracking(1.5)
                            .textCase(.uppercase)
                            .foregroundColor(.primary)
                    }
                }
                
                Divider().background(Color.white.opacity(0.06))
                
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("醉酒驾驶 / DRUNK DRIVING")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .tracking(2.0)
                            .foregroundColor(.primary.opacity(0.9))
                        Text(String(format: "%.3f%%", userSettings.selectedCountry.duiLimit))
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.warning)
                    }
                    
                    Spacer()
                    
                    if let dwiLimit = userSettings.selectedCountry.dwiLimit {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("DUI Threshold")
                                .font(.system(size: 9, design: .monospaced))
                                .tracking(2.0)
                                .opacity(0.4)
                            Text(String(format: "%.3f%%", dwiLimit))
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(.error)
                        }
                    }
                }
            }
            .padding(20)
            .glassCard()
        }
        .sheet(isPresented: $showCountryPicker) {
            CountryPickerSheet(selectedCountry: $userSettings.defaultCountryName)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .onDisappear {
                    brain.country = userSettings.selectedCountry
                    brain.refreshQuote()
                }
        }
    }
}

struct CountryPickerSheet: View {
    @Binding var selectedCountry: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List(CountryLaw.allCountries, id: \.name) { country in
                Button(action: {
                    selectedCountry = country.name
                    dismiss()
                }) {
                    HStack(spacing: 12) {
                        Text(country.flag)
                            .font(.title2)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(country.name)
                                .font(.system(size: 14, weight: .medium, design: .monospaced))
                                .foregroundColor(selectedCountry == country.name ? .primary : .onSurface)
                            Text(country.duiLimitString)
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.onSurfaceVariant.opacity(0.6))
                        }
                        Spacer()
                        if selectedCountry == country.name {
                            Image(systemName: "checkmark")
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("选择国家 / Select Country")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SettingsMetabolismSection: View {
    @ObservedObject var userSettings: UserSettings
    @ObservedObject var brain: AlcoholBrain
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .bottom) {
                Text("代谢速率 / Metabolism")
                    .font(.system(size: 20, weight: .semibold, design: .serif).italic())
                Spacer()
                Text("科学参数")
                    .font(.system(size: 10, design: .monospaced))
                    .tracking(2.0)
                    .foregroundColor(.onSurface.opacity(0.4))
            }
            
            VStack(spacing: 20) {
                ForEach(MetabolicRate.allCases, id: \.self) { rate in
                    let isSelected = userSettings.metabolicRateStore == rate.rawValue
                    
                    Button(action: { userSettings.metabolicRateStore = rate.rawValue }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(rate.displayName)
                                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                                    .foregroundColor(isSelected ? .primary : .onSurface)
                                Text(rate.description)
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(.onSurfaceVariant.opacity(0.6))
                            }
                            
                            Spacer()
                            
                            Text(String(format: "%.3f%%/h", rate.value * 100))
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(isSelected ? .primary : .onSurfaceVariant.opacity(0.4))
                        }
                        .padding(16)
                        .background(isSelected ? Color.primary.opacity(0.1) : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(isSelected ? Color.primary : Color.white.opacity(0.05), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .onChange(of: userSettings.metabolicRateStore) { _ in
                brain.metabolicRate = userSettings.selectedMetabolicRate
                brain.recalculateBAC()
            }
            
            Text("Adjust this only if you have clinical data regarding your personal alcohol elimination rate. / 仅当您拥有关于个人酒精消除率的临床数据时才进行调整。")
                .font(.system(size: 12, design: .serif).italic())
                .foregroundColor(.onSurfaceVariant.opacity(0.5))
                .multilineTextAlignment(.center)
        }
    }
}

struct SettingsFooterView: View {
    @ObservedObject var userSettings: UserSettings
    @Binding var showAboutSheet: Bool
    @Binding var showPrivacySheet: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            Divider().background(Color.white.opacity(0.06))
            
            Text("Version 2.2")
                .font(.system(size: 10, design: .monospaced))
                .tracking(4.0)
                .opacity(0.4)
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.8)) {
                    userSettings.hasCompletedOnboarding = false
                    userSettings.hasSeenCinematicIntro = false
                }
            }) {
                Text("RESTART JOURNEY / 重启旅程")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .overlay(Capsule().stroke(Color.primary.opacity(0.3), lineWidth: 1))
                    .foregroundColor(.primary.opacity(0.6))
            }
            
            Button(action: { showAboutSheet = true }) {
                Text("About Druk")
                    .font(.system(size: 16, weight: .semibold, design: .serif).italic())
                    .foregroundColor(.primary)
            }
            
            Link(destination: URL(string: "mailto:bestskillz2000@gmail.com")!) {
                Text("FEEDBACK & SUPPORT / 用户反馈")
                    .font(.system(size: 14, weight: .semibold, design: .serif).italic())
                    .foregroundColor(.onSurfaceVariant.opacity(0.8))
            }
            
            // ── LEGAL DISCLAIMER CARD ────────────────────────────────────
            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.warning)
                        .font(.system(size: 12))
                    Text("LEGAL DISCLAIMER / 法律免责声明")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .tracking(1.5)
                        .foregroundColor(.primary.opacity(0.9))
                }
                
                VStack(spacing: 8) {
                    Text("本应用基于 Widmark 公式的计算结果仅供娱乐与学术参考。数据不可作为医疗建议，亦绝不能作为判断是否涉及酒驾的法律标准。切忌酒后驾驶。")
                        .font(.system(size: 11, weight: .regular, design: .serif))
                        .foregroundColor(.onSurfaceVariant.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                    
                    Text("Calculations based on the Widmark formula are for entertainment and academic reference only. This data must not be construed as medical advice, nor used as a legal standard for determining intoxication. Never drink and drive.")
                        .font(.system(size: 10, weight: .light, design: .serif).italic())
                        .foregroundColor(.onSurfaceVariant.opacity(0.65))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }
            }
            .padding(20)
            .background(Color.warning.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.warning.opacity(0.2), lineWidth: 1) // subtle warning border
            )
            .cornerRadius(16)
            .padding(.horizontal, 20)
            
            // Links
            HStack(spacing: 24) {
                Link("Our Philosophy", destination: URL(string: "#")!)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.onSurfaceVariant.opacity(0.6))
                
                Button(action: { showPrivacySheet = true }) {
                    Text("Privacy Policy")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.onSurfaceVariant.opacity(0.6))
                }
            }
            
            Text("\"In vino veritas, in aqua sanitas.\"")
                .font(.system(size: 14, weight: .regular, design: .serif).italic())
                .foregroundColor(.onSurfaceVariant.opacity(0.5))
        }
        .padding(.vertical, 32)
    }
}

struct AboutDrukSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.surfaceDim.ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                VStack(spacing: 20) {
                    Image("whiskey_glass")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                    
                    Text("Druk")
                        .font(.system(size: 32, weight: .bold, design: .serif).italic())
                        .foregroundColor(.primary)
                    
                    Text("Version 2.2")
                        .font(.system(size: 12, design: .monospaced))
                        .tracking(2.0)
                        .foregroundColor(.onSurfaceVariant.opacity(0.5))
                }
                
                VStack(spacing: 16) {
                    Divider().background(Color.white.opacity(0.1))
                    
                    Text("致谢 / Acknowledgments:")
                        .font(.system(size: 12, design: .monospaced))
                        .tracking(1.5)
                        .textCase(.uppercase)
                        .foregroundColor(.onSurfaceVariant.opacity(0.6))
                    
                    VStack(spacing: 8) {
                        acknowledgmentRow(title: "电影《酒精计划》(2020)", subtitle: "Another Round, Thomas Vinterberg")
                        acknowledgmentRow(title: "baccalculator.online", subtitle: "BAC Calculation Reference")
                        acknowledgmentRow(title: "Widmark Formula (1932)", subtitle: "Forensic Toxicology Standard")
                    }
                }
                .padding(24)
                .glassCard()
                
                VStack(spacing: 8) {
                    Text("⚠️ 免责声明 / DISCLAIMER")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.error.opacity(0.9))
                    Text("本应用得出的血液酒精浓度（BAC）仅供娱乐和参考，不可作为判断是否涉及酒驾或醉驾的法律/医疗标准。请以交警实际测试结果为准。切勿酒后驾驶。")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.onSurfaceVariant.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Text("关闭 / Close")
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                        .tracking(2.0)
                        .textCase(.uppercase)
                        .foregroundColor(.surfaceDim)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.primary)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func acknowledgmentRow(title: String, subtitle: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.onSurface)
                Text(subtitle)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.onSurfaceVariant.opacity(0.5))
            }
            Spacer()
        }
    }
}

// MARK: - Share Sheet Helper
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

private func renderShareCard(image: Image) -> UIImage {
    let renderer = ImageRenderer(content: image)
    renderer.scale = 3.0
    return renderer.uiImage ?? UIImage()
}
