import SwiftUI

struct PosterPreviewSheet: View {
    let images: [UIImage]
    @Environment(\.dismiss) private var dismiss
    @State private var selectedIndex = 0
    @State private var showingSavedAlert = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var isSaving = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.surfaceDim.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Preview Header
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("POSTER PREVIEW")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .tracking(2.0)
                            Text("/ 海报预览")
                                .font(.system(size: 10, design: .monospaced))
                                .opacity(0.5)
                        }
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundColor(.onSurface.opacity(0.3))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    
                    // The Image Layer
                    TabView(selection: $selectedIndex) {
                        ForEach(0..<images.count, id: \.self) { index in
                            ScrollView(.vertical, showsIndicators: false) {
                                Image(uiImage: images[index])
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)
                                    .padding(.horizontal, 32)
                                    .padding(.vertical, 12)
                            }
                            .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        // Main Download Button
                        Button(action: saveToPhotos) {
                            HStack(spacing: 10) {
                                if isSaving {
                                    ProgressView()
                                        .tint(.surfaceDim)
                                } else {
                                    Image(systemName: "square.and.arrow.down.fill")
                                }
                                Text("DOWNLOAD / 保存海报")
                            }
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.surfaceDim)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.primary)
                            .clipShape(Capsule())
                        }
                        .disabled(isSaving)
                        
                        // Fallback Share Button
                        Button(action: {
                            presentSystemShare()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "ellipsis.circle")
                                Text("SYSTEM SHARE / 系统分享")
                            }
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundColor(.primary.opacity(0.8))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .stroke(Color.primary.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
            .alert("Success / 保存成功", isPresented: $showingSavedAlert) {
                Button("OK") { }
            } message: {
                Text("Poster has been saved to your photo library. / 海报已保存至相册。")
            }
            .alert("Error / 保存失败", isPresented: $showingErrorAlert) {
                Button("OK") { }
            } message: {
                Text("\(errorMessage)\n\n请检查 Xcode 项目设置中是否已添加 Photo Library 权限声明。")
            }
        }
    }
    
    private func saveToPhotos() {
        guard selectedIndex < images.count else { return }
        isSaving = true
        PosterRenderer.shared.saveImageToPhotos(images[selectedIndex]) { success, error in
            DispatchQueue.main.async {
                isSaving = false
                if success {
                    showingSavedAlert = true
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                } else {
                    errorMessage = error?.localizedDescription ?? "Unknown Error"
                    showingErrorAlert = true
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                }
            }
        }
    }
    
    private func presentSystemShare() {
        guard selectedIndex < images.count else { return }
        let activityVC = UIActivityViewController(activityItems: [images[selectedIndex]], applicationActivities: nil)
        
        // Find the top-most view controller to present from
        var topVC = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?.rootViewController
        
        while let presentedVC = topVC?.presentedViewController {
            topVC = presentedVC
        }
        
        if let controller = topVC {
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = controller.view
                popover.sourceRect = CGRect(x: controller.view.bounds.midX, y: controller.view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            controller.present(activityVC, animated: true)
        }
    }
}
