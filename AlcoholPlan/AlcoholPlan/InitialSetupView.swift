import SwiftUI

struct InitialSetupView: View {
    @ObservedObject var userSettings: UserSettings
    @ObservedObject var brain: AlcoholBrain
    
    // Internal state for UI reactivity
    @State private var weightValue: Double = 70.0
    @State private var isEntering = false
    @State private var showingCountryPicker = false
    
    // Dynamic Filter for Personas
    private var filteredPersonas: [Persona] {
        Persona.allCases.filter { $0.gender == userSettings.defaultGender }
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.surfaceDim.ignoresSafeArea()
            
            // Soft Amber Glow (Ambient Light)
            RadialGradient(
                colors: [Color.primary.opacity(0.08), Color.clear],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 800
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 56) {
                    editorialHeader
                    
                    anatomySection
                    
                    personaGridSection
                    
                    jurisdictionSection
                    
                    metabolismSection
                    
                    footerActionSection
                }
                .padding(.horizontal, 24)
                .padding(.top, 40)
                .padding(.bottom, 80)
            }
        }
        .sheet(isPresented: $showingCountryPicker) {
            CountryPickerView(userSettings: userSettings, brain: brain)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            weightValue = userSettings.defaultWeight
            withAnimation(.easeOut(duration: 0.8)) {
                isEntering = true
            }
        }
    }
    
    // MARK: - 1. Editorial Header
    private var editorialHeader: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Druk / The Patron Registry")
                    .font(.system(size: 14, weight: .regular, design: .serif).italic())
                    .foregroundColor(.amberGold.opacity(0.9))
                    .tracking(2.0)
                
                Text("午夜序章")
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundColor(.ivoryWarm)
                
                Text("THE MIDNIGHT PROLOGUE")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .tracking(4.0)
                    .foregroundColor(.silverGray.opacity(0.5))
            }
            Spacer()
        }
        .opacity(isEntering ? 1 : 0)
        .offset(y: isEntering ? 0 : 20)
    }
    
    // MARK: - 2. Anatomy (Biological Stats) - NOW FIRST
    private var anatomySection: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .bottom) {
                Text("生物特征 / The Anatomy")
                    .font(.system(size: 20, weight: .bold, design: .serif).italic())
                    .foregroundColor(.ivoryWarm)
                Spacer()
                Text("生物指标 / BIOMETRICS")
                    .font(.system(size: 10, design: .monospaced))
                    .tracking(2.0)
                    .foregroundColor(.silverGray.opacity(0.6))
            }
            
            // Gender Toggle
            HStack(spacing: 16) {
                GenderToggle(title: "MALE / 男性", systemImage: "male", isSelected: userSettings.defaultGender == .male) {
                    toggleGender(.male)
                }
                
                GenderToggle(title: "FEMALE / 女性", systemImage: "female", isSelected: userSettings.defaultGender == .female) {
                    toggleGender(.female)
                }
            }
            
            // Weight Slider Card
            VStack(spacing: 24) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("体重 / Weight")
                            .font(.system(size: 16, weight: .bold, design: .serif))
                            .foregroundColor(.ivoryWarm)
                        Text("体重是精确计算酒精浓度的关键基准指标\nWEIGHT IS THE BASELINE FOR BAC ACCURACY")
                            .font(.system(size: 9, design: .serif).italic())
                            .foregroundColor(.silverGray.opacity(0.7))
                            .lineSpacing(4)
                    }
                    Spacer()
                    HStack(alignment: .bottom, spacing: 4) {
                        Text("\(Int(weightValue))")
                            .font(.system(size: 36, weight: .bold, design: .monospaced))
                            .foregroundColor(.amberGold)
                        Text("KG")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.amberGold.opacity(0.5))
                            .padding(.bottom, 6)
                    }
                }
                
                Slider(value: $weightValue, in: 40...150, step: 1)
                    .accentColor(.amberGold)
                    .onChange(of: weightValue) { newValue in
                        userSettings.defaultWeight = newValue
                        brain.weight = newValue
                    }
            }
            .padding(24)
            .glassCard()
        }
        .opacity(isEntering ? 1 : 0)
        .offset(y: isEntering ? 0 : 20)
    }
    
    // MARK: - 3. Persona Selection (Dynamic Filtering & Animation)
    private var personaGridSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .bottom) {
                Text("人格档案 / The Persona")
                    .font(.system(size: 20, weight: .bold, design: .serif).italic())
                    .foregroundColor(.ivoryWarm)
                Spacer()
                Text("身份选择 / IDENTITY")
                    .font(.system(size: 10, design: .monospaced))
                    .tracking(2.0)
                    .foregroundColor(.silverGray.opacity(0.6))
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(Array(filteredPersonas.enumerated()), id: \.element.id) { index, persona in
                    PersonaCardView(
                        persona: persona,
                        isSelected: userSettings.selectedPersona == persona,
                        isEntering: isEntering,
                        index: index,
                        action: { selectPersona(persona) }
                    )
                }
            }
            .transition(.push(from: .trailing))
            .id("personaGrid-\(userSettings.defaultGender.rawValue)")
            
            // Philosophy Description (Bilingual)
            VStack(spacing: 12) {
                Text(userSettings.selectedPersona.zhDescription)
                    .font(.system(size: 14, weight: .regular, design: .serif).italic())
                    .multilineTextAlignment(.center)
                    .foregroundColor(.ivoryWarm.opacity(0.85))
                
                Text(userSettings.selectedPersona.enDescription.uppercased())
                    .font(.system(size: 9, design: .monospaced))
                    .tracking(1.0)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.silverGray.opacity(0.5))
                    .lineSpacing(4)
            }
            .padding(.horizontal, 24)
            .frame(minHeight: 100)
            .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .opacity))
            .id("desc-\(userSettings.selectedPersona.rawValue)")
            .padding(.top, 8)
        }
    }
    
    // MARK: - 4. Jurisdiction
    private var jurisdictionSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .bottom) {
                Text("法律管辖区 / Jurisdiction")
                    .font(.system(size: 20, weight: .bold, design: .serif).italic())
                    .foregroundColor(.ivoryWarm)
                Spacer()
                Text("地区标准 / STANDARDS")
                    .font(.system(size: 10, design: .monospaced))
                    .tracking(2.0)
                    .foregroundColor(.silverGray.opacity(0.6))
            }
            
            VStack(spacing: 0) {
                HStack(spacing: 20) {
                    Text(userSettings.selectedCountry.flag)
                        .font(.system(size: 40))
                        .shadow(radius: 5)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("国家 / 地区 / COUNTRY")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(.silverGray.opacity(0.5))
                        HStack(spacing: 8) {
                            Text(userSettings.selectedCountry.name)
                                .font(.system(size: 18, weight: .bold, design: .serif).italic())
                                .foregroundColor(.ivoryWarm)
                            Text("/")
                                .font(.system(size: 14))
                                .foregroundColor(.silverGray.opacity(0.2))
                            Text(userSettings.selectedCountry.enName.uppercased())
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(.silverGray.opacity(0.6))
                        }
                    }
                    Spacer()
                    Button(action: { showingCountryPicker = true }) {
                        Text("修改 / CHANGE")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.05))
                            .overlay(Capsule().stroke(Color.white.opacity(0.1), lineWidth: 1))
                            .foregroundColor(.ivoryWarm)
                    }
                }
                .padding(24)
                
                Divider().background(Color.white.opacity(0.1)).padding(.horizontal, 24)
                
                HStack(spacing: 40) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("醉酒驾驶 / DRUNK DRIVING")
                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                            .foregroundColor(.silverGray.opacity(0.5))
                        Text(String(format: "%.2f%%", userSettings.selectedCountry.duiLimit))
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundColor(.amberGold)
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("饮酒驾驶阈值 / DUI THRESHOLD")
                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                            .foregroundColor(.silverGray.opacity(0.5))
                        Text(userSettings.selectedCountry.dwiLimit != nil ? String(format: "%.2f%%", userSettings.selectedCountry.dwiLimit!) : "N/A")
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundColor(.amberGold.opacity(0.7))
                    }
                    Spacer()
                }
                .padding(24)
            }
            .glassCard()
        }
        .opacity(isEntering ? 1 : 0)
        .offset(y: isEntering ? 0 : 20)
    }
    
    // MARK: - 5. Metabolism
    private var metabolismSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .bottom) {
                Text("代谢速率 / Metabolism")
                    .font(.system(size: 20, weight: .bold, design: .serif).italic())
                    .foregroundColor(.ivoryWarm)
                Spacer()
                Text("代谢率 / BURN RATE")
                    .font(.system(size: 10, design: .monospaced))
                    .tracking(2.0)
                    .foregroundColor(.silverGray.opacity(0.6))
            }
            
            HStack(spacing: 4) {
                ForEach(MetabolicRate.allCases) { rate in
                    let isSelected = userSettings.selectedMetabolicRate == rate
                    Button(action: {
                        withAnimation { userSettings.selectedMetabolicRate = rate }
                    }) {
                        Text(rate.displayName.uppercased())
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(isSelected ? .amberGold.opacity(0.15) : Color.clear)
                            .foregroundColor(isSelected ? .amberGold : .silverGray.opacity(0.6))
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(4)
            .background(Color.surfaceContainerLowest.opacity(0.6))
            .clipShape(Capsule())
        }
        .opacity(isEntering ? 1 : 0)
        .offset(y: isEntering ? 0 : 20)
    }
    
    // MARK: - 6. Footer
    private var footerActionSection: some View {
        VStack(spacing: 24) {
            PrimaryActionButton(title: "开始旅程 / ENTER THE LEDGER", action: finishSetup)
            Text("\"In vino veritas, in aqua sanitas.\"")
                .font(.system(size: 13, weight: .regular, design: .serif).italic())
                .foregroundColor(.ivoryWarm.opacity(0.3))
        }
    }
    
    // MARK: - Logic
    private func toggleGender(_ gender: Gender) {
        if userSettings.defaultGender != gender {
            withAnimation(.spring(response: 0.5)) {
                userSettings.defaultGender = gender
                brain.gender = gender
                
                // Auto-switch persona to a valid one for the new gender
                let firstValid = Persona.allCases.first { $0.gender == gender }
                if let valid = firstValid {
                    userSettings.selectedPersona = valid
                }
            }
        }
    }
    
    private func selectPersona(_ persona: Persona) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            userSettings.selectedPersona = persona
        }
    }
    
    private func finishSetup() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        withAnimation(.easeInOut(duration: 1.0)) {
            userSettings.hasCompletedOnboarding = true
        }
    }
}

