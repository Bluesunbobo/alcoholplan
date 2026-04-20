import SwiftUI
import CoreData

struct HeatmapData {
    let year: String
    let totalDrinks: Int
    let highestBAC: Double
    let favoriteDrink: String
    let days: [HeatmapDay]
    let quoteZh: String
    let quoteEn: String
}

struct HeatmapDay: Identifiable {
    let id = UUID()
    let date: Date
    let bac: Double // Determine color intensity
}

struct HeatmapPosterView: View {
    let data: HeatmapData
    
    // Grid Setup
    let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 26) // 26 columns for year
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection
            
            Spacer()
            
            // Hero info
            heroSection
            
            Spacer()
            
            // Heatmap Grid
            gridSection
            
            Spacer(minLength: 12)
            
            // Stats Grid
            statsGridSection
            
            Spacer(minLength: 12)
            
            // Footer
            footerSection
        }
        .padding(40)
        .frame(width: 400, height: 720)
        .background(
            ZStack {
                Color.surfaceDim
                

                
                RadialGradient(
                    colors: [Color.primary.opacity(0.12), Color.clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 400
                )
            }
        )
        .edgesIgnoringSafeArea(.all)
    }
    
    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Druk-微醺志")
                    .font(.system(size: 14, weight: .bold, design: .serif).italic())
                    .tracking(1.0)
                    .foregroundColor(.primary)
                
                Text("\(data.year) ANNUAL REPORT")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(.onSurface.opacity(0.6))
            }
            Spacer()
            Circle()
                .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                .frame(width: 32, height: 32)
                .overlay(
                    Text("D")
                        .font(.system(size: 14, weight: .bold, design: .serif))
                        .foregroundColor(.primary)
                )
        }
    }
    
    private var heroSection: some View {
        VStack(spacing: 8) {
            Text("\"\(data.quoteZh)\"")
                .font(.system(size: 24, weight: .regular, design: .serif).italic())
                .foregroundColor(.onSurface)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .lineLimit(4)
                .minimumScaleFactor(0.6)
            
            Text(data.quoteEn)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(.primary.opacity(0.8))
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .lineLimit(4)
                .minimumScaleFactor(0.5)
        }
    }
    
    private var gridSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("FREQUENCY MATRIX / 饮酒频次矩阵")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .tracking(2.0)
                .foregroundColor(.primary.opacity(0.4))
            
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(data.days) { day in
                    let alcoholGrams = day.bac // mapped to grams
                    let intensityLevel = getIntensityLevel(for: alcoholGrams)
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(getColor(for: intensityLevel))
                        .aspectRatio(1, contentMode: .fill)
                }
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.05), lineWidth: 1))
            
            // Legend
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
                Text("沉醉 / HEAVY")
                    .font(.system(size: 8, design: .monospaced))
                    .foregroundColor(.onSurfaceVariant.opacity(0.4))
            }
            .padding(.horizontal, 16)
        }
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
    
    private var statsGridSection: some View {
        HStack(spacing: 0) {
            // Left: Session count
            VStack(alignment: .center, spacing: 10) {
                VStack(spacing: 2) {
                    Text("记录饮酒")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.onSurface.opacity(0.3))
                    Text("SESSIONS")
                        .font(.system(size: 8, design: .monospaced))
                        .tracking(1.5)
                        .foregroundColor(.onSurface.opacity(0.2))
                }
                Text("\(data.totalDrinks) 次")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(.onSurface)
            }
            .frame(maxWidth: .infinity)
            
            // Vertical divider
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 1, height: 48)
            
            // Right: Highest BAC
            VStack(alignment: .center, spacing: 10) {
                VStack(spacing: 2) {
                    Text("最高峰值")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.onSurface.opacity(0.3))
                    Text("HIGHEST BAC")
                        .font(.system(size: 8, design: .monospaced))
                        .tracking(1.5)
                        .foregroundColor(.onSurface.opacity(0.2))
                }
                Text(String(format: "%.3f%%", data.highestBAC))
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(.onSurface)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 24)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.03)))
    }
    
    private var footerSection: some View {
        VStack(spacing: 12) {
            Text("免责声明：本应用计算出的 BAC 理论值仅供娱乐和参考，不可作为判断是否涉及酒驾的标准。请以实际检测为准。切勿酒后驾驶。")
                .font(.system(size: 6))
                .foregroundColor(.white.opacity(0.15))
                .multilineTextAlignment(.center)
            
            Divider().background(Color.white.opacity(0.1))
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("PHOTO GENERATED BY DRUK APP")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                    Text("图片由 Druk 微醺志 生成")
                        .font(.system(size: 7))
                }
                .foregroundColor(.primary.opacity(0.4))
                .tracking(1.5)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("ANNUAL REVIEW")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .tracking(2.0)
                    Text("年度饮酒报告")
                        .font(.system(size: 7))
                }
                .foregroundColor(.primary.opacity(0.4))
            }
        }
    }
}
