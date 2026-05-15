import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:druk/constants/app_colors.dart';
import 'package:druk/logic/alcohol_brain.dart';
import 'package:druk/widgets/dashboard_extras.dart';
import 'package:druk/widgets/glass_card.dart';
import 'package:druk/widgets/record_panel.dart';
import 'package:druk/widgets/share_poster.dart';
import 'package:druk/widgets/country_picker_sheet.dart';

import 'package:druk/screens/movie_splash_screen.dart';
import 'package:druk/screens/onboarding_screen.dart';
import 'package:druk/screens/intro_screen.dart';
import 'package:druk/screens/history_screen.dart';
import 'package:druk/screens/profile_screen.dart';
import 'package:druk/screens/curve_screen.dart';
import 'package:druk/screens/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ── Unified Status Bar ──
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.surfaceDim,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(
    ChangeNotifierProvider(
      create: (_) => AlcoholBrain(
        weight: 70,
        gender: Gender.male,
        metabolicRate: MetabolicRate.medium,
      ),
      child: const DrukApp(),
    ),
  );
}

class DrukApp extends StatefulWidget {
  const DrukApp({super.key});

  @override
  State<DrukApp> createState() => _DrukAppState();
}

class _DrukAppState extends State<DrukApp> {
  bool _onboardingDone = false;
  bool _introCompleted = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkOnboardingState();
  }

  Future<void> _checkOnboardingState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _onboardingDone = prefs.getBool('onboarding_done') ?? false;
      // Removed: _isLoading = false; 
      // It will be set to false ONLY when MovieSplashScreen is done.
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '微醺志 Druk',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.surfaceDim,
        textTheme: GoogleFonts.playfairDisplayTextTheme(
          ThemeData.dark().textTheme,
        ).apply(
          bodyColor: AppColors.onSurface,
          displayColor: AppColors.primary,
        ),
      ),
      home: _isLoading
          ? MovieSplashScreen(onFinished: () {
              setState(() => _isLoading = false);
            })
          : !_onboardingDone
              ? OnboardingScreen(onComplete: () {
                  setState(() {
                    _onboardingDone = true;
                  });
                })
              : const MainContainer(),
    );
  }
}

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => MainContainerState();
}

class MainContainerState extends State<MainContainer> {
  int _currentIndex = 0;
  
  void navigateToTab(int index) {
    setState(() => _currentIndex = index);
  }

