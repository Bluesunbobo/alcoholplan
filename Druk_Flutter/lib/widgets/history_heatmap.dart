import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:druk/constants/app_colors.dart';
import 'package:druk/logic/alcohol_brain.dart';
import 'backfill_dialog.dart';

class HistoryHeatMap extends StatefulWidget {
  final List<DrinkSession> sessions;
  final bool isPosterMode;
  const HistoryHeatMap({
    super.key, 
    required this.sessions, 
    this.isPosterMode = false,
  });

  @override
  State<HistoryHeatMap> createState() => _HistoryHeatMapState();
}

class _HistoryHeatMapState extends State<HistoryHeatMap> {
  int _selectedYear = DateTime.now().year;
  int _heatmapClickCount = 0;
  Timer? _clickResetTimer;

  void _handleHeatmapTap() {
    setState(() {
      _heatmapClickCount++;
    });

    _clickResetTimer?.cancel();
    _clickResetTimer = Timer(const Duration(seconds: 2), () {
      setState(() {
        _heatmapClickCount = 0;
      });
    });

    if (_heatmapClickCount >= 7) {
      _heatmapClickCount = 0;
      _clickResetTimer?.cancel();
      _showBackfillDialog();
    }
  }

  void _showBackfillDialog() {
    HapticFeedback.heavyImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BackfillDialog(),
    );
  }

  @override
  void dispose() {
    _clickResetTimer?.cancel();
    super.dispose();
  }

  // Optimized Daily Data Mapping
  Map<String, double> get _dailyData {
    final Map<String, double> data = {};
    for (final session in widget.sessions) {
      final startTime = session.startTime.toLocal();
      if (startTime.year != _selectedYear) continue;
      
      // Strict YYYY-MM-DD key to ensure exact daily sync
      final dateKey = DateFormat('yyyy-MM-dd').format(startTime);
      final currentMax = data[dateKey] ?? 0.0;
      if (session.peakBAC > currentMax) {
        data[dateKey] = session.peakBAC;
      }
    }
    return data;
  }

  // Generate EXACT number of days for the year
  List<DateTime> get _yearDates {
    final DateTime firstDay = DateTime(_selectedYear, 1, 1);
    final DateTime lastDay = DateTime(_selectedYear, 12, 31);
    final int totalDays = lastDay.difference(firstDay).inDays + 1;

    return List.generate(
      totalDays,
      (i) => firstDay.add(Duration(days: i)),
    );
  }

  int get _sessionCountForYear =>
      widget.sessions.where((s) => s.startTime.year == _selectedYear).length;

  double get _annualAlcoholGrams =>
      widget.sessions
          .where((s) => s.startTime.year == _selectedYear)
          .fold(0.0, (sum, s) =>
              sum + s.entries.fold(0.0, (e, d) => e + (d.volumeML * d.abv * 0.789)));

  Color _getColor(double peakBAC) {
    if (peakBAC <= 0) return Colors.white.withOpacity(0.04);
    if (peakBAC < 0.02) return AppColors.amberGold.withOpacity(0.20);
    if (peakBAC < 0.04) return AppColors.amberGold.withOpacity(0.40);
    if (peakBAC < 0.06) return AppColors.amberGold.withOpacity(0.60);
    if (peakBAC < 0.08) return AppColors.amberGold.withOpacity(0.80);
    return AppColors.amberGold.withOpacity(1.0);
  }

  @override
  Widget build(BuildContext context) {
    final dailyData = _dailyData;
    final yearDates = _yearDates;
    final currentYear = DateTime.now().year;
    final yearStr = NumberFormat("#,###").format(_selectedYear);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──────────────────────────
        if (!widget.isPosterMode) ...[
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _selectedYear--),
                child: const Icon(Icons.chevron_left, size: 16, color: AppColors.amberGold),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$yearStr 饮酒频率 / VINTAGE FREQUENCY',
                  style: GoogleFonts.robotoMono(
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: AppColors.onSurface.withOpacity(0.4),
                  ),
                ),
              ),
              GestureDetector(
                onTap: _selectedYear < currentYear ? () => setState(() => _selectedYear++) : null,
                child: Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: _selectedYear < currentYear
                      ? AppColors.amberGold
                      : Colors.white.withOpacity(0.1),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$_sessionCountForYear 场次 / SESSIONS',
                style: GoogleFonts.robotoMono(
                  fontSize: 8.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.amberGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],

        // ── Full Year Matrix (Dynamic Row Calculation) ──
        GestureDetector(
          onTap: _handleHeatmapTap,
          behavior: HitTestBehavior.opaque,
          child: LayoutBuilder(
            builder: (context, constraints) {
              const int cols = 26;
              const double spacing = 2.0;
              final double cellWidth = (constraints.maxWidth - ((cols - 1) * spacing)) / cols;
              // Ensure 365 or 366 days fit into the grid
              final int rows = (yearDates.length / cols).ceil();
              
              return SizedBox(
                height: (cellWidth * rows) + ((rows - 1) * spacing),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    mainAxisSpacing: spacing,
                    crossAxisSpacing: spacing,
                    childAspectRatio: 1,
                  ),
                  itemCount: yearDates.length,
                  itemBuilder: (context, index) {
                    final date = yearDates[index];
                    final key = DateFormat('yyyy-MM-dd').format(date);
                    final peakBAC = dailyData[key] ?? 0.0;
                    
                    return Container(
                      decoration: BoxDecoration(
                        color: _getColor(peakBAC),
                        borderRadius: BorderRadius.circular(2.2),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // ── Legend ──────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('轻微 / LIGHT',
                style: GoogleFonts.robotoMono(
                    fontSize: 7.5, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.25))),
            const SizedBox(width: 6),
            ...List.generate(
              5,
              (i) => Container(
                width: 8.5,
                height: 8.5,
                margin: const EdgeInsets.only(left: 3),
                decoration: BoxDecoration(
                  color: _getColor([0.01, 0.03, 0.05, 0.07, 0.09][i]),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text('酣畅 / HEAVY',
                style: GoogleFonts.robotoMono(
                    fontSize: 7.5, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.25))),
          ],
        ),

        if (!widget.isPosterMode) ...[
          const SizedBox(height: 24),
          Divider(color: Colors.white.withOpacity(0.05), height: 1),
          const SizedBox(height: 20),

          // ── Annual Intensity ─────────────────
          Text(
            '年度总量 / ANNUAL INTENSITY',
            style: GoogleFonts.robotoMono(
              fontSize: 8.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: AppColors.onSurface.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${_annualAlcoholGrams.toInt()}',
                style: GoogleFonts.robotoMono(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'g',
                style: GoogleFonts.robotoMono(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface.withOpacity(0.5),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                '预计纯酒精 / EST. PURE ALCOHOL',
                style: GoogleFonts.robotoMono(
                  fontSize: 7.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.amberGold.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
