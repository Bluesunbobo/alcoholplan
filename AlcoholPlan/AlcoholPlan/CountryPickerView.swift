import SwiftUI

struct CountryPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var userSettings: UserSettings
    @ObservedObject var brain: AlcoholBrain
    
    @State private var searchText = ""
    
    private var filteredCountries: [CountryLaw] {
        if searchText.isEmpty {
            return CountryLaw.allCountries
        } else {
            return CountryLaw.allCountries.filter { 
                $0.name.contains(searchText) || 
                $0.enName.lowercased().contains(searchText.lowercased()) 
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.surface.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("法律管辖区 / JURISDICTION")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .tracking(2.0)
                            .foregroundColor(.primary.opacity(0.6))
                        Text("选择标准")
                            .font(.system(size: 24, weight: .bold, design: .serif))
                            .foregroundColor(.onSurface)
                    }
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.onSurface.opacity(0.2))
                    }
                }
                .padding(24)
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.onSurface.opacity(0.3))
                    TextField("搜索国家 / Search Country...", text: $searchText)
                        .font(.system(size: 16, design: .serif).italic())
                }
                .padding(16)
                .background(Color.surfaceContainer.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                
                // Content
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(filteredCountries) { country in
                            let isSelected = userSettings.selectedCountry == country
                            
                            Button(action: {
                                selectCountry(country)
                            }) {
                                HStack(spacing: 16) {
                                    // Flag
                                    Text(country.flag)
                                        .font(.system(size: 32))
                                        .frame(width: 48, height: 48)
                                        .background(Circle().fill(Color.white.opacity(isSelected ? 0.1 : 0.05)))
                                    
                                    // Names
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(country.name)
                                            .font(.system(size: 18, weight: .bold, design: .serif).italic())
                                            .foregroundColor(isSelected ? .primary : .onSurface)
                                        Text(country.enName.uppercased())
                                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                                            .tracking(1.0)
                                            .foregroundColor(isSelected ? .primary.opacity(0.7) : .onSurface.opacity(0.4))
                                    }
                                    
                                    Spacer()
                                    
                                    // Limits Info
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("DUI LIMIT")
                                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                                            .foregroundColor(.onSurface.opacity(0.3))
                                        Text(String(format: "%.2f%%", country.duiLimit))
                                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                                            .foregroundColor(isSelected ? .primary : .tertiary)
                                    }
                                }
                                .padding(20)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(isSelected ? Color.primary.opacity(0.1) : Color.surfaceContainerLow.opacity(0.3))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(isSelected ? Color.primary.opacity(0.4) : Color.white.opacity(0.05), lineWidth: 1)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(24)
                }
            }
        }
    }
    
    private func selectCountry(_ country: CountryLaw) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            userSettings.selectedCountry = country
            brain.country = country
        }
        dismiss()
    }
}
