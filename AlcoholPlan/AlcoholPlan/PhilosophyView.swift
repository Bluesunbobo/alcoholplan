import SwiftUI

struct PhilosophyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.surfaceDim.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Branded Header
                VStack(spacing: 12) {
                    Image("whiskey_glass")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.white.opacity(0.1), Color.clear]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .background(Color.black.opacity(0.8))
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.white.opacity(0.3), .clear, .white.opacity(0.1)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 0.5
                                )
                        )
                        .shadow(color: .primary.opacity(0.4), radius: 30) // Ambient Glow Effect
                        .shadow(color: .black.opacity(0.5), radius: 15, x: 0, y: 10) // 3D Physical Shadow
                        .padding(.top, 40)
                    
                    Text("Druk 微醺志")
                        .font(.system(size: 28, weight: .medium, design: .serif).italic())
                        .foregroundColor(.primary)
                    
                    Text("OUR PHILOSOPHY")
                        .font(.system(size: 9, design: .monospaced))
                        .tracking(4.0)
                        .foregroundColor(.onSurfaceVariant.opacity(0.4))
                        .padding(.bottom, 32)
                }
                .frame(maxWidth: .infinity)
                .overlay(alignment: .topTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white.opacity(0.2))
                            .padding(24)
                    }
                }
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Hero Quote Card (Finn Skårderud)
                        VStack(alignment: .leading, spacing: 16) {
                            Text("“寻找那 0.05% 的本真”")
                                .font(.system(size: 20, weight: .bold, design: .serif).italic())
                                .foregroundColor(.primary)
                            
                            Text("电影《酒精计划》(Druk) 提出了一个迷人的假说：人类生来血液中就缺少 0.05% 的酒精浓度。这微小的差值，正是通往创造力与生命热情的“黄金点”。")
                                .font(.system(size: 15))
                                .foregroundColor(.onSurface)
                                .lineSpacing(6)
                            
                            Text("The movie \"Another Round\" suggests a fascinating hypothesis: humans are born with a 0.05% alcohol deficit.")
                                .font(.system(size: 12, design: .serif).italic())
                                .foregroundColor(.onSurfaceVariant.opacity(0.5))
                        }
                        .padding(28)
                        .background(Color.white.opacity(0.04))
                        .cornerRadius(24)
                        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.05), lineWidth: 1))

                        // Reflection Card
                        PhilosophyCapsuleCard(
                            titleZh: "镜鉴与警示",
                            titleEn: "MIRROR & WARNING",
                            contentZh: "酒精是一面镜子，映照出被生活磨平的少年意气，也可能成为溺毙理性的深渊。微醺志，是为了在诗意与失控之间，留出一寸清醒的余地。",
                            contentEn: "Alcohol is a mirror reflecting youthful spirit but also a potential abyss for reason. Druk is designed to find clarity between poetry and chaos."
                        )
                        
                        PhilosophyCapsuleCard(
                            titleZh: "喝了再写，醒了再改",
                            titleEn: "WRITE DRUNK, EDIT SOBER",
                            contentZh: "人生亦即如此。我们并非追求沉沦，而是追求在科学的边界内，敢于面对真实的自我。",
                            contentEn: "Such is life. We seek not to drown, but to face our authentic selves within scientific boundaries."
                        )

                        // Footer Quote
                        VStack(spacing: 32) {
                            VStack(spacing: 8) {
                                Text("“酒以见性，水以养生”")
                                    .font(.system(size: 16, weight: .medium, design: .serif))
                                    .foregroundColor(.onSurfaceVariant.opacity(0.8))
                                
                                Text("\"In vino veritas, in aqua sanitas.\"")
                                    .font(.system(size: 12, design: .serif).italic())
                                    .foregroundColor(.onSurfaceVariant.opacity(0.4))
                            }
                            
                            VStack(spacing: 12) {
                                Text("DRUK PHILOSOPHY BOARD")
                                    .font(.system(size: 9, design: .monospaced))
                                    .tracking(2.0)
                                    .foregroundColor(.primary.opacity(0.4))
                                
                                Text("CRAFTED VIA MULTI-AI COLLABORATION")
                                    .font(.system(size: 7, design: .monospaced))
                                    .opacity(0.2)
                            }
                        }
                        .padding(.top, 40)
                        .padding(.bottom, 60)
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
    }
}

struct PhilosophyCapsuleCard: View {
    let titleZh: String
    let titleEn: String
    let contentZh: String
    let contentEn: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 2) {
                Text(titleZh)
                    .font(.system(size: 18, weight: .bold, design: .serif).italic())
                    .foregroundColor(.primary)
                Text(titleEn)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.primary.opacity(0.4))
                    .textCase(.uppercase)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(contentZh)
                    .font(.system(size: 15))
                    .foregroundColor(.onSurface)
                    .lineSpacing(5)
                Text(contentEn)
                    .font(.system(size: 12, design: .serif).italic())
                    .foregroundColor(.onSurfaceVariant.opacity(0.6))
                    .lineSpacing(3)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.03))
        .cornerRadius(24)
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.05), lineWidth: 1))
    }
}

#Preview {
    PhilosophyView()
        .preferredColorScheme(.dark)
}
