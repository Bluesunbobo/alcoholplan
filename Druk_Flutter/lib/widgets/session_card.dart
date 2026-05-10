import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:druk/constants/app_colors.dart';
import 'package:druk/logic/alcohol_brain.dart';
import 'package:druk/widgets/glass_card.dart';
import 'package:druk/widgets/share_poster.dart';

class SessionCard extends StatelessWidget {
  final DrinkSession session;

  const SessionCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MM月 dd日 HH:mm').format(session.startTime);
    final occasionTag = session.occasion ?? "朋友聚会";

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateStr,
                    style: GoogleFonts.robotoMono(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.amberGold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.amberGold.withOpacity(0.3), width: 0.5),
                    ),
                    child: Text(
                      occasionTag,
                      style: GoogleFonts.notoSerifSc(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppColors.amberGold,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      final brain = Provider.of<AlcoholBrain>(context, listen: false);
                      ShareService.shareSession(
                        context: context, 
                        brain: brain, 
                        historySession: session
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.ios_share, 
                        size: 14, 
                        color: AppColors.amberGold.withOpacity(0.5)
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'PEAK BAC',
                        style: GoogleFonts.robotoMono(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface.withOpacity(0.4),
                        ),
                      ),
                      Text(
                        '峰值',
                        style: GoogleFonts.notoSerifSc(
                          fontSize: 10,
                          color: AppColors.amberGold,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            session.peakBAC.toStringAsFixed(3),
                            style: GoogleFonts.robotoMono(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.amberGold,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '%',
                            style: GoogleFonts.robotoMono(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.amberGold.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          Divider(color: Colors.white.withOpacity(0.05), height: 1),
          const SizedBox(height: 16),
          

          // ── Drink Log ─────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DRINK LOG',
                style: GoogleFonts.robotoMono(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: AppColors.onSurface.withOpacity(0.4),
                ),
              ),
              Text(
                '饮酒日志',
                style: GoogleFonts.notoSerifSc(
                  fontSize: 10,
                  color: AppColors.amberGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: session.entries.map((e) => _buildDrinkItem(e)).toList(),
            ),
          ),

          const SizedBox(height: 20),
          
          // ── Hangover Footer ───────────────
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 12,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.mood_outlined, size: 14, color: AppColors.amberGold),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HANGOVER FEELING',
                        style: GoogleFonts.robotoMono(
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface.withOpacity(0.4),
                        ),
                      ),
                      Text(
                        '宿醉感',
                        style: GoogleFonts.notoSerifSc(
                          fontSize: 9,
                          color: AppColors.amberGold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  final emojis = ['😃', '😐', '🥴', '🤢', '🤮'];
                  final isActive = (session.hangoverScore ?? -1) == index;
                  return GestureDetector(
                    onTap: () {
                      Provider.of<AlcoholBrain>(context, listen: false)
                          .updateSessionHangover(session.id, index);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: isActive ? 1.0 : 0.15,
                        child: Text(emojis[index], style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrinkItem(DrinkEntryData entry) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${entry.volumeML.toInt()} ml',
            style: GoogleFonts.robotoMono(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.amberGold,
            ),
          ),
          Text(
            '${(entry.abv * 100).toStringAsFixed(1)}%',
            style: GoogleFonts.robotoMono(
              fontSize: 9,
              color: AppColors.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}
