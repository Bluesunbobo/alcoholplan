import SwiftUI

struct CinematicIntroView: View {
    @ObservedObject var userSettings: UserSettings

    @State private var showQuote = false
    @State private var showQuoteTranslation = false
    @State private var showOriginalQuote = false
    @State private var showCite = false
    @State private var showPrompt = false

    // Cinematic palette
    private let ivoryWarm  = Color(red: 0.97, green: 0.93, blue: 0.85)
    private let amberGold  = Color(red: 0.85, green: 0.65, blue: 0.30)
    private let silverGray = Color(red: 0.80, green: 0.80, blue: 0.82)

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // ── QUOTE BLOCK ──────────────────────────────────────
                VStack(spacing: 28) {

                    // Chinese — warm ivory, largest, most iconic
                    if showQuote {
                        Text("\u{201c}人类生来血液中就缺少 0.05% 的酒精。\u{201d}")
                            .font(.system(size: 24, weight: .regular, design: .serif))
                            .foregroundColor(ivoryWarm)
                            .multilineTextAlignment(.center)
                            .lineSpacing(10)
                            .padding(.horizontal, 40)
                            .transition(.opacity.animation(.easeInOut(duration: 2.5)))
                    }

                    // English — pure white, italic, clearly readable
                    if showQuoteTranslation {
                        Text("Humans are born with a blood\nalcohol level that is 0.05% too low.")
                            .font(.system(size: 16, weight: .light, design: .serif).italic())
                            .foregroundColor(.white.opacity(0.80))
                            .multilineTextAlignment(.center)
                            .lineSpacing(7)
                            .padding(.horizontal, 44)
                            .transition(.opacity.animation(.easeInOut(duration: 2.5)))
                    }

                    // Norwegian — silver-gray, clearly legible
                    if showOriginalQuote {
                        Text("Mennesker er f\u{00f8}dt med et underskudd\np\u{00e5} 0,5 promille alkohol i blodet.")
                            .font(.system(size: 14, weight: .light, design: .serif).italic())
                            .foregroundColor(silverGray)
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)
                            .padding(.horizontal, 44)
                            .transition(.opacity.animation(.easeInOut(duration: 2.5)))
                    }
                }

                // ── ATTRIBUTION BLOCK ─────────────────────────────────
                if showCite {
                    VStack(spacing: 10) {

                        // Amber divider line
                        Rectangle()
                            .fill(amberGold.opacity(0.6))
                            .frame(width: 36, height: 1)
                            .padding(.bottom, 6)

                        // Author — amber gold, prominent
                        Text("— Finn Sk\u{00e5}rderud")
                            .font(.system(size: 17, weight: .regular, design: .serif).italic())
                            .foregroundColor(amberGold)

                        // Film — silver monospaced
                        Text("DRUK  \u{00b7}  2020")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(silverGray)
                            .tracking(4.0)

                        // Chinese inspiration credit
                        Text("本应用（微醺志）开发思路源于电影《Druk》")
                            .font(.system(size: 11, weight: .light, design: .serif))
                            .foregroundColor(.white.opacity(0.60))
                            .padding(.top, 6)

                        // English credit
                        Text("INSPIRED BY THE CINEMATIC JOURNEY OF DRUK")
                            .font(.system(size: 9, weight: .light, design: .monospaced))
                            .foregroundColor(.white.opacity(0.40))
                            .tracking(1.5)
                    }
                    .padding(.top, 48)
                    .transition(.opacity.animation(.easeInOut(duration: 2.5)))
                }

                Spacer()
                Spacer()

                // ── PROMPT ────────────────────────────────────────────
                if showPrompt {
                    Text("TAP TO ENTER  \u{00b7}  轻触进入")
                        .font(.system(size: 11, weight: .light, design: .monospaced))
                        .tracking(3.0)
                        .foregroundColor(.white.opacity(0.55))
                        .opacity(showPrompt ? 1.0 : 0.0)
                        .animation(Animation.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: showPrompt)
                        .padding(.bottom, 50)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 1.2)) {
                userSettings.hasSeenCinematicIntro = true
            }
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation { showQuote = true }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                withAnimation { showQuoteTranslation = true }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 6.5) {
                withAnimation { showOriginalQuote = true }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 9.0) {
                withAnimation { showCite = true }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 12.0) {
                withAnimation { showPrompt = true }
            }
        }
    }
}
