import SwiftUI

struct PrivacyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.surfaceDim.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("隐私政策 / PRIVACY POLICY")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .tracking(2.0)
                        .foregroundColor(.primary.opacity(0.8))
                    
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.2))
                    }
                }
                .padding(24)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Introduction
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Druk (微醺志) 是一款注重隐私的应用。我们相信，您的饮酒数据和心境记录纯属私密。")
                                .font(.system(size: 15, weight: .medium, design: .serif))
                                .foregroundColor(.onSurface)
                                .lineSpacing(6)
                            
                            Text("本政策说明了我们如何处理您的数据（或者说，我们如何不处理您的数据）。")
                                .font(.system(size: 13))
                                .foregroundColor(.onSurfaceVariant.opacity(0.7))
                        }
                        .padding(20)
                        .glassCard()

                        // Core Commitment Sections
                        PrivacySectionView(
                            title: "1. 数据本地化 (Local-First)",
                            icon: "lock.shield",
                            content: "您的所有 BAC 记录、饮酒轨迹、人格偏好及海报生成历史，均仅保存在您设备的本地数据库（Core Data）中。我们不提供任何云端同步服务，因此数据绝不会离开您的设备。"
                        )
                        
                        PrivacySectionView(
                            title: "2. 不收集个人信息",
                            icon: "person.crop.circle.badge.exclamationmark",
                            content: "Druk 无需注册，不要求绑定手机号、邮箱或社交账号。我们不收集您的姓名、精确地理位置、联系人列表或唯一设备标识符。"
                        )
                        
                        PrivacySectionView(
                            title: "3. 第三方服务与分享",
                            icon: "arrow.up.forward.circle",
                            content: "当您使用“海报分享”功能时，应用会生成图片并调用系统级分享组件。除非您主动分享，否则这些照片不会上传至任何服务器。本应用不包含任何第三方追踪或广告 SDK。"
                        )
                        
                        PrivacySectionView(
                            title: "4. 用户控制权",
                            icon: "trash",
                            content: "您可以随时在设置中清除所有饮酒会话。一旦您卸载本应用，所有本地存储的饮酒记录都将永久删除且不可恢复。"
                        )

                        // Footer Note
                        VStack(spacing: 8) {
                            Divider().background(Color.white.opacity(0.1))
                            Text("如有任何疑问，请联系我们：")
                                .font(.system(size: 11))
                                .foregroundColor(.onSurfaceVariant.opacity(0.5))
                            Text("SUPPORT@DRUK.APP")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(.primary.opacity(0.6))
                        }
                        .padding(.top, 24)
                        .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
    }
}

struct PrivacySectionView: View {
    let title: String
    let icon: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.primary)
            }
            .opacity(0.9)
            
            Text(content)
                .font(.system(size: 13))
                .foregroundColor(.onSurfaceVariant)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .glassCard()
    }
}

#Preview {
    PrivacyView()
        .preferredColorScheme(.dark)
}
