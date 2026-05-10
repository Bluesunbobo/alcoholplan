import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:druk/constants/app_colors.dart';

class MovieSplashScreen extends StatefulWidget {
  final VoidCallback onFinished;
  const MovieSplashScreen({super.key, required this.onFinished});

  @override
  State<MovieSplashScreen> createState() => _MovieSplashScreenState();
}

class _MovieSplashScreenState extends State<MovieSplashScreen> {
  // Use a simple double to track progress, driven by a hardware-independent Timer
  double _progress = 0.0;
  Timer? _timer;
  final int _totalDurationMs = 10000; // Fixed 10 seconds

  @override
  void initState() {
    super.initState();
    
    // Start after a short delay to ensure fonts and engine are ready
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      
      const int tickMs = 16;
      _timer = Timer.periodic(const Duration(milliseconds: tickMs), (timer) {
        setState(() {
          _progress += tickMs / _totalDurationMs;
          if (_progress >= 1.0) {
            _progress = 1.0;
            _timer?.cancel();
          }
        });
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Pure mathematical fade function (Curves.easeInOut)
  double _getOpacity(double start, double duration) {
    if (_progress < start) return 0.0;
    double t = ((_progress - start) / duration).clamp(0.0, 1.0);
    // Applying an EaseInOut curve manually: 3t^2 - 2t^3
    return t * t * (3 - 2 * t);
  }

  Widget _buildFixedStep({
    required String text,
    required TextStyle style,
    required double start,
    required double height,
  }) {
    final opacity = _getOpacity(start, 0.35); // Each text takes 3.5s to fade
    
    return Container(
      height: height,
      width: double.infinity,
      alignment: Alignment.center,
      child: Opacity(
        opacity: opacity,
        child: Text(text, textAlign: TextAlign.center, style: style),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505), // Slightly off-black for version verification
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onFinished,
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Step 1: Chinese - Fixed height prevents overlap
                    _buildFixedStep(
                      text: '“ 人类生来血液中就缺少 0.05% 的\n酒精。 ”',
                      start: 0.05,
                      height: 80,
                      style: GoogleFonts.notoSerifSc(
                        fontSize: 21,
                        height: 1.8,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.95),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Step 2: English
                    _buildFixedStep(
                      text: 'Humans are born with a blood alcohol level\nthat is 0.05% too low.',
                      start: 0.18,
                      height: 60,
                      style: GoogleFonts.notoSerif(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                        color: Colors.white.withOpacity(0.55),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Step 3: Danish
                    _buildFixedStep(
                      text: 'Mennesker er født med et underskudd\npå 0,5 promille alkohol i blodet.',
                      start: 0.30,
                      height: 50,
                      style: GoogleFonts.notoSerif(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                        color: Colors.white.withOpacity(0.35),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Step 4: Signature Block
                    Opacity(
                      opacity: _getOpacity(0.50, 0.30),
                      child: Column(
                        children: [
                          Container(width: 32, height: 1, color: AppColors.amberGold.withOpacity(0.4)),
                          const SizedBox(height: 20),
                          Text(
                            '— Finn Skårderud',
                            style: GoogleFonts.notoSerifSc(fontSize: 17, fontStyle: FontStyle.italic, color: AppColors.amberGold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'D R U K   ·   2 0 2 0',
                            style: GoogleFonts.robotoMono(fontSize: 10, letterSpacing: 2, color: Colors.white.withOpacity(0.3)),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Step 5: Inspired By
                    Opacity(
                      opacity: _getOpacity(0.70, 0.25),
                      child: Column(
                        children: [
                          Text(
                            '本应用（微醺志）开发思路源于电影《Druk》',
                            style: GoogleFonts.notoSerifSc(fontSize: 9, color: Colors.white.withOpacity(0.2)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'INSPIRED BY THE CINEMATIC JOURNEY OF DRUK',
                            style: GoogleFonts.robotoMono(fontSize: 7, color: Colors.white.withOpacity(0.15)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tap Hint
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: _progress < 0.85 ? 0.0 : ((_progress - 0.85) / 0.15).clamp(0.0, 0.6),
                child: Center(
                  child: Text(
                    'T A P   T O   E N T E R   ·   轻 触 进 入',
                    style: GoogleFonts.robotoMono(fontSize: 10, letterSpacing: 1.5, color: Colors.white.withOpacity(0.6)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
