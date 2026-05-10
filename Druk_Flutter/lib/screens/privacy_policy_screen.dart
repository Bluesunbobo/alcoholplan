import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:druk/constants/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceDim,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.ivoryWarm),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '隐私政策 / Privacy Policy',
          style: GoogleFonts.notoSerifSc(fontSize: 16, color: AppColors.ivoryWarm),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              "数据收集",
              "DATA COLLECTION",
              "Druk（微醺志）是一款本地优先的应用。我们收集的饮酒记录、体重、性别等个人数据仅存储在您的设备本地。我们不会将这些数据上传到任何服务器或共享给第三方。",
            ),
            _buildSection(
              "权限说明",
              "PERMISSIONS",
              "应用可能需要‘通知’权限以便在您饮酒后发送预计清醒的提醒。‘存储’权限用于保存分享的海报图片。除此之外，应用不会访问您的联系人、地理位置或摄像头。",
            ),
            _buildSection(
              "用户责任",
              "DISCLAIMER",
              "本应用提供的 BAC 计算仅基于 Widmark 公式进行的理论估算。每个人的代谢能力存在显著差异。严禁将本应用作为判断是否可以酒后驾车的唯一依据。请始终坚持‘喝酒不开车，开车不喝酒’。",
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                "Last Updated: April 2026",
                style: GoogleFonts.robotoMono(fontSize: 10, color: AppColors.silverGray.withOpacity(0.3)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String titleZh, String titleEn, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titleEn,
            style: GoogleFonts.robotoMono(
              fontSize: 9,
              letterSpacing: 2.0,
              fontWeight: FontWeight.bold,
              color: AppColors.amberGold.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            titleZh,
            style: GoogleFonts.notoSerifSc(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.ivoryWarm,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: GoogleFonts.notoSerifSc(
              fontSize: 14,
              height: 1.6,
              color: AppColors.ivoryWarm.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
