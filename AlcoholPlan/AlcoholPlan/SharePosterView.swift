import SwiftUI
import Charts

struct SharePosterView: View {
    let sessionData: PosterSessionData
    let userSettings: UserSettings
    
    var body: some View {
        VStack(spacing: 0) {
            // Header: Branding
            headerSection
            
            Spacer()
            
            // Hero: Status & BAC (The Focal Point)
            heroSectionCentered
            
            Spacer()
            
            // Chart: Metabolism Curve
            chartSection
            
            Spacer(minLength: 40)
            
            // Info Grid
            statsGridSection
            
            Spacer(minLength: 40)
            
            // Footer: Quote & Attribution
            footerSection
        }
        .padding(40)
        .frame(width: 400, height: 720) // Standard high-res aspect ratio base
        .background(
            ZStack {
                Color.surfaceDim
                // Central High-Intensity Glow matching the new hero position
                RadialGradient(
                    colors: [Color.primary.opacity(0.18), Color.clear],
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
                Text("Druk-醉好时光")
                    .font(.system(size: 14, weight: .bold, design: .serif).italic())
                    .tracking(1.0)
                    .foregroundColor(.primary)
                
                Text(sessionData.dateString)
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(.onSurface.opacity(0.4))
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
    
    private var heroSectionCentered: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Text("\"\(sessionData.quoteZh)\"")
                    .font(.system(size: 24, weight: .regular, design: .serif).italic())
                    .foregroundColor(.onSurface)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                
                Text(sessionData.quoteEn)
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(.primary.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            
            // The Big Number (Focal Point)
            HStack(alignment: .lastTextBaseline, spacing: -2) {
                Text(String(format: "%.3f", sessionData.peakBAC))
                    .font(.system(size: 84, weight: .bold, design: .monospaced))
                    .tracking(-4.0)
                    .foregroundColor(.primary)
                    .shadow(color: Color.primary.opacity(0.3), radius: 30)
                Text("%")
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(.primary.opacity(0.6))
            }
        }
    }
    
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("METABOLISM CURVE / 代谢曲线")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .tracking(1.5)
                .foregroundColor(.onSurface.opacity(0.3))
            
            Chart {
                ForEach(sessionData.trajectory, id: \.time) { dp in
                    LineMark(
                        x: .value("Time", dp.time),
                        y: .value("BAC", dp.bac)
                    )
                    .interpolationMethod(.monotone)
                    .foregroundStyle(Color.primary)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    
                    AreaMark(
                        x: .value("Time", dp.time),
                        y: .value("BAC", dp.bac)
                    )
                    .interpolationMethod(.monotone)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.primary.opacity(0.3), Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(height: 100)
        }
    }
    
    private var statsGridSection: some View {
        HStack(spacing: 0) {
            VStack(spacing: 8) {
                Text("本次摄入 / INTAKE")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(.onSurface.opacity(0.3))
                
                VStack(spacing: 4) {
                    ForEach(sessionData.drinksDetail, id: \.self) { drink in
                        HStack(spacing: 4) {
                            Text(drink.name)
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.onSurface.opacity(0.8))
                            Text("\(Int(drink.volumeML))ML")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(.onSurface)
                            Text("(\(String(format: "%.1f", drink.abv * 100))%)")
                                .font(.system(size: 8, design: .monospaced))
                                .foregroundColor(.primary.opacity(0.8))
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            
            Divider().background(Color.white.opacity(0.1)).frame(height: 30)
            
            StatItem(label: "峰值时间 / PEAK AT", value: sessionData.peakTime)
        }
        .padding(.vertical, 20)
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
                    Text("图片由 Druk 醉好时光 生成")
                        .font(.system(size: 7))
                }
                .foregroundColor(.primary.opacity(0.4))
                .tracking(1.5)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(sessionData.statusEn.uppercased())
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .tracking(2.0)
                    Text(sessionData.statusZh)
                        .font(.system(size: 7))
                }
                .foregroundColor(.primary.opacity(0.4))
            }
        }
    }
}

struct StatItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(.onSurface.opacity(0.3))
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(.onSurface)
        }
    }
}

struct PosterDrinkDetail: Hashable {
    let name: String
    let abv: Double
    let volumeML: Double
}

// Data model for the poster
struct PosterSessionData {
    let dateString: String
    let avatarImage: String // Keeping for model compatibility but unused in view
    let statusZh: String
    let statusEn: String
    let peakBAC: Double
    let drinksDetail: [PosterDrinkDetail]
    let totalAlcohol: Double
    let peakTime: String
    let quoteZh: String
    let quoteEn: String
    let trajectory: [(time: Date, bac: Double, isPredicted: Bool)]
}
