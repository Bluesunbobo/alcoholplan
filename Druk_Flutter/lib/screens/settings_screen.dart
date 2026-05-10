import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:druk/constants/app_colors.dart';
import 'package:druk/logic/alcohol_brain.dart';
import 'package:druk/models/persona.dart';
import 'package:druk/widgets/glass_card.dart';
import 'package:druk/widgets/country_picker_sheet.dart';
import 'package:druk/screens/philosophy_screen.dart';
import 'package:druk/screens/privacy_policy_screen.dart';

import 'package:druk/screens/intro_screen.dart';
import 'package:druk/screens/onboarding_screen.dart';
import 'package:druk/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceDim,
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -200,
            right: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.amberGold.withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                  children: [
                    const SizedBox(height: 12),
                    
                    _buildEditorialHeader(),
                    const SizedBox(height: 56),
                    _buildAnatomySection(),
                    const SizedBox(height: 56),
                    _buildPersonaSection(),
                    const SizedBox(height: 56),
                    _buildMetabolismSection(),
                    const SizedBox(height: 56),
                    _buildAboutSection(context),
                    const SizedBox(height: 140),
                    // Removed _buildFooter call per user request
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorialHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Druk / The Patron Registry',
          style: GoogleFonts.playfairDisplay(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: AppColors.amberGold.withOpacity(0.9),
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '设定档案',
          style: GoogleFonts.notoSerifSc(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: AppColors.ivoryWarm,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'SYSTEM PREFERENCES',
          style: GoogleFonts.robotoMono(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 4.0,
            color: AppColors.silverGray.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildAnatomySection() {
    return Consumer<AlcoholBrain>(
      builder: (context, brain, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '生物特征 / The Anatomy',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: AppColors.ivoryWarm,
                  ),
                ),
                const Spacer(),
                Text(
                  'BIOMETRICS',
                  style: GoogleFonts.robotoMono(
                    fontSize: 10,
                    letterSpacing: 2.0,
                    color: AppColors.silverGray.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Gender
            Row(
              children: [
                Expanded(
                  child: _GenderToggle(
                    title: 'MALE / 男性',
                    icon: Icons.male,
                    isSelected: brain.gender == Gender.male,
                    onTap: () => brain.updateGender(Gender.male),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _GenderToggle(
                    title: 'FEMALE / 女性',
                    icon: Icons.female,
                    isSelected: brain.gender == Gender.female,
                    onTap: () => brain.updateGender(Gender.female),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Weight
            GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '体重 / Weight',
                              style: GoogleFonts.notoSerifSc(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.ivoryWarm,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '体重是精确计算酒精浓度的关键基准指标\nWEIGHT IS THE BASELINE FOR BAC ACCURACY',
                              style: GoogleFonts.notoSerifSc(
                                fontSize: 9,
                                fontStyle: FontStyle.italic,
                                color: AppColors.silverGray.withOpacity(0.7),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${brain.weight.toInt()}',
                            style: GoogleFonts.robotoMono(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AppColors.amberGold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'KG',
                            style: GoogleFonts.robotoMono(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.amberGold.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.amberGold,
                      inactiveTrackColor: Colors.white.withOpacity(0.1),
                      thumbColor: AppColors.amberGold,
                      overlayColor: AppColors.amberGold.withOpacity(0.2),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: brain.weight,
                      min: 40,
                      max: 150,
                      onChanged: (v) => brain.updateWeight(v),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPersonaSection() {
    return Consumer<AlcoholBrain>(
      builder: (context, brain, _) {
        final filteredPersonas = Persona.values.where((p) => p.defaultGender == brain.gender).toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '人格档案 / The Persona',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: AppColors.ivoryWarm,
                  ),
                ),
                const Spacer(),
                Text(
                  'IDENTITY',
                  style: GoogleFonts.robotoMono(
                    fontSize: 10,
                    letterSpacing: 2.0,
                    color: AppColors.silverGray.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: filteredPersonas.length,
              itemBuilder: (context, index) {
                final persona = filteredPersonas[index];
                final isSelected = brain.persona == persona;
                
                return _PersonaCard(
                  persona: persona,
                  isSelected: isSelected,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    brain.updatePersona(persona);
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            
            // Description
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Container(
                key: ValueKey(brain.persona),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Text(
                      brain.persona.zhDescription,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.notoSerifSc(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: AppColors.ivoryWarm.withOpacity(0.85),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      brain.persona.enDescription.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.robotoMono(
                        fontSize: 9,
                        letterSpacing: 1.0,
                        color: AppColors.silverGray.withOpacity(0.5),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '法律与关于 / Legal & About',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: AppColors.ivoryWarm,
              ),
            ),
            const Spacer(),
            Text(
              'SYSTEM',
              style: GoogleFonts.robotoMono(
                fontSize: 10,
                letterSpacing: 2.0,
                color: AppColors.silverGray.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSettingsLink(
          context,
          icon: Icons.auto_awesome,
          title: '重启旅程 / Restart Journey',
          subtitle: 'RESET ALL INITIAL SETUP',
          onTap: () async {
            HapticFeedback.heavyImpact();
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('onboarding_done', false);
            await prefs.setBool('has_seen_intro', false);
            
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => OnboardingScreen(
                    onComplete: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => IntroScreen(
                            onComplete: () => Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => MainContainer()),
                              (route) => false,
                            ),
                          ),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ),
                (route) => false,
              );
            }
          },
        ),
        const SizedBox(height: 16),
        _buildSettingsLink(
          context,
          icon: Icons.history_edu,
          title: '微醺哲学 / Philosophy',
          subtitle: 'OUR VISION',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PhilosophyScreen()),
            );
          },
        ),
        const SizedBox(height: 16),
        _buildSettingsLink(
          context,
          icon: Icons.security,
          title: '隐私政策 / Privacy Policy',
          subtitle: 'DATA & SAFETY',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
            );
          },
        ),

      ],
    );
  }

  Widget _buildSettingsLink(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          children: [
            Icon(icon, color: AppColors.amberGold, size: 20),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.notoSerifSc(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ivoryWarm,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.robotoMono(
                      fontSize: 9,
                      letterSpacing: 1.0,
                      color: AppColors.silverGray.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: AppColors.ivoryWarm.withOpacity(0.2), size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildMetabolismSection() {
    return Consumer<AlcoholBrain>(
      builder: (context, brain, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '代谢速率 / Metabolism',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: AppColors.ivoryWarm,
                  ),
                ),
                const Spacer(),
                Text(
                  'BURN RATE',
                  style: GoogleFonts.robotoMono(
                    fontSize: 10,
                    letterSpacing: 2.0,
                    color: AppColors.silverGray.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest.withOpacity(0.6),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: MetabolicRate.values.map((rate) {
                  final isSelected = brain.metabolicRate == rate;
                  final String displayName = rate == MetabolicRate.slow 
                    ? "SLOW / 慢速" : (rate == MetabolicRate.medium ? "STANDARD / 标准" : "FAST / 快速");

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => brain.updateMetabolicRate(rate),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.amberGold.withOpacity(0.15) : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          displayName,
                          style: GoogleFonts.robotoMono(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? AppColors.amberGold : AppColors.silverGray.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.heavyImpact();
            Navigator.pop(context);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.amberGold, Color(0xFFC8862A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: AppColors.amberGold.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              '确认更改 / SAVE CHANGES',
              style: GoogleFonts.robotoMono(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                color: const Color(0xFF1A1714),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '"In vino veritas, in aqua sanitas."',
          style: GoogleFonts.playfairDisplay(
            fontSize: 13,
            fontStyle: FontStyle.italic,
            color: AppColors.ivoryWarm.withOpacity(0.3),
          ),
        ),
      ],
    );
  }
}

class _GenderToggle extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderToggle({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.amberGold.withOpacity(0.1) : AppColors.surfaceContainerLow.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.amberGold.withOpacity(0.4) : Colors.white.withOpacity(0.05),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.amberGold : AppColors.ivoryWarm.withOpacity(0.4),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.robotoMono(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.amberGold : AppColors.ivoryWarm.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonaCard extends StatefulWidget {
  final Persona persona;
  final bool isSelected;
  final VoidCallback onTap;

  const _PersonaCard({
    required this.persona,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_PersonaCard> createState() => _PersonaCardState();
}

class _PersonaCardState extends State<_PersonaCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack,
        child: Container(
          decoration: BoxDecoration(
            color: widget.isSelected 
              ? AppColors.primary.withOpacity(0.12)
              : Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: widget.isSelected ? AppColors.primary.withOpacity(0.6) : Colors.white.withOpacity(0.08),
              width: widget.isSelected ? 1.5 : 1,
            ),
            boxShadow: widget.isSelected ? [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.15),
                blurRadius: 20,
                spreadRadius: -5,
              )
            ] : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar with glow
              Stack(
                alignment: Alignment.center,
                children: [
                  if (widget.isSelected)
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1),
                      ),
                    ),
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      image: DecorationImage(
                        image: AssetImage('assets/images/${widget.persona.avatarImageName}.png'),
                        fit: BoxFit.cover,
                        colorFilter: widget.isSelected 
                          ? null 
                          : ColorFilter.mode(Colors.black.withOpacity(0.35), BlendMode.darken),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Labels
              Text(
                widget.persona.zhName,
                style: GoogleFonts.notoSerifSc(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: widget.isSelected ? AppColors.primary : AppColors.ivoryWarm.withOpacity(0.6),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.persona.enPersonaType,
                style: GoogleFonts.robotoMono(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: widget.isSelected ? AppColors.primary.withOpacity(0.8) : AppColors.silverGray.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
