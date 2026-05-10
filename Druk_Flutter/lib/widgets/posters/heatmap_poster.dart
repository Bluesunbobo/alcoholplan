import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:druk/constants/app_colors.dart';
import 'package:druk/logic/alcohol_brain.dart';
import 'package:druk/models/quotes_db.dart';
import 'package:intl/intl.dart';

class HeatmapPoster extends StatelessWidget {
  final AlcoholBrain brain;

  const HeatmapPoster({super.key, required this.brain});

  @override
  Widget build(BuildContext context) {
    final year = DateTime.now().year;
    final sessions = brain.getAllSessions().where((s) => s.startTime.year == year).toList();
    
    // Calculate total drinks and highest BAC
    int totalDrinks = sessions.length;
    double highestBAC = 0.0;
    for (var session in sessions) {
      if (session.peakBAC > highestBAC) highestBAC = session.peakBAC;
    }

    // Get a philosophical quote based on the persona
    final stateRange = QuotesDB.shared.getStateRange(
      bac: highestBAC,
      country: brain.country,
      isSoberingDown: false,
      persona: brain.persona,
    );
    final personaQuote = stateRange.quotes.isNotEmpty 
      ? stateRange.quotes.first 
      : const Quote(quote: "适量，是通往自由的最后防线。", translation: "Moderation is the final defense to freedom.", type: QuoteType.philosophic);

    return Container(
      width: 400,
      height: 720,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.surfaceDim,
        gradient: RadialGradient(
          colors: [AppColors.primary.withOpacity(0.12), Colors.transparent],
          center: Alignment.center,
          radius: 1.0,
        ),
      ),
      child: Column(
        children: [
          // ── Header ───────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Druk-微醺志',
                    style: GoogleFonts.notoSerifSc(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 1.0,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$year ANNUAL REPORT',
                    style: GoogleFonts.robotoMono(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                alignment: Alignment.center,
                child: Text(
                  'D',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          
          const Spacer(),

          // ── Hero Quote ───────────────────────────────────────
          Text(
            '"${personaQuote.quote}"',
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSerifSc(
              fontSize: 24,
              fontStyle: FontStyle.italic,
              color: AppColors.onSurface,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            personaQuote.translation.toUpperCase(),
            textAlign: TextAlign.center,
            style: GoogleFonts.robotoMono(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.primary.withOpacity(0.8),
              letterSpacing: 1.0,
              height: 1.5,
            ),
          ),
          
          const Spacer(),

          // ── Grid Section ─────────────────────────────────────
          _buildGridSection(sessions, year),
          
          const SizedBox(height: 24),

          // ── Stats Section ────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text('记录饮酒', style: GoogleFonts.notoSerifSc(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.onSurface.withOpacity(0.3))),
                      const SizedBox(height: 2),
                      Text('SESSIONS', style: GoogleFonts.robotoMono(fontSize: 8, letterSpacing: 1.5, color: AppColors.onSurface.withOpacity(0.2))),
                      const SizedBox(height: 10),
                      Text('$totalDrinks 次', style: GoogleFonts.robotoMono(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                    ],
                  ),
                ),
                Container(width: 1, height: 48, color: Colors.white.withOpacity(0.1)),
                Expanded(
                  child: Column(
                    children: [
                      Text('最高峰值', style: GoogleFonts.notoSerifSc(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.onSurface.withOpacity(0.3))),
                      const SizedBox(height: 2),
                      Text('HIGHEST BAC', style: GoogleFonts.robotoMono(fontSize: 8, letterSpacing: 1.5, color: AppColors.onSurface.withOpacity(0.2))),
                      const SizedBox(height: 10),
                      Text('${highestBAC.toStringAsFixed(3)}%', style: GoogleFonts.robotoMono(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),

          // ── Footer ───────────────────────────────────────────
          Text(
            '免责声明：本应用计算出的 BAC 理论值仅供娱乐和参考，不可作为判断是否涉及酒驾的标准。请以实际检测为准。切勿酒后驾驶。',
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSerifSc(fontSize: 6, color: Colors.white.withOpacity(0.15)),
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PHOTO GENERATED BY DRUK APP', style: GoogleFonts.robotoMono(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.primary.withOpacity(0.4), letterSpacing: 1.5)),
                  const SizedBox(height: 2),
                  Text('图片由 Druk 微醺志 生成', style: GoogleFonts.notoSerifSc(fontSize: 7, color: AppColors.primary.withOpacity(0.4))),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('ANNUAL REVIEW', style: GoogleFonts.robotoMono(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.primary.withOpacity(0.4), letterSpacing: 2.0)),
                  const SizedBox(height: 2),
                  Text('年度饮酒报告', style: GoogleFonts.notoSerifSc(fontSize: 7, color: AppColors.primary.withOpacity(0.4))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridSection(List<DrinkSession> sessions, int year) {
    Map<DateTime, double> dailyData = {};
    for (var session in sessions) {
      final date = DateTime(session.startTime.year, session.startTime.month, session.startTime.day);
      double totalGrams = session.entries.fold(0.0, (sum, e) => sum + (e.volumeML * e.abv * 0.789));
      dailyData[date] = (dailyData[date] ?? 0) + totalGrams;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FREQUENCY MATRIX / 饮酒频次矩阵',
          style: GoogleFonts.robotoMono(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: AppColors.primary.withOpacity(0.4),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withOpacity(0.05)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: AspectRatio(
            aspectRatio: 52 / 7,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 52,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
              ),
              itemCount: 52 * 7,
              itemBuilder: (context, index) {
                // Show trailing 364 days leading up to Dec 31 of the selected year
                final baseDate = DateTime(year, 12, 31);
                final date = baseDate.subtract(Duration(days: (52 * 7 - 1) - index));
                final normalizedDate = DateTime(date.year, date.month, date.day);
                final grams = dailyData[normalizedDate] ?? 0.0;
                
                return Container(
                  decoration: BoxDecoration(
                    color: _getColor(grams),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('轻微 / LIGHT', style: GoogleFonts.robotoMono(fontSize: 8, color: AppColors.onSurface.withOpacity(0.4))),
            const SizedBox(width: 4),
            Row(
              children: [0.0, 10.0, 30.0, 55.0, 100.0].map((g) => Container(
                width: 8, height: 8,
                margin: const EdgeInsets.only(right: 2),
                decoration: BoxDecoration(
                  color: _getColor(g),
                  borderRadius: BorderRadius.circular(2),
                ),
              )).toList(),
            ),
            const SizedBox(width: 4),
            Text('沉醉 / HEAVY', style: GoogleFonts.robotoMono(fontSize: 8, color: AppColors.onSurface.withOpacity(0.4))),
          ],
        ),
      ],
    );
  }

  Color _getColor(double grams) {
    if (grams <= 0) return AppColors.primary.withOpacity(0.05);
    if (grams < 20) return AppColors.primary.withOpacity(0.25);
    if (grams < 50) return AppColors.primary.withOpacity(0.5);
    if (grams < 100) return AppColors.primary.withOpacity(0.75);
    return AppColors.primary;
  }
}