// MARK: - Subviews
struct GenderToggle: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 16))
                Text(title)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
            }
            .foregroundColor(isSelected ? Color.amberGold : Color.ivoryWarm.opacity(0.4))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? Color.amberGold.opacity(0.1) : Color.surfaceContainerLow.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.amberGold.opacity(0.4) : Color.white.opacity(0.05), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PersonaCardView: View {
    let persona: Persona
    let isSelected: Bool
    let isEntering: Bool
    let index: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                PersonaAvatarView(persona: persona, isSelected: isSelected)
                PersonaLabelsView(persona: persona, isSelected: isSelected)
            }
            .padding(.top, 24)
            .padding(.bottom, 20)
            .frame(maxWidth: .infinity)
            .background(cardBackground)
            .overlay(cardOverlay)
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(isEntering ? 1 : 0)
        .offset(y: isEntering ? 0 : 30)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1 + 0.3), value: isEntering)
    }
    
    @ViewBuilder
    private var cardBackground: some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.surfaceContainerHighest.opacity(0.3))
                .background(RoundedRectangle(cornerRadius: 24).fill(.ultraThinMaterial))
        } else {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.surfaceContainerLow.opacity(0.1))
        }
    }
    
    private var cardOverlay: some View {
        RoundedRectangle(cornerRadius: 24)
            .stroke(isSelected ? .amberGold.opacity(0.4) : Color.white.opacity(0.05), lineWidth: 1)
    }
}

