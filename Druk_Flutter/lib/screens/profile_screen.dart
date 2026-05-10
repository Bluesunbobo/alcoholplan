import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:druk/constants/app_colors.dart';
import 'package:druk/logic/alcohol_brain.dart';
import 'package:druk/widgets/glass_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brain = Provider.of<AlcoholBrain>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 72),
              
              // ── Header (Settings / 设定) ────────
              _buildMainHeader(),
              
              const SizedBox(height: 48),

              // ── Section 1: The Persona ────────
              _buildSectionHeader('人格档案', 'The Persona', '身份路径'),
              const SizedBox(height: 24),
              _buildPersonaScroll(),
              const SizedBox(height: 28),
              _buildPhilosopherQuote(),
              
              const SizedBox(height: 52),

              // ── Section 2: The Anatomy ────────
              _buildSectionHeader('生物特征', 'The Anatomy', '生物特质'),
              const SizedBox(height: 24),
              _buildAnatomyCard(brain),
              
              const SizedBox(height: 52),

              // ── Section 3: Metabolism ─────────
              _buildSectionHeader('代谢速率', 'Metabolism', '代谢等级'),
              const SizedBox(height: 24),
              _buildMetabolismList(brain),
              
              const SizedBox(height: 20),
              _buildMetabolismNote(),

              const SizedBox(height: 100),

              // ── Footer ────────────────────────
              _buildFooter(brain),
              
              const SizedBox(height: 140),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          'Settings',
          style: GoogleFonts.playfairDisplay(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(width: 14),
        Text(
          '/ 设定',
          style: GoogleFonts.notoSerifSc(
            fontSize: 16,
            color: AppColors.onSurface.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String zh, String en, String sub) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(zh, style: GoogleFonts.notoSerifSc(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
            const SizedBox(width: 8),
            Text('/ $en', style: GoogleFonts.playfairDisplay(fontSize: 16, fontStyle: FontStyle.italic, color: AppColors.onSurface.withOpacity(0.5))),
          ],
        ),
        Text(sub, style: GoogleFonts.notoSerifSc(fontSize: 9, letterSpacing: 0.5, color: AppColors.onSurface.withOpacity(0.15))),
      ],
    );
  }

  Widget _buildPersonaScroll() {
    final personas = [
      {'name': '马丁', 'en': 'MARTIN', 'active': true, 'img': 'https://api.dicebear.com/7.x/avataaars/png?seed=Martin'},
      {'name': '尼古拉', 'en': 'NIKOLAI', 'active': false, 'img': 'https://api.dicebear.com/7.x/avataaars/png?seed=Nikolai'},
      {'name': '海明', 'en': 'ERNEST', 'active': false, 'img': 'https://api.dicebear.com/7.x/avataaars/png?seed=Ernest'},
      {'name': '维特', 'en': 'WERTHER', 'active': false, 'img': 'https://api.dicebear.com/7.x/avataaars/png?seed=Werther'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: personas.map((p) => _buildPersonaCard(p)).toList(),
      ),
    );
  }

  Widget _buildPersonaCard(Map<String, dynamic> p) {
    bool active = p['active'];
    return Container(
      width: 104,
      margin: const EdgeInsets.only(right: 14),
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: active ? Colors.white.withOpacity(0.04) : Colors.white.withOpacity(0.01),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: active ? AppColors.primary.withOpacity(0.6) : Colors.white.withOpacity(0.05),
          width: active ? 1.0 : 0.5,
        ),
        boxShadow: active ? [
          BoxShadow(color: AppColors.primary.withOpacity(0.08), blurRadius: 24, spreadRadius: -2)
        ] : null,
      ),
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: active ? AppColors.primary : Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
              image: DecorationImage(
                image: NetworkImage(p['img']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            p['name'],
            style: GoogleFonts.notoSerifSc(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: active ? AppColors.primary : AppColors.onSurface.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            p['en'],
            style: GoogleFonts.robotoMono(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: active ? AppColors.primary.withOpacity(0.4) : AppColors.onSurface.withOpacity(0.15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhilosopherQuote() {
    return Center(
      child: Column(
        children: [
          Text(
            '哲学探索者 / THE PHILOSOPHER',
            style: GoogleFonts.robotoMono(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '追求 0.05% 黄金点。相信通过酒精能让人变得更真实。',
            style: GoogleFonts.notoSerifSc(
              fontSize: 12,
              color: AppColors.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'CHASING THE 0.05% GOLD POINT. BELIEVING THAT\nMODERATED ALCOHOL ALLOWS FOR A MORE AUTHENTIC\nSELF.',
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 9,
              fontStyle: FontStyle.italic,
              height: 1.5,
              letterSpacing: 0.5,
              color: AppColors.onSurface.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnatomyCard(AlcoholBrain brain) {
    return GlassCard(
      padding: const EdgeInsets.all(28),
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
                    '体重 / WEIGHT',
                    style: GoogleFonts.robotoMono(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSurface.withOpacity(0.3)),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${brain.weight.toInt()}',
                        style: GoogleFonts.robotoMono(fontSize: 38, fontWeight: FontWeight.w900, color: AppColors.primary),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'kg',
                        style: GoogleFonts.robotoMono(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary.withOpacity(0.5)),
                      ),
                    ],
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 32, top: 12),
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 6,
                      activeTrackColor: AppColors.primary.withOpacity(0.4),
                      inactiveTrackColor: Colors.white.withOpacity(0.05),
                      thumbShape: const PillSliderThumbShape(),
                      overlayColor: AppColors.primary.withOpacity(0.1),
                    ),
                    child: Slider(
                      value: brain.weight,
                      min: 40,
                      max: 120,
                      onChanged: (v) => brain.updateWeight(v),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 44),
          Text(
            '性别 / GENDER',
            style: GoogleFonts.robotoMono(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSurface.withOpacity(0.3)),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildGenderToggle('男性 / Male', brain.gender == Gender.male, () => brain.updateGender(Gender.male))),
              const SizedBox(width: 16),
              Expanded(child: _buildGenderToggle('女性 / Female', brain.gender == Gender.female, () => brain.updateGender(Gender.female))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenderToggle(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: active ? AppColors.primary.withOpacity(0.15) : Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? AppColors.primary.withOpacity(0.6) : Colors.white.withOpacity(0.05),
            width: active ? 1.2 : 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (active) const Icon(Icons.person, size: 14, color: AppColors.primary),
            if (active) const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.notoSerifSc(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: active ? AppColors.primary : AppColors.onSurface.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetabolismList(AlcoholBrain brain) {
    return Column(
      children: [
        _buildMetabolismCard('Slow / 慢速', 'lower metabolic rate / 代谢较慢', '1.200%/h', brain.metabolicRate == MetabolicRate.slow, () => brain.updateMetabolicRate(MetabolicRate.slow)),
        const SizedBox(height: 14),
        _buildMetabolismCard('Standard / 标准', 'Average metabolic rate / 平均代谢', '1.500%/h', brain.metabolicRate == MetabolicRate.medium, () => brain.updateMetabolicRate(MetabolicRate.medium)),
        const SizedBox(height: 14),
        _buildMetabolismCard('Fast / 快速', 'Higher metabolic rate / 代谢极快', '2.000%/h', brain.metabolicRate == MetabolicRate.fast, () => brain.updateMetabolicRate(MetabolicRate.fast)),
      ],
    );
  }

  Widget _buildMetabolismCard(String title, String desc, String rate, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: active ? Colors.white.withOpacity(0.02) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? AppColors.primary.withOpacity(0.7) : Colors.white.withOpacity(0.05),
            width: active ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.robotoMono(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: active ? AppColors.primary : AppColors.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: GoogleFonts.notoSerifSc(
                    fontSize: 10,
                    color: AppColors.onSurface.withOpacity(0.3),
                  ),
                ),
              ],
            ),
            Text(
              rate,
              style: GoogleFonts.robotoMono(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: active ? AppColors.primary : AppColors.onSurface.withOpacity(0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetabolismNote() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        'Adjust this only if you have clinical data regarding your personal alcohol elimination rate. / 仅当您拥有关于个人酒精代谢率的临床数据时才进行调整。',
        style: GoogleFonts.notoSerifSc(
          fontSize: 10,
          fontStyle: FontStyle.italic,
          height: 1.5,
          color: AppColors.onSurface.withOpacity(0.25),
        ),
      ),
    );
  }

  Widget _buildFooter(AlcoholBrain brain) {
    return Center(
      child: Column(
        children: [
          Text(
            'Version 1.0.0',
            style: GoogleFonts.robotoMono(fontSize: 10, color: AppColors.onSurface.withOpacity(0.15)),
          ),
          const SizedBox(height: 32),
          _buildOutlinedAction('RESTART JOURNEY / 重合旅程'),
          const SizedBox(height: 64),
          Text(
            'About Druk',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: AppColors.primary.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'FEEDBACK & SUPPORT / 用户反馈',
            style: GoogleFonts.robotoMono(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: AppColors.onSurface.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 64),
          _buildLegalCard(),
          const SizedBox(height: 64),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSimpleLink('我们的哲学 Our Philosophy'),
              const SizedBox(width: 36),
              _buildSimpleLink('隐私政策 Privacy Policy'),
            ],
          ),
          const SizedBox(height: 64),
          Text(
            '“酒以见性，水以养生”',
            style: GoogleFonts.notoSerifSc(fontSize: 13, fontStyle: FontStyle.italic, color: AppColors.onSurface.withOpacity(0.2)),
          ),
          const SizedBox(height: 4),
          Text(
            '“In vino veritas, in aqua sanitas.”',
            style: GoogleFonts.playfairDisplay(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.onSurface.withOpacity(0.1)),
          ),
        ],
      ),
    );
  }

  Widget _buildOutlinedAction(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.onSurface.withOpacity(0.12)),
      ),
      child: Text(
        label,
        style: GoogleFonts.robotoMono(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSurface.withOpacity(0.4)),
      ),
    );
  }

  Widget _buildLegalCard() {
    return GlassCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.primary, size: 16),
              const SizedBox(width: 10),
              Text(
                'LEGAL DISCLAIMER / 法律免责声明',
                style: GoogleFonts.robotoMono(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '本应用基于 Widmark 公式进行估算，数据仅供交流学术参考，不作为任何医疗建议。应用不承担作为判断醉酒与否的法律标准。请勿酒后驾车。',
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSerifSc(fontSize: 11, height: 1.7, color: AppColors.onSurface.withOpacity(0.5)),
          ),
          const SizedBox(height: 16),
          Text(
            'Calculations based on the Widmark formula are for entertainment and academic reference only. This data must not be used as medical advice, nor used as a legal standard for determining intoxication. Never drink and drive.',
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(fontSize: 10, fontStyle: FontStyle.italic, height: 1.5, color: AppColors.onSurface.withOpacity(0.2)),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleLink(String text) {
    return Text(
      text,
      style: GoogleFonts.notoSerifSc(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.onSurface.withOpacity(0.3)),
    );
  }
}

class PillSliderThumbShape extends SliderComponentShape {
  const PillSliderThumbShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(48, 24);

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

    final rect = Rect.fromCenter(center: center, width: 44, height: 22);
    final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(11));

    // Refined Drop Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    
    canvas.drawRRect(rRect.shift(const Offset(0, 4)), shadowPaint);
    canvas.drawRRect(rRect, paint);
    
    // Internal Highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRRect(rRect, highlightPaint);
  }
}
