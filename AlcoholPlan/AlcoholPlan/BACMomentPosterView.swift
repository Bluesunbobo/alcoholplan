import SwiftUI

// MARK: - BAC Moment Snapshot Poster
// Cinematic heart-of-the-moment poster.
// Typography and BAC display style mirrors the app's main BAC card 1:1.

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

    // Mirrors app's glow formula: 0.12 * min(1.0, bac * 10)
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

                // ── BAC Card Zone — identical layout to app ───────
                bacCardZone
                    .padding(.horizontal, 40)

                Spacer()

                // ── Hero Quote — centrepiece ──────────────────────
                quoteSection
                    .padding(.horizontal, 36)

                Spacer(minLength: 20)

                footerSection
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
            }
        }
        .frame(width: 400, height: 720)
        .clipped()
    }

    // MARK: - Background
    // Mirrors the app BAC card: RadialGradient from .top + vignette
    private var backgroundLayer: some View {
        ZStack {
            Color.surfaceDim

            // Same amber glow as app card — origin at top, scales with BAC
            RadialGradient(
                colors: [Color.primary.opacity(glowOpacity), Color.clear],
                center: UnitPoint(x: 0.5, y: 0.0),
                startRadius: 20,
                endRadius: 380
            )

            // Cinematic vignette border
            RadialGradient(
                colors: [Color.clear, Color.black.opacity(0.65)],
                center: .center,
                startRadius: 150,
                endRadius: 420
            )
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Druk · 微醺志")
                    .font(.system(size: 13, weight: .bold, design: .serif).italic())
                    .tracking(0.8)
                    .foregroundColor(.primary)

                Text("此刻心境  ·  \(dateString)")
                    .font(.system(size: 8, design: .monospaced))
                    .tracking(1.5)
                    .foregroundColor(.onSurface.opacity(0.35))
            }

            Spacer()

            HStack(spacing: 6) {
                Image(data.personaAvatarImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 28, height: 28)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.primary.opacity(0.25), lineWidth: 1))

                Text(data.personaZhName)
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .tracking(1.2)
                    .foregroundColor(.primary.opacity(0.7))
            }
        }
    }

    // MARK: - BAC Card Zone
    // Mirrors app's bacDisplayCard layout precisely:
    // context label → big number → state name → separator → quote
    private var bacCardZone: some View {
        VStack(spacing: 20) {
            // Context label — matches app's "当前实时估算 / REAL-TIME"
            HStack(spacing: 6) {
                Text("当前实时估算")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.primary.opacity(0.5))
                Text("/ REAL-TIME")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.primary.opacity(0.3))
            }
            .tracking(1.5)

            // Large BAC number — 72pt bold monospaced (same as app)
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(String(format: "%.3f", data.bacValue))
                    .font(.system(size: 72, weight: .bold, design: .monospaced))
                    .foregroundColor(.primary)
                    .shadow(color: Color.primary.opacity(0.22), radius: 24)

                Text("%")
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(.primary.opacity(0.8))
            }
            .frame(maxWidth: .infinity)

            // State name — 18pt serif medium ZH + 16pt serif italic EN (same as app)
            HStack(spacing: 8) {
                Text(data.stateZh)
                    .font(.system(size: 18, weight: .medium, design: .serif))
                    .foregroundColor(.primary)

                Text(data.stateEn)
                    .font(.system(size: 16, weight: .regular, design: .serif).italic())
                    .foregroundColor(.primary.opacity(0.85))
            }

            // Separator — 60px / 1px / opacity 0.15 (same as app)
            Rectangle()
                .fill(Color.primary.opacity(0.15))
                .frame(width: 60, height: 1)

            // Time stamp — subtle, below the separator
            Text(timeString)
                .font(.system(size: 10, weight: .light, design: .monospaced))
                .tracking(5.0)
                .foregroundColor(.onSurface.opacity(0.25))
        }
    }

    // MARK: - Quote Section — centrepiece of the poster
    private var quoteSection: some View {
        VStack(spacing: 14) {
            // Chinese quote — 26pt serif italic, high presence (scaled from app's 16pt)
            Text("\u{201C}\(data.quoteZh)\u{201D}")
                .font(.system(size: 26, weight: .regular, design: .serif).italic())
                .foregroundColor(.onSurface.opacity(0.88))
                .multilineTextAlignment(.center)
                .lineSpacing(8)
                .lineLimit(5)
                .minimumScaleFactor(0.6)

            // English subtitle — uppercase, mirrors app's style
            Text("\"\(data.quoteEn)\"")
                .font(.system(size: 11, weight: .regular, design: .serif).italic())
                .foregroundColor(.onSurfaceVariant.opacity(0.5))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .lineLimit(4)
                .minimumScaleFactor(0.65)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Footer
    private var footerSection: some View {
        VStack(spacing: 8) {
            Text("切勿酒后驾驶  ·  NEVER DRINK AND DRIVE")
                .font(.system(size: 7, weight: .semibold, design: .monospaced))
                .tracking(2.0)
                .foregroundColor(.primary.opacity(0.2))
                .multilineTextAlignment(.center)

            Rectangle().fill(Color.white.opacity(0.07)).frame(height: 1)

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("GENERATED BY DRUK APP")
                        .font(.system(size: 6.5, weight: .bold, design: .monospaced))
                        .tracking(1.2)
                    Text("图片由 Druk 微醺志 生成")
                        .font(.system(size: 6))
                }
                .foregroundColor(.primary.opacity(0.28))

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(data.personaName.uppercased() + " PERSONA")
                        .font(.system(size: 6.5, weight: .bold, design: .monospaced))
                        .tracking(1.2)
                    Text("BAC 理论值仅供参考")
                        .font(.system(size: 6))
                }
                .foregroundColor(.primary.opacity(0.28))
            }
        }
    }
}
