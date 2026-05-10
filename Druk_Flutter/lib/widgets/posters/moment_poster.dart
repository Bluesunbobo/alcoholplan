import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:druk/constants/app_colors.dart';

class BACMomentData {
  final DateTime timestamp;
  final double bacValue;
  final String stateZh;
  final String stateEn;
  final String quoteZh;
  final String quoteEn;
  final String personaName;
  final String personaZhName;
  final String personaAvatarImage;

  BACMomentData({
    required this.timestamp,
    required this.bacValue,
    required this.stateZh,
    required this.stateEn,
    required this.quoteZh,
    required this.quoteEn,
    required this.personaName,
    required this.personaZhName,
    required this.personaAvatarImage,
  });
}

class MomentPoster extends StatelessWidget {
  final BACMomentData data;

  const MomentPoster({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM dd, yyyy').format(data.timestamp).toUpperCase();
    final timeStr = DateFormat('HH:mm').format(data.timestamp);
    final glowOpacity = (0.18 * (data.bacValue * 10).clamp(0.0, 1.0));

    return Container(
      width: 400,
      height: 720,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfaceDim,
      ),
      child: Stack(
        children: [
          // ── Background Layers ──────────────────
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.0, -1.0),
                  radius: 1.0,
                  colors: [
                    AppColors.primary.withOpacity(glowOpacity),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),

          // ── Content Layers ─────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 44.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Druk 微醺志',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'MOMENT LEDGER / $dateStr',
                        style: GoogleFonts.robotoMono(
                          fontSize: 8,
                          letterSpacing: 3.5,
                          color: AppColors.onSurface.withOpacity(0.35),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),

                // Data Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 3,
                      height: 180,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ESTIMATED BAC',
                          style: GoogleFonts.robotoMono(
                            fontSize: 8,
                            letterSpacing: 2.0,
                            color: AppColors.primary.withOpacity(0.4),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              data.bacValue.toStringAsFixed(3),
                              style: GoogleFonts.robotoMono(
                                fontSize: 72,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '%',
                              style: GoogleFonts.robotoMono(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              data.stateZh,
                              style: GoogleFonts.notoSerifSc(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              data.stateEn,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 18,
                                fontStyle: FontStyle.italic,
                                color: AppColors.primary.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'LOGGED AT $timeStr',
                          style: GoogleFonts.robotoMono(
                            fontSize: 9,
                            letterSpacing: 3.0,
                            color: AppColors.onSurface.withOpacity(0.25),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const Spacer(),

                // Quote Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '“${data.quoteZh}”',
                      style: GoogleFonts.notoSerifSc(
                        fontSize: 24,
                        fontStyle: FontStyle.italic,
                        color: AppColors.onSurface.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '"${data.quoteEn.toUpperCase()}"',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                        color: AppColors.onSurfaceVariant.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),

                const Spacer(flex: 2),

                // Footer
                Column(
                  children: [
                    Text(
                      'NEVER DRINK AND DRIVE  ·  切勿酒后驾驶',
                      style: GoogleFonts.robotoMono(
                        fontSize: 7,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 3.5,
                        color: AppColors.primary.withOpacity(0.25),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Divider(color: Colors.white.withOpacity(0.08)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                                image: DecorationImage(
                                  image: AssetImage('assets/images/${data.personaAvatarImage}.png'),
                                  colorFilter: const ColorFilter.matrix([
                                    0.2126, 0.7152, 0.0722, 0, 0,
                                    0.2126, 0.7152, 0.0722, 0, 0,
                                    0.2126, 0.7152, 0.0722, 0, 0,
                                    0,      0,      0,      1, 0,
                                  ]), // Grayscale
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data.personaZhName,
                                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  data.personaName.toUpperCase(),
                                  style: GoogleFonts.robotoMono(fontSize: 7, color: Colors.white.withOpacity(0.4)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'DRUK MICRO-LOG',
                              style: GoogleFonts.robotoMono(fontSize: 7, fontWeight: FontWeight.bold, color: AppColors.primary.withOpacity(0.3)),
                            ),
                            Text(
                              '理论值仅供参考',
                              style: TextStyle(fontSize: 6, color: AppColors.primary.withOpacity(0.3)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
