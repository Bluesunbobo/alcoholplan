import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:druk/constants/app_colors.dart';
import 'package:druk/logic/alcohol_brain.dart';
import 'glass_card.dart';

class RecordPanel extends StatefulWidget {
  const RecordPanel({super.key});

  @override
  State<RecordPanel> createState() => _RecordPanelState();
}

class _RecordPanelState extends State<RecordPanel> {
  int _selectedHangoverIndex = 2;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final brain = Provider.of<AlcoholBrain>(context);
    final canConfirm = brain.pendingVolumeML > 0;

    return GlassCard(
      padding: const EdgeInsets.all(28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Quick Select Grid ────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildDrinkCard(context, '🍺', 'BEER', '啤酒', 0.05, 330),
                const SizedBox(width: 12),
                _buildDrinkCard(context, '🍷', 'WINE', '红酒', 0.12, 150),
                const SizedBox(width: 12),
                _buildDrinkCard(context, '🥃', 'WHISKY', '威士忌', 0.40, 60),
                const SizedBox(width: 12),
                _buildDrinkCard(context, '🍶', 'SAKE', '清酒', 0.15, 180),
                const SizedBox(width: 12),
                _buildDrinkCard(context, '🍸', 'COCKTAIL', '鸡尾酒', 0.25, 150),
                const SizedBox(width: 12),
                _buildDrinkCard(context, '🔥', 'SHOT', '子弹杯', 0.40, 45),
                const SizedBox(width: 12),
                _buildDrinkCard(context, '🍶', 'BAIJIU', '白酒', 0.52, 20),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // ── ABV Slider ────────────────────────
          _buildSliderHeader(
            en: 'ALCOHOL BY VOLUME',
            zh: '酒精浓度 (ABV)',
            value: '${(brain.pendingABV * 100).toStringAsFixed(1)} %',
          ),
          const SizedBox(height: 4),
          _buildPillSlider(
            value: brain.pendingABV * 100,
            min: 1,
            max: 70,
            onChanged: (val) {
              brain.pendingABV = val / 100;
              brain.selectedDrinkId = 'CUSTOM';
              brain.syncSimulation();
              HapticFeedback.selectionClick();
            },
          ),
          const SizedBox(height: 24),

          // ── Volume Slider ─────────────────────
          _buildSliderHeader(
            en: 'SERVING AMOUNT',
            zh: '饮酒量',
            value: '${brain.pendingVolumeML.toInt()} ml',
            subtitle: brain.selectedDrinkId == 'BEER' ? '约一听罐装' :
                      brain.selectedDrinkId == 'WINE' ? '标准红酒杯' :
                      brain.selectedDrinkId == 'WHISKY' ? '双份烈酒杯' :
                      brain.selectedDrinkId == 'SAKE' ? '标准德利壶' :
                      brain.selectedDrinkId == 'COCKTAIL' ? '标准调酒杯' :
                      brain.selectedDrinkId == 'SHOT' ? '标准子弹杯' :
                      brain.selectedDrinkId == 'BAIJIU' ? '中式小白酒杯' : '自定义容量',
          ),
          const SizedBox(height: 4),
          _buildPillSlider(
            value: brain.pendingVolumeML,
            min: 0,
            max: 1000,
            onChanged: (val) {
              brain.pendingVolumeML = val;
              brain.selectedDrinkId = 'CUSTOM';
              brain.syncSimulation();
              HapticFeedback.selectionClick();
            },
          ),
          const SizedBox(height: 32),

          // ── Hangover Feeling ──────────────────
          Text(
            'HANGOVER FEELING',
            style: GoogleFonts.robotoMono(
              fontSize: 8,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '宿醉感',
            style: GoogleFonts.notoSerifSc(
              fontSize: 10,
              color: AppColors.amberGold,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(5, (index) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _buildEmojiCard(index),
              )),
            ),
          ),
          const SizedBox(height: 40),

          // ── Confirm Button (Optimized) ─────────
          GestureDetector(
            onTapDown: canConfirm ? (_) => setState(() => _isPressed = true) : null,
            onTapUp: canConfirm ? (_) => setState(() => _isPressed = false) : null,
            onTapCancel: canConfirm ? () => setState(() => _isPressed = false) : null,
            onTap: canConfirm ? () {
              brain.addDrink();
              HapticFeedback.heavyImpact();
            } : null,
            child: AnimatedScale(
              scale: _isPressed ? 0.96 : 1.0,
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeInOut,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: canConfirm 
                    ? AppColors.primary 
                    : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    if (canConfirm && _isPressed)
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: canConfirm ? 1.0 : 0.3,
                      child: Icon(
                        Icons.add_circle_outline, 
                        size: 16, 
                        color: canConfirm ? Colors.black : AppColors.onSurface
                      ),
                    ),
                    const SizedBox(width: 10),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: canConfirm ? 1.0 : 0.3,
                      child: Text(
                        'CONFIRM POUR  确认倒入',
                        style: GoogleFonts.robotoMono(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: canConfirm ? Colors.black : AppColors.onSurface,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrinkCard(BuildContext context, String emoji, String en, String zh, double abv, double defaultVolume) {
    final brain = Provider.of<AlcoholBrain>(context);
    bool isSelected = brain.selectedDrinkId == en;

    return GestureDetector(
      onTap: () {
        brain.pendingABV = abv;
        brain.pendingVolumeML = defaultVolume;
        brain.selectedDrinkId = en;
        brain.syncSimulation();
        HapticFeedback.mediumImpact();
      },
      child: Container(
        width: 76,
        height: 96,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.03) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary.withOpacity(0.5) : Colors.white.withOpacity(0.05),
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 6),
            Text(
              en,
              style: GoogleFonts.robotoMono(
                fontSize: 7,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primary : AppColors.onSurface.withOpacity(0.4),
              ),
            ),
            Text(
              zh,
              style: GoogleFonts.notoSerifSc(
                fontSize: 8,
                color: isSelected ? AppColors.primary.withOpacity(0.7) : AppColors.onSurface.withOpacity(0.2),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${defaultVolume.toInt()}ml',
                style: GoogleFonts.robotoMono(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.primary : AppColors.onSurface.withOpacity(0.3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderHeader({required String en, required String zh, required String value, String? subtitle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              en,
              style: GoogleFonts.robotoMono(
                fontSize: 8,
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface.withOpacity(0.4),
              ),
            ),
            Row(
              children: [
                Text(
                  zh,
                  style: GoogleFonts.notoSerifSc(
                    fontSize: 10,
                    color: AppColors.amberGold,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '($subtitle)',
                    style: GoogleFonts.notoSerifSc(
                      fontSize: 8,
                      color: AppColors.onSurface.withOpacity(0.3),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        Text(
          value,
          style: GoogleFonts.robotoMono(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildPillSlider({required double value, required double min, required double max, required ValueChanged<double> onChanged}) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: Colors.white.withOpacity(0.1),
        inactiveTrackColor: Colors.white.withOpacity(0.03),
        trackHeight: 1.5,
        thumbColor: Colors.white,
        thumbShape: const PillThumbShape(),
        overlayColor: Colors.transparent,
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildEmojiCard(int index) {
    final emojis = ['😃', '😐', '🥴', '🤢', '🤮'];
    bool isSelected = _selectedHangoverIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedHangoverIndex = index),
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary.withOpacity(0.4) : Colors.white.withOpacity(0.05),
          ),
        ),
        child: Center(
          child: Opacity(
            opacity: isSelected ? 1.0 : 0.3,
            child: Text(emojis[index], style: const TextStyle(fontSize: 20)),
          ),
        ),
      ),
    );
  }
}

class PillThumbShape extends SliderComponentShape {
  const PillThumbShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(20, 10);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final RRect rRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 24, height: 12),
      const Radius.circular(6),
    );
    canvas.drawRRect(rRect, paint);
  }
}
