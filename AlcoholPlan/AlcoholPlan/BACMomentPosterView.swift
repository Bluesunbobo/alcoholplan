import SwiftUI

// MARK: - BAC Moment Snapshot Poster
// Cinematic "Late-night Ledger" poster.
// Mirroring the brand's philosophical and high-end aesthetic.

struct BACMomentData {
    let timestamp: Date
    let bacValue: Double
    let stateZh: String
    let stateEn: String
    let quoteZh: String
    let quoteEn: String
    let personaName: String
    let personaZhName: String
    let personaAvatarImage: String
}

struct BACMomentPosterView: View {
    let data: BACMomentData

    private var timeString: String {
        let f = DateFormatter(); f.dateFormat = "HH:mm"
        return f.string(from: data.timestamp)
    }

    private var dateString: String {
        let f = DateFormatter(); f.dateFormat = "MMM dd, yyyy"
        return f.string(from: data.timestamp).uppercased()
    }

    // Mirrors app's glow formula: 0.18 * min(1.0, bac * 10)
    private var glowOpacity: Double {
        0.18 * min(1.0, data.bacValue * 10)
    }

    var body: some View {
        ZStack {
            backgroundLayer

            VStack(spacing: 0) {
                headerSection
                    .padding(.top, 44)
                    .padding(.horizontal, 40)

                Spacer()

                // ── Cinematic Data Ledger Zone ──────────────────
                HStack(alignment: .top, spacing: 24) {
                    // Vertical Amber Bar - The Brand Signature
                    Rectangle()
                        .fill(Color.primary)
                        .frame(width: 3)
                        .frame(height: 180)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        bacDisplaySection
                        stateDisplaySection
                        timestampSection
                    }
                }
                .padding(.horizontal, 40)

                Spacer()

                // ── Hero Quote ────────────────────────────────────
                quoteSection
                    .padding(.horizontal, 40)

                Spacer(minLength: 40)

                footerSection
                    .padding(.horizontal, 40)
                    .padding(.bottom, 44)
            }
        }
        .frame(width: 400, height: 720)
        .clipped()
    }

    // MARK: - Background Layer
    private var backgroundLayer: some View {
        ZStack {
            Color.surfaceDim

            // Radial Glow
            RadialGradient(
                colors: [Color.primary.opacity(glowOpacity), Color.clear],
                center: .top,
                startRadius: 0,
                endRadius: 400
            )

            // Vignette
            RadialGradient(
                colors: [Color.clear, Color.black.opacity(0.7)],
                center: .center,
                startRadius: 100,
                endRadius: 450
            )
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Druk 微醺志")
                .font(.system(size: 20, weight: .medium, design: .serif).italic())
                .foregroundColor(.primary)
            
            Text("MOMENT LEDGER / \(dateString)")
                .font(.system(size: 8, design: .monospaced))
                .tracking(3.5)
                .foregroundColor(.onSurface.opacity(0.35))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - BAC Display
    private var bacDisplaySection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("ESTIMATED BAC")
                .font(.system(size: 8, design: .monospaced))
                .tracking(2.0)
                .foregroundColor(.primary.opacity(0.4))
                .padding(.bottom, 4)

            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(String(format: "%.3f", data.bacValue))
                    .font(.system(size: 72, weight: .bold, design: .monospaced))
                    .foregroundColor(.primary)
                
                Text("%")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(.primary.opacity(0.6))
            }
        }
    }

    // MARK: - State Display
    private var stateDisplaySection: some View {
        HStack(spacing: 8) {
            Text(data.stateZh)
                .font(.system(size: 22, weight: .semibold, design: .serif))
                .foregroundColor(.primary)

            Text(data.stateEn)
                .font(.system(size: 18, weight: .regular, design: .serif).italic())
                .foregroundColor(.primary.opacity(0.8))
        }
    }
    
    // MARK: - Timestamp
    private var timestampSection: some View {
        Text("LOGGED AT \(timeString)")
            .font(.system(size: 9, weight: .light, design: .monospaced))
            .tracking(3.0)
            .foregroundColor(.onSurface.opacity(0.25))
            .padding(.top, 4)
    }

    // MARK: - Quote Section
    private var quoteSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\u{201C}\(data.quoteZh)\u{201D}")
                .font(.system(size: 24, weight: .regular, design: .serif).italic())
                .foregroundColor(.onSurface.opacity(0.9))
                .multilineTextAlignment(.leading)
                .lineSpacing(10)

            Text("\"\(data.quoteEn)\"")
                .font(.system(size: 10, weight: .regular, design: .serif).italic())
                .foregroundColor(.onSurfaceVariant.opacity(0.4))
                .multilineTextAlignment(.leading)
                .lineSpacing(4)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Footer
    private var footerSection: some View {
        VStack(spacing: 12) {
            Text("NEVER DRINK AND DRIVE  ·  切勿酒后驾驶")
                .font(.system(size: 7, weight: .semibold, design: .monospaced))
                .tracking(3.5)
                .foregroundColor(.primary.opacity(0.25))

            Divider().background(Color.white.opacity(0.08))

            HStack {
                HStack(spacing: 8) {
                    Image(data.personaAvatarImage)
                        .resizable()
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                        .grayscale(1.0)
                        .overlay(Circle().stroke(Color.primary.opacity(0.2), lineWidth: 1))
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text(data.personaZhName)
                            .font(.system(size: 9, weight: .bold))
                        Text(data.personaName.uppercased())
                            .font(.system(size: 7, design: .monospaced))
                            .opacity(0.4)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("DRUK MICRO-LOG")
                        .font(.system(size: 7, weight: .bold, design: .monospaced))
                        .tracking(1.0)
                    Text("理论值仅供参考")
                        .font(.system(size: 6))
                        .opacity(0.3)
                }
                .foregroundColor(.primary.opacity(0.3))
            }
        }
    }
}

#Preview {
    BACMomentPosterView(data: BACMomentData(
        timestamp: Date(),
        bacValue: 0.045,
        stateZh: "微醺",
        stateEn: "Tipsy",
        quoteZh: "今朝有酒今朝醉，明日愁来明日愁。",
        quoteEn: "Drink today, for tomorrow is another day.",
        personaName: "Poet",
        personaZhName: "诗人",
        personaAvatarImage: "avatar_poet"
    ))
    .preferredColorScheme(.dark)
}
