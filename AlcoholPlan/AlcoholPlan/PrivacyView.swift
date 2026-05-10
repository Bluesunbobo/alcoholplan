import SwiftUI

struct PrivacyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.surfaceDim.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Branded Header (Verified Gold Icon)
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
                    
                    Text("PRIVACY & COMPLIANCE")
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
                    VStack(spacing: 20) {
                        // Introduction
                        VStack(alignment: .leading, spacing: 10) {
                            Text("微醺志（Druk）是一款注重隐私的应用。本政策详细说明了我们如何保护您的数据，以符合全球法律标准。")
                                .font(.system(size: 15, weight: .medium, design: .serif))
                                .foregroundColor(.onSurface.opacity(0.9))
                            
                            Text("Druk is a privacy-focused app. This policy explains how we protect your data according to global standards.")
                                .font(.system(size: 12, design: .serif).italic())
                                .foregroundColor(.onSurfaceVariant.opacity(0.6))
                        }
                        .padding(24)
                        .background(Color.white.opacity(0.04))
                        .cornerRadius(24)
                        
                        // THE 7 CORE SECTIONS
                        PrivacyCapsuleCard(
                            titleZh: "1. 数据本地存储",
                            titleEn: "LOCAL DATA STORAGE",
                            contentZh: "摄入记录及配置数据均仅存储在本地设备（Core Data）中。数据绝不会离开您的设备。",
                            contentEn: "All intake records and profile data are stored exclusively on your local device."
                        )
                        
                        PrivacyCapsuleCard(
                            titleZh: "2. 不收集信息",
                            titleEn: "NO DATA COLLECTION",
                            contentZh: "本 App 无需注册，不收集姓名、精确位置或唯一标识符。我们不使用任何第三方追踪。",
                            contentEn: "No registration required. No personal information collected. No 3rd-party tracking."
                        )

                        PrivacyCapsuleCard(
                            titleZh: "3. 无账号体系",
                            titleEn: "NO ACCOUNT SYSTEM",
                            contentZh: "本应用无账号注册体系。不涉及账号注销。卸载 App 即可彻底销毁本地所有数据。",
                            contentEn: "No account system. No account deletion needed. All data is wiped upon uninstallation."
                        )
                        
                        PrivacyCapsuleCard(
                            titleZh: "4. 内容分享说明",
                            titleEn: "CONTENT SHARING",
                            contentZh: "分享通过 iOS 系统组件完成，本 App 不托管、不分发用户内容。因此不涉及 UGC 举报机制。",
                            contentEn: "Sharing is handled by iOS. We do not host or distribute user content."
                        )

                        PrivacyCapsuleCard(
                            titleZh: "5. 相册与媒体",
                            titleEn: "PHOTO LIBRARY ACCESS",
                            contentZh: "相册权限仅用于保存生成的微醺海报。我们不会读取或访问您的已有照片。",
                            contentEn: "Permissions are only for saving posters. We do not read or access your photos."
                        )

                        PrivacyCapsuleCard(
                            titleZh: "6. 地区法律标准",
                            titleEn: "REGIONAL JURISDICTIONS",
                            contentZh: "内置全球法律数据库，并针对禁酒地区提供强制性警示逻辑。使用即表示您同意遵守当地法规。",
                            contentEn: "Built-in jurisdictional database with mandatory warnings for prohibited regions."
                        )

                        PrivacyCapsuleCard(
                            titleZh: "7. 年龄要求",
                            titleEn: "AGE REQUIREMENT",
                            contentZh: "本应用仅限已达到法定饮酒年龄（18+）的成年人使用。",
                            contentEn: "Strictly for adults (18+). No data from minors is collected."
                        )

                        // Final Contact
                        VStack(spacing: 24) {
                            Link("bestskillz2000@gmail.com", destination: URL(string: "mailto:bestskillz2000@gmail.com")!)
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundColor(.primary.opacity(0.8))
                            
                            Text("DRUK DEVELOPMENT TEAM")
                                .font(.system(size: 9, design: .monospaced))
                                .tracking(2.0)
                                .foregroundColor(.onSurfaceVariant.opacity(0.3))
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 60)
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
    }
}

// Reusing PrivacyCapsuleCard from previous layout for legibility
struct PrivacyCapsuleCard: View {
    let titleZh: String
    let titleEn: String
    let contentZh: String
    let contentEn: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 2) {
                Text(titleZh)
                    .font(.system(size: 16, weight: .bold, design: .serif))
                    .foregroundColor(.primary)
                Text(titleEn)
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(.primary.opacity(0.4))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(contentZh)
                    .font(.system(size: 14))
                    .foregroundColor(.onSurface)
                    .lineSpacing(4)
                Text(contentEn)
                    .font(.system(size: 12, design: .serif).italic())
                    .foregroundColor(.onSurfaceVariant.opacity(0.6))
                    .lineSpacing(3)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.04))
        .cornerRadius(24)
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.05), lineWidth: 1))
    }
}

#Preview {
    PrivacyView()
        .preferredColorScheme(.dark)
}
