import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:druk/constants/app_colors.dart';
import 'package:druk/logic/alcohol_brain.dart';
import 'package:druk/widgets/posters/moment_poster.dart';
import 'package:druk/widgets/posters/heatmap_poster.dart';

class PosterPreviewSheet extends StatefulWidget {
  final BACMomentData posterData;

  const PosterPreviewSheet({super.key, required this.posterData});

  @override
  State<PosterPreviewSheet> createState() => _PosterPreviewSheetState();
}

class _PosterPreviewSheetState extends State<PosterPreviewSheet> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _isProcessing = false;

  final GlobalKey _momentKey = GlobalKey();
  final GlobalKey _heatmapKey = GlobalKey();

  Future<void> _captureAndShare() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final key = _currentIndex == 0 ? _momentKey : _heatmapKey;
      RenderRepaintBoundary boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/druk_poster_${DateTime.now().millisecondsSinceEpoch}.png').create();
      await file.writeAsBytes(pngBytes);

      final xfile = XFile(file.path);
      await Share.shareXFiles([xfile], text: 'Shared via Druk-微醺志');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error generating poster: $e')));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppColors.surfaceDim,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // ── Header ──────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'POSTER PREVIEW',
                      style: GoogleFonts.robotoMono(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      '/ 海报预览',
                      style: GoogleFonts.robotoMono(
                        fontSize: 10,
                        color: AppColors.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.cancel, color: AppColors.onSurface.withOpacity(0.3)),
                ),
              ],
            ),
          ),

          // ── Carousel ────────────────────────
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              children: [
                _buildPosterPreview(
                  RepaintBoundary(
                    key: _momentKey,
                    child: MomentPoster(data: widget.posterData),
                  ),
                ),
                _buildPosterPreview(
                  RepaintBoundary(
                    key: _heatmapKey,
                    child: HeatmapPoster(brain: Provider.of<AlcoholBrain>(context, listen: false)),
                  ),
                ),
              ],
            ),
          ),

          // ── Indicators ──────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(2, (index) {
              return Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == index ? AppColors.primary : AppColors.onSurface.withOpacity(0.2),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),

          // ── Action Buttons ──────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _buildMainButton(
                  icon: _isProcessing ? Icons.hourglass_empty : Icons.share_rounded,
                  label: _isProcessing ? "PROCESSING..." : "SHARE POSTER / 分享海报",
                  onPressed: _captureAndShare,
                ),
                const SizedBox(height: 12),
                _buildOutlineButton(
                  icon: Icons.cancel,
                  label: "CANCEL / 取消",
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPosterPreview(Widget poster) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: FittedBox(
            fit: BoxFit.contain,
            child: poster,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder(String title) {
    return Center(
      child: Container(
        width: 300,
        height: 500,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
            const SizedBox(height: 24),
            Text(
              "Brewing $title...",
              style: GoogleFonts.robotoMono(
                fontSize: 11,
                color: AppColors.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainButton({required IconData icon, required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surfaceDim,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.robotoMono(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildOutlineButton({required IconData icon, required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary.withOpacity(0.8),
          side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.robotoMono(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
