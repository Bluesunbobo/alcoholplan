import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:druk/constants/app_colors.dart';

class IntroScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const IntroScreen({super.key, required this.onComplete});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> with SingleTickerProviderStateMixin {
  int _stage = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    
    // Total sequence compressed into ~5 seconds
    // Stage 0 -> 1 -> 2 -> 3 -> Complete
    _timer = Timer.periodic(const Duration(milliseconds: 1400), (timer) {
      if (_stage < 3) {
        if (mounted) setState(() => _stage++);
      } else {
        timer.cancel();
        _onComplete();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _onComplete() {
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _onComplete,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 1000),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            child: _buildStageContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildStageContent() {
    switch (_stage) {
      case 0:
        return _buildTextStep("酒以见性，水以养生。", "IN VINO VERITAS");
      case 1:
        return _buildTextStep("人类生来血液中就缺少 0.05% 的酒精。", "THE 0.05% HYPOTHESIS");
      case 2:
        return _buildTextStep("众鸟高飞尽，孤云独去闲。", "THE SOLITARY CLOUD");
      case 3:
        return Column(
          key: const ValueKey('brand_stage'),
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '微醺志',
              style: GoogleFonts.notoSerifSc(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: 10,
                color: AppColors.ivoryWarm,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'DRUK',
              style: GoogleFonts.playfairDisplay(
                fontSize: 14,
                letterSpacing: 6,
                fontWeight: FontWeight.bold,
                color: AppColors.amberGold,
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTextStep(String zh, String en) {
    return Container(
      key: ValueKey(zh),
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            zh,
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSerifSc(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: AppColors.ivoryWarm,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            en,
            textAlign: TextAlign.center,
            style: GoogleFonts.robotoMono(
              fontSize: 10,
              letterSpacing: 3.0,
              fontWeight: FontWeight.bold,
              color: AppColors.amberGold.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