  final List<Widget> _pages = [
    const DashboardScreen(),
    const CurveScreen(),
    const HistoryScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Global Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.5, -0.3),
                  radius: 1.2,
                  colors: [
                    Color(0xFF2D1F16),
                    AppColors.surfaceDim,
                  ],
                ),
              ),
            ),
          ),
          
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          
          _buildGlassNavigationBar(context),
        ],
      ),
    );
  }

  Widget _buildGlassNavigationBar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final barWidth = screenWidth - 48; // 24px each side
    final itemWidth = barWidth / 4;

    return Positioned(
      bottom: 24,
      left: 24,
      right: 24,
      // SafeArea padding for devices with gesture nav bars
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: BackdropFilter(
          // ── Layer 1: Strong blur (simulates iOS UIBlurEffect base) ──
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            height: 82,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              // ── Layer 2: Dark warm tinted overlay (simulates .systemUltraThinMaterialDark) ──
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  // Slightly lighter at top (specular highlight)
                  const Color(0xFF2A2017).withOpacity(0.72),
                  const Color(0xFF1A1410).withOpacity(0.82),
                ],
              ),
            ),
            child: Stack(
              children: [
                // ── Layer 3: Inner top specular highlight (iOS frost sheen) ──
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.0),
                          Colors.white.withOpacity(0.12),
                          Colors.white.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Layer 4: Outer hairline border ──
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(34),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.07),
                        width: 0.5,
                      ),
                    ),
                  ),
                ),

                // ── Layer 5: Sliding active indicator ──
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOut,
                  left: _currentIndex * itemWidth + 5,
                  top: 5,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOut,
                    width: itemWidth - 10,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.11),
                          Colors.white.withOpacity(0.05),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 0.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.08),
                          blurRadius: 12,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Layer 6: Navigation items ──
                Row(
                  children: [
                    _buildNavItem(0, Icons.wine_bar, 'LEDGER', '记录'),
                    _buildNavItem(1, Icons.show_chart, 'CURVE', '曲线'),
                    _buildNavItem(2, Icons.history_edu, 'HISTORY', '历史'),
                    _buildNavItem(3, Icons.person_outline, 'PROFILE', '设定'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String en, String zh) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _currentIndex = index);
          HapticFeedback.lightImpact();
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with cross-fade color transition
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Icon(
                  icon,
                  key: ValueKey('${index}_$isSelected'),
                  size: 20,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.onSurface.withOpacity(0.32),
                ),
              ),
              const SizedBox(height: 4),
              // EN label
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                style: GoogleFonts.robotoMono(
                  fontSize: 7.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.onSurface.withOpacity(0.28),
                ),
                child: Text(en),
              ),
              // ZH label
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                style: GoogleFonts.notoSerifSc(
                  fontSize: 7,
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.65)
                      : AppColors.onSurface.withOpacity(0.15),
                ),
                child: Text(zh),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        final brain = Provider.of<AlcoholBrain>(context, listen: false);
        if (brain.bacPercentage > 0 || brain.drinks.isNotEmpty) {
          brain.recalculateBAC();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brain = Provider.of<AlcoholBrain>(context);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          brain.isInputFocused = false;
        },
        behavior: HitTestBehavior.opaque,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 82),
                
                // Header with Persona Avatar & Share
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            final containerState = context.findAncestorStateOfType<MainContainerState>();
                            if (containerState != null) {
                              containerState.navigateToTab(3); // Navigate to Profile tab
                            }
                          },
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            backgroundImage: AssetImage('assets/images/${brain.persona.avatarImageName}.png'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${brain.persona.zhName} / ${brain.persona.rawValue.toUpperCase()}',
                              style: GoogleFonts.notoSerifSc(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${brain.persona.zhPersonaType} / ${brain.persona.enPersonaType}',
                              style: GoogleFonts.robotoMono(
                                fontSize: 9,
                                letterSpacing: 1.0,
                                fontWeight: FontWeight.w500,
                                color: AppColors.onSurface.withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      'Druk',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                GestureDetector(
                  onTap: () => ShareService.shareSession(context: context, brain: brain),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.ios_share, size: 12, color: AppColors.onSurface.withOpacity(0.4)),
                          const SizedBox(width: 8),
                          Text(
                            'SHARE / 分享',
                            style: GoogleFonts.robotoMono(
                              fontSize: 8,
                              color: AppColors.onSurface.withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                
                // ── MAIN BAC DISPLAY ──
                const _BACDisplayCard(),
                
                const SizedBox(height: 24),

                // ── ADD DRINK HEADER ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'Add Drink',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '/ 记录饮酒',
                      style: GoogleFonts.notoSerifSc(
                        fontSize: 12,
                        color: AppColors.onSurface.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                
                // ── RECORD PANEL ──
                const RecordPanel(),

                const SizedBox(height: 24),
                
                // ── EXTRAS (Jurisdiction) ──
                DashboardExtras(),
                
                const SizedBox(height: 140),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BACDisplayCard extends StatefulWidget {
  const _BACDisplayCard();

  @override
  State<_BACDisplayCard> createState() => _BACDisplayCardState();
}

class _BACDisplayCardState extends State<_BACDisplayCard> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    
    // Sync controller with initial brain state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final brain = Provider.of<AlcoholBrain>(context, listen: false);
      _controller.text = brain.displayBACString;
    });

    _focusNode.addListener(() {
      setState(() {}); 
      final brain = Provider.of<AlcoholBrain>(context, listen: false);
      brain.isInputFocused = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brain = Provider.of<AlcoholBrain>(context);
    
    // Auto-sync controller if not focused
    if (!_focusNode.hasFocus && _controller.text != brain.displayBACString) {
      _controller.text = brain.displayBACString;
    }

    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      borderRadius: 40,
      child: Column(
        children: [
          Text(
            brain.isSimulating ? 'PREDICTED BAC 预测值' : 'REAL-TIME BAC 实时值',
            style: GoogleFonts.robotoMono(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              color: brain.isSimulating ? Colors.blueAccent : AppColors.onSurface.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 16),
          
          // Editable BAC Number + % Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 100, maxWidth: 220),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.robotoMono(
                    fontSize: 60,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    letterSpacing: -1,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  onChanged: (val) {
                    brain.displayBACString = val;
                  },
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '%',
                style: GoogleFonts.robotoMono(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary.withOpacity(0.5),
                ),
              ),
            ],
          ),
          
          // Status
          Text(
            '${brain.currentStateNameZh}  ${brain.currentStateNameEn}',
            style: GoogleFonts.notoSerifSc(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          
          Text(
            '点击金句可自定义 / TAP TO CUSTOMIZE',
            style: GoogleFonts.robotoMono(
              fontSize: 7,
              color: AppColors.onSurface.withOpacity(0.2),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          
          const SizedBox(height: 16),
          
          // Divider
          Container(
            width: 32,
            height: 1,
            color: AppColors.onSurface.withOpacity(0.1),
          ),
          
          const SizedBox(height: 20),
          
          // Quote Container with Dynamic Sizing
          GestureDetector(
            onTap: () => _showQuoteInputDialog(context, brain),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Chinese Quote
                  Builder(
                    builder: (context) {
                      final text = brain.currentQuoteZh;
                      double fontSize = 14;
                      if (text.length < 15) {
                        fontSize = 18;
                      } else if (text.length > 35) {
                        fontSize = 11;
                      }
                      
                      return AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoSerifSc(
                          fontSize: fontSize,
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                          color: AppColors.onSurface.withOpacity(0.85),
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text('“$text”'),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // English Quote (Subtle secondary focus)
                  Builder(
                    builder: (context) {
                      final text = brain.currentQuoteEn;
                      if (text.isEmpty) return const SizedBox.shrink();
                      double fontSize = 9;
                      if (text.length < 40) {
                        fontSize = 11;
                      } else if (text.length > 80) {
                        fontSize = 8;
                      }

                      return AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: fontSize,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                          letterSpacing: 0.5,
                          color: AppColors.onSurface.withOpacity(0.35),
                        ),
                        child: Text('“${text.toUpperCase()}”'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Action Button (Predict Volume)
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
               final target = double.tryParse(brain.displayBACString) ?? 0.0;
               brain.applyTargetBACFromInput(target);
               HapticFeedback.heavyImpact();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.analytics_outlined, size: 16, color: Colors.black),
                  const SizedBox(width: 10),
                  Text(
                    'PREDICT VOLUME / 预测饮酒量',
                    style: GoogleFonts.robotoMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildStatusPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.robotoMono(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  void _showQuoteInputDialog(BuildContext context, AlcoholBrain brain) {
    final controller = TextEditingController(text: brain.currentQuoteZh);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDim,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'CUSTOM QUOTE / 自定义金句',
          style: GoogleFonts.robotoMono(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        content: TextField(
          controller: controller,
          maxLines: 3,
          autofocus: true,
          style: GoogleFonts.notoSerifSc(color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: '写下此刻的心情...',
            hintStyle: TextStyle(color: AppColors.onSurface.withOpacity(0.3)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.primary.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: TextStyle(color: AppColors.onSurface.withOpacity(0.5))),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                brain.setUserQuote(controller.text.trim());
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }
}
