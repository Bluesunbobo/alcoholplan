import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:druk/constants/app_colors.dart';
import 'package:druk/logic/alcohol_brain.dart';
import 'package:druk/widgets/bac_chart.dart';
import 'package:druk/widgets/glass_card.dart';

class CurveScreen extends StatefulWidget {
  const CurveScreen({super.key});

  @override
  State<CurveScreen> createState() => _CurveScreenState();
}

class _CurveScreenState extends State<CurveScreen> {
  late final Stream<DateTime> _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final brain = Provider.of<AlcoholBrain>(context);
    final isAbsorbing = !brain.isSoberingDown && brain.bacPercentage > 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 82),
              
              // ── Header ────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '清醒曲线',
                    style: GoogleFonts.notoSerifSc(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '/ The Sobriety Curve',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: AppColors.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '实时血液酒精估算与代谢恢复预测 / Real-time\nblood alcohol estimation and metabolic recovery\nprojection.',
                style: GoogleFonts.notoSerifSc(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                  color: AppColors.amberGold.withOpacity(0.8),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // ── Status Card (Estimated BAC) ───
              _buildStatusCard(brain, isAbsorbing),
              
              const SizedBox(height: 24),
              
              // ── Main Timeline Card ────────────
              _buildTimelineCard(brain),
              
              const SizedBox(height: 24),

              // ── Legal Safety Countdown ────────
              _buildDistanceToSafety(brain),
              
              const SizedBox(height: 24),

              // ── Bottom Stats Row ──────────────
              Row(
                children: [
                  Expanded(child: _buildSmallStat(Icons.water_drop, '本次摄入', 'SESSION INTAKE', '${brain.totalLiquidVolumeML.toInt()}', 'ml')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSmallStat(Icons.trending_up, '峰值时刻', 'PEAK INTENSITY', brain.peakBACTime != null && brain.bacPercentage > 0 ? _formatTime(brain.peakBACTime!) : '--:--', '')),
                ],
              ),
              
              const SizedBox(height: 140),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(AlcoholBrain brain, bool isAbsorbing) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
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
                    'ESTIMATED BAC',
                    style: GoogleFonts.robotoMono(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.onSurface.withOpacity(0.4)),
                  ),
                  Text(
                    '预计 BAC',
                    style: GoogleFonts.notoSerifSc(fontSize: 10, color: AppColors.amberGold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'STATUS',
                    style: GoogleFonts.robotoMono(fontSize: 7, fontWeight: FontWeight.bold, color: AppColors.onSurface.withOpacity(0.3)),
                  ),
                  Text(
                    '系统状态',
                    style: GoogleFonts.notoSerifSc(fontSize: 8, color: AppColors.amberGold.withOpacity(0.6)),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    brain.bacPercentage > 0 ? (isAbsorbing ? '吸收中' : '代谢中') : '清醒',
                    style: GoogleFonts.notoSerifSc(fontSize: 11, color: AppColors.onSurface),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '|',
                    style: TextStyle(color: AppColors.onSurface.withOpacity(0.2)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    brain.bacPercentage > 0 ? (isAbsorbing ? 'Absorbing' : 'Metabolizing') : 'Sober',
                    style: GoogleFonts.robotoMono(fontSize: 10, color: AppColors.onSurface.withOpacity(0.5)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                brain.bacPercentage.toStringAsFixed(3),
                style: GoogleFonts.robotoMono(fontSize: 64, fontWeight: FontWeight.w900, color: AppColors.amberGold),
              ),
              const SizedBox(width: 4),
              Text(
                '%',
                style: GoogleFonts.robotoMono(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.amberGold.withOpacity(0.6)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(AlcoholBrain brain) {
    final points = brain.getChartPoints();
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BAC TIMELINE',
            style: GoogleFonts.robotoMono(fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.onSurface.withOpacity(0.4)),
          ),
          Text(
            '浓度变化轴',
            style: GoogleFonts.notoSerifSc(fontSize: 10, color: AppColors.amberGold),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 300,
            child: points.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.show_chart, color: AppColors.primary.withOpacity(0.1), size: 48),
                      const SizedBox(height: 16),
                      Text(
                        '无可用数据 / No data available',
                        style: GoogleFonts.robotoMono(fontSize: 11, color: AppColors.onSurface.withOpacity(0.3)),
                      ),
                    ],
                  ),
                )
              : BACChart(
                  points: points,
                  country: brain.country,
                  startTime: brain.drinks.isNotEmpty ? brain.drinks.first.timestamp : null,
                  soberTime: brain.soberDate,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceToSafety(AlcoholBrain brain) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.security, color: AppColors.amberGold, size: 20),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LEGAL SAFETY COUNTDOWN',
                    style: GoogleFonts.robotoMono(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.onSurface.withOpacity(0.4)),
                  ),
                  Text(
                    '法律安全标准倒计时',
                    style: GoogleFonts.notoSerifSc(fontSize: 10, color: AppColors.amberGold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '距离法定驾驶标准',
                style: GoogleFonts.notoSerifSc(fontSize: 12, color: AppColors.onSurface.withOpacity(0.5)),
              ),
              Builder(
                builder: (context) {
                  final now = DateTime.now();
                  if (brain.safeDate == null || now.isAfter(brain.safeDate!) || brain.bacPercentage < brain.country.duiLimit) {
                    return Text(
                      '已达标 / Safe',
                      style: GoogleFonts.robotoMono(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.onSurface.withOpacity(0.4)),
                    );
                  }
                  final d = brain.safeDate!.difference(now);
                  final h = d.inHours;
                  final m = d.inMinutes.remainder(60);
                  final s = d.inSeconds.remainder(60);
                  return Text(
                    '${h}h ${m}m ${s}s',
                    style: GoogleFonts.robotoMono(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.amberGold),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStat(IconData icon, String zh, String en, String value, String unit) {
    return GlassCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.amberGold.withOpacity(0.6), size: 24),
          const SizedBox(height: 28),
          Text(en, style: GoogleFonts.robotoMono(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.onSurface.withOpacity(0.4))),
          Text(zh, style: GoogleFonts.notoSerifSc(fontSize: 10, color: AppColors.amberGold)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.robotoMono(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.amberGold),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: GoogleFonts.robotoMono(fontSize: 10, color: AppColors.amberGold.withOpacity(0.6)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) => '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
