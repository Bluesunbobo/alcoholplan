import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:druk/constants/app_colors.dart';
import 'package:druk/logic/alcohol_brain.dart';
import 'package:druk/models/persona.dart';
import 'package:druk/widgets/glass_card.dart';
import 'package:druk/widgets/country_picker_sheet.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  double _weightValue = 70.0;
  Gender _selectedGender = Gender.male;
  Persona _selectedPersona = Persona.martin;
  MetabolicRate _selectedRate = MetabolicRate.medium;

  List<Persona> get _filteredPersonas =>
      Persona.values.where((p) => p.defaultGender == _selectedGender).toList();

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );
    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  Future<void> _finishSetup() async {
    HapticFeedback.heavyImpact();
    final brain = context.read<AlcoholBrain>();
    brain.weight = _weightValue;
    brain.gender = _selectedGender;
    brain.persona = _selectedPersona;
    brain.metabolicRate = _selectedRate;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);

    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceDim,
      body: Stack(
        children: [
          // Ambient Glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 600,
              height: 600,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.primary.withOpacity(0.07),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 56),
                      _buildAnatomySection(),
                      const SizedBox(height: 56),
                      _buildPersonaSection(),
                      const SizedBox(height: 56),
                      _buildJurisdictionSection(),
                      const SizedBox(height: 56),
                      _buildMetabolismSection(),
                      const SizedBox(height: 56),
                      _buildFooter(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 1. EDITORIAL HEADER ─────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Druk / The Patron Registry',
          style: GoogleFonts.playfairDisplay(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: AppColors.amberGold.withOpacity(0.9),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '午夜序章',
          style: GoogleFonts.notoSerifSc(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: AppColors.ivoryWarm,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'THE MIDNIGHT PROLOGUE',
          style: GoogleFonts.robotoMono(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 4.0,
            color: AppColors.silverGray.withOpacity(0.4),
          ),
        ),
      ],
    );
  }

  // ── 2. ANATOMY ───────────────────────────────────────────────
  Widget _buildAnatomySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('生物特征 / The Anatomy', 'BIOMETRICS'),
        const SizedBox(height: 24),

        // Gender Toggle
        Row(
          children: [
            Expanded(child: _buildGenderButton(Gender.male, 'MALE / 男性', Icons.male)),
            const SizedBox(width: 16),
            Expanded(child: _buildGenderButton(Gender.female, 'FEMALE / 女性', Icons.female)),
          ],
        ),
        const SizedBox(height: 16),

        // Weight Slider Card
        GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
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
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 9,
                            fontStyle: FontStyle.italic,
                            color: AppColors.silverGray.withOpacity(0.6),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${_weightValue.toInt()}',
                        style: GoogleFonts.robotoMono(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppColors.amberGold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          'KG',
                          style: GoogleFonts.robotoMono(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.amberGold.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.amberGold,
                  inactiveTrackColor: AppColors.amberGold.withOpacity(0.15),
                  thumbColor: AppColors.amberGold,
                  overlayColor: AppColors.amberGold.withOpacity(0.1),
                  trackHeight: 2,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 8),
                ),
                child: Slider(
                  value: _weightValue,
                  min: 40,
                  max: 150,
                  divisions: 110,
                  onChanged: (val) {
                    setState(() => _weightValue = val);
                    HapticFeedback.selectionClick();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGenderButton(Gender gender, String label, IconData icon) {
    final isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedGender = gender;
          final first = _filteredPersonas.firstOrNull;
          if (first != null) _selectedPersona = first;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.amberGold.withOpacity(0.1)
              : AppColors.surfaceContainerLow.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.amberGold.withOpacity(0.4)
                : Colors.white.withOpacity(0.05),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 16,
                color: isSelected
                    ? AppColors.amberGold
                    : AppColors.ivoryWarm.withOpacity(0.4)),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.robotoMono(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? AppColors.amberGold
                    : AppColors.ivoryWarm.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 3. PERSONA GRID ───────────────────────────────────────────
  Widget _buildPersonaSection() {
    final personas = _filteredPersonas;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('人格档案 / The Persona', 'IDENTITY'),
        const SizedBox(height: 20),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: GridView.count(
            key: ValueKey(_selectedGender),
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
            children: personas.map((persona) {
              final isSelected = _selectedPersona == persona;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedPersona = persona);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.surfaceContainerHighest.withOpacity(0.35)
                        : AppColors.surfaceContainerLow.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.amberGold.withOpacity(0.4)
                          : Colors.white.withOpacity(0.05),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Avatar
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: CircleAvatar(
                          radius: isSelected ? 44 : 40,
                          backgroundImage:
                              AssetImage('assets/images/${persona.avatarImageName}.png'),
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        persona.zhName,
                        style: GoogleFonts.notoSerifSc(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: isSelected
                              ? AppColors.amberGold
                              : AppColors.ivoryWarm.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        persona.enPersonaType,
                        style: GoogleFonts.robotoMono(
                          fontSize: 8,
                          letterSpacing: 1.0,
                          color: isSelected
                              ? AppColors.amberGold.withOpacity(0.7)
                              : AppColors.silverGray.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 16),

        // Persona description
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: Container(
            key: ValueKey(_selectedPersona),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(
                  _selectedPersona.zhDescription,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSerifSc(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    height: 1.6,
                    color: AppColors.ivoryWarm.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedPersona.enDescription.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.robotoMono(
                    fontSize: 8,
                    letterSpacing: 1.0,
                    height: 1.5,
                    color: AppColors.silverGray.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── 4. JURISDICTION ───────────────────────────────────────────
  Widget _buildJurisdictionSection() {
    return Consumer<AlcoholBrain>(
      builder: (context, brain, _) {
        final country = brain.country;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('法律管辖区 / Jurisdiction', 'STANDARDS'),
            const SizedBox(height: 24),
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Text(country.flag,
                            style: const TextStyle(fontSize: 40)),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '国家 / 地区 / COUNTRY',
                                style: GoogleFonts.robotoMono(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.silverGray.withOpacity(0.5),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    country.name,
                                    style: GoogleFonts.notoSerifSc(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.ivoryWarm,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('/',
                                      style: TextStyle(
                                          color: AppColors.silverGray
                                              .withOpacity(0.2))),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      country.enName.toUpperCase(),
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.robotoMono(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.silverGray
                                            .withOpacity(0.6),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => const CountryPickerSheet(),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.1)),
                            ),
                            child: Text(
                              '修改 / CHANGE',
                              style: GoogleFonts.robotoMono(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.ivoryWarm,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: Colors.white.withOpacity(0.08), height: 1),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '醉酒驾驶 / DRUNK DRIVING',
                              style: GoogleFonts.robotoMono(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: AppColors.silverGray.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              country.dwiLimitString,
                              style: GoogleFonts.robotoMono(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.amberGold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 40),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '饮酒驾驶 / DUI THRESHOLD',
                              style: GoogleFonts.robotoMono(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: AppColors.silverGray.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              country.isProhibition
                                  ? 'ZERO'
                                  : country.duiLimitString,
                              style: GoogleFonts.robotoMono(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.amberGold.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  // ── 5. METABOLISM ────────────────────────────────────────────
  Widget _buildMetabolismSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('代谢速率 / Metabolism', 'BURN RATE'),
        const SizedBox(height: 20),
        GlassCard(
          padding: const EdgeInsets.all(4),
          child: Row(
            children: MetabolicRate.values.map((rate) {
              final isSelected = _selectedRate == rate;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _selectedRate = rate);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.amberGold.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Center(
                      child: Text(
                        rate.name.toUpperCase(),
                        style: GoogleFonts.robotoMono(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? AppColors.amberGold
                              : AppColors.silverGray.withOpacity(0.5),
                        ),
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
  }

  // ── 6. FOOTER ────────────────────────────────────────────────
  Widget _buildFooter() {
    return Column(
      children: [
        GestureDetector(
          onTap: _finishSetup,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.amberGold, AppColors.primaryContainer],
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
            child: Center(
              child: Text(
                '开始旅程 / ENTER THE LEDGER',
                style: GoogleFonts.robotoMono(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: const Color(0xFF1a1714),
                ),
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
            color: AppColors.ivoryWarm.withOpacity(0.25),
          ),
        ),
      ],
    );
  }

  // ── HELPERS ──────────────────────────────────────────────────
  Widget _sectionTitle(String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: AppColors.ivoryWarm,
            ),
          ),
        ),
        Text(
          subtitle,
          style: GoogleFonts.robotoMono(
            fontSize: 9,
            letterSpacing: 2.0,
            color: AppColors.silverGray.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}
