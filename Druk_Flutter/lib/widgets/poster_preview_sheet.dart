import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:druk/constants/app_colors.dart';
import 'package:druk/services/poster_service.dart';
import 'glass_card.dart';
import 'posters/moment_poster.dart';

class PosterPreviewSheet extends StatefulWidget {
  final BACMomentData data;

  const PosterPreviewSheet({super.key, required this.data});

  @override
  State<PosterPreviewSheet> createState() => _PosterPreviewSheetState();
}

class _PosterPreviewSheetState extends State<PosterPreviewSheet> {
  final GlobalKey _posterKey = GlobalKey();
  bool _isExporting = false;

  Future<void> _handleSave() async {
    setState(() => _isExporting = true);
    final bytes = await PosterService.captureWidget(_posterKey);
    if (bytes != null) {
      final success = await PosterService.saveToGallery(bytes, 'Druk_Moment_${DateTime.now().millisecondsSinceEpoch}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(success ? 'Saved to Gallery / 已保存至相册' : 'Save Failed / 保存失败')),
        );
      }
    }
    setState(() => _isExporting = false);
  }

  Future<void> _handleShare() async {
    setState(() => _isExporting = true);
    final bytes = await PosterService.captureWidget(_posterKey);
    if (bytes != null) {
      await PosterService.shareImage(bytes, 'Druk_Share');
    }
    setState(() => _isExporting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDim,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          
          // Poster Preview Area
          SizedBox(
            height: 450, // Scaled down for preview
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Center(
                child: Transform.scale(
                  scale: 0.6, // Preview scale
                  child: RepaintBoundary(
                    key: _posterKey,
                    child: MomentPoster(data: widget.data),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    label: 'SAVE',
                    icon: Icons.download,
                    onTap: _isExporting ? null : _handleSave,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    label: 'SHARE',
                    icon: Icons.share,
                    isPrimary: true,
                    onTap: _isExporting ? null : _handleShare,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback? onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: isPrimary ? null : Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isPrimary ? AppColors.onPrimary : Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.robotoMono(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isPrimary ? AppColors.onPrimary : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
