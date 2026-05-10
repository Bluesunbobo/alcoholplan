import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:druk/constants/app_colors.dart';
import 'package:druk/widgets/glass_card.dart';
import 'package:druk/logic/alcohol_brain.dart';
import 'package:provider/provider.dart';
import 'package:druk/widgets/country_picker_sheet.dart';

class JurisdictionCard extends StatelessWidget {
  const JurisdictionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AlcoholBrain>(
      builder: (context, brain, _) {
        final country = brain.country;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '法律管辖区 / Jurisdiction',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: AppColors.ivoryWarm,
                  ),
                ),
                GestureDetector(
                  onTap: () => showCountryPickerSheet(context),
                  child: Text(
                    '地区 设置',
                    style: GoogleFonts.notoSerifSc(
                      fontSize: 11,
                      color: AppColors.silverGray.withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.public, color: AppColors.amberGold, size: 24),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${country.name}  /  ${country.enName}',
                              style: GoogleFonts.notoSerifSc(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.amberGold,
                              ),
                            ),
                            Text(
                              'DUI  ${country.duiLimitString}',
                              style: GoogleFonts.robotoMono(
                                fontSize: 10,
                                color: AppColors.onSurface.withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => showCountryPickerSheet(context),
                        child: Row(
                          children: [
                            Text(
                              '修改  /  CHANGE',
                              style: GoogleFonts.notoSerifSc(
                                fontSize: 10,
                                color: AppColors.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(height: 1, color: Colors.white.withOpacity(0.05)),
                  const SizedBox(height: 24),
                  
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: _buildThresholdItem(
                          labelZh: '醉酒驾驶',
                          labelEn: 'DRUNK DRIVING',
                          value: country.dwiLimitString,
                          isPrimary: true,
                        ),
                      ),
                      const SizedBox(width: 8), 
                      Expanded(
                        flex: 1,
                        child: _buildThresholdItem(
                          labelZh: '饮酒驾驶',
                          labelEn: 'DUI Threshold',
                          value: country.isProhibition ? 'ZERO' : country.duiLimitString,
                          isPrimary: false,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildThresholdItem({
    required String labelZh,
    required String labelEn,
    required String value,
    required bool isPrimary,
    TextAlign textAlign = TextAlign.start,
  }) {
    return Column(
      crossAxisAlignment: textAlign == TextAlign.start ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          labelEn.toUpperCase(),
          style: GoogleFonts.robotoMono(
            fontSize: 7,
            letterSpacing: 1.0,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface.withOpacity(0.4),
          ),
        ),
        Text(
          labelZh,
          style: GoogleFonts.notoSerifSc(
            fontSize: 10,
            color: AppColors.amberGold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.robotoMono(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: isPrimary ? AppColors.amberGold : AppColors.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

class DashboardStatsRow extends StatelessWidget {
  final String soberTime;
  final double intakeML;

  const DashboardStatsRow({
    super.key,
    required this.soberTime,
    required this.intakeML,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.timelapse,
            labelEn: 'EXPECTED SOBER',
            labelZh: '预计清醒',
            value: soberTime,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.water_drop,
            labelEn: 'SESSION INTAKE',
            labelZh: '本次摄入',
            value: '${intakeML.toInt()} ml',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String labelEn,
    required String labelZh,
    required String value,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.amberGold.withOpacity(0.6), size: 20),
          const SizedBox(height: 24),
          Text(
            labelEn,
            style: GoogleFonts.robotoMono(
              fontSize: 8,
              letterSpacing: 1.0,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface.withOpacity(0.4),
            ),
          ),
          Text(
            labelZh,
            style: GoogleFonts.notoSerifSc(
              fontSize: 10,
              color: AppColors.amberGold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.robotoMono(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.amberGold,
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardExtras extends StatelessWidget {
  const DashboardExtras({super.key});

  @override
  Widget build(BuildContext context) {
    final brain = Provider.of<AlcoholBrain>(context);
    
    // Format sober time as exact clock time (e.g., 22:30)
    String soberTimeStr = "--:--";
    if (brain.soberDate != null && brain.bacPercentage > 0) {
      soberTimeStr = "${brain.soberDate!.hour.toString().padLeft(2, '0')}:${brain.soberDate!.minute.toString().padLeft(2, '0')}";
    }

    return Column(
      children: [
        const JurisdictionCard(),
        const SizedBox(height: 24),
        DashboardStatsRow(
          soberTime: soberTimeStr,
          intakeML: brain.totalLiquidVolumeML,
        ),
      ],
    );
  }
}