struct PersonaAvatarView: View {
    let persona: Persona
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            Image(persona.avatarImageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .grayscale(isSelected ? 0 : 1.0)
                .opacity(isSelected ? 1.0 : 0.4)
                .scaleEffect(isSelected ? 1.1 : 1.0)
            
            if isSelected {
                Circle()
                    .stroke(Color.amberGold.opacity(0.5), lineWidth: 3)
                    .frame(width: 88, height: 88)
                    .blur(radius: 2)
            }
        }
        .shadow(color: isSelected ? Color.amberGold.opacity(0.3) : .clear, radius: 15)
    }
}

struct PersonaLabelsView: View {
    let persona: Persona
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Text(persona.zhName)
                .font(.system(size: 16, weight: .bold, design: .serif).italic())
                .foregroundColor(isSelected ? Color.amberGold : Color.ivoryWarm.opacity(0.6))
            
            Text(persona.enPersonaType)
                .font(.system(size: 8, design: .monospaced))
                .tracking(1.0)
                .foregroundColor(isSelected ? Color.amberGold.opacity(0.7) : Color.silverGray.opacity(0.3))
        }
    }
}

struct PrimaryActionButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .tracking(2.0)
                .foregroundColor(Color(hex: "#1a1714"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 22)
                .background(
                    Capsule()
                        .fill(LinearGradient(colors: [.amberGold, Color(hex: "#c8862a")], startPoint: .top, endPoint: .bottom))
                )
                .shadow(color: .amberGold.opacity(0.3), radius: 20, x: 0, y: 10)
        }
    }
}
