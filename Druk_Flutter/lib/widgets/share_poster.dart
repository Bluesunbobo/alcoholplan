import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import 'package:druk/constants/app_colors.dart';
import 'package:druk/logic/alcohol_brain.dart';
import 'package:druk/models/quotes_db.dart';
import 'package:druk/widgets/history_heatmap.dart';

class ShareService {
  static Future<void> shareSession({
    required BuildContext context,
    required AlcoholBrain brain,
    DrinkSession? historySession,
  }) async {
    final PageController pageController = PageController(viewportFraction: 0.82);
    final List<GlobalKey> keys = List.generate(3, (_) => GlobalKey());
    int currentPage = 0;

    final double screenHeight = MediaQuery.of(context).size.height;
    
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.9),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => StatefulBuilder(
        builder: (context, setState) => Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                // ── Header (Fixed Height) ─────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'POSTER PREVIEW',
                            style: GoogleFonts.robotoMono(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '/ 海报预览',
                            style: GoogleFonts.notoSerifSc(
                              fontSize: 11,
                              color: Colors.white38,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 20, color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Poster Preview (Adaptive Area) ──
                // This Expanded area will take ALL remaining space between Header and Buttons
                Expanded(
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: 3,
                    onPageChanged: (i) => setState(() => currentPage = i),
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      Widget child;
                      if (index == 0) {
                        child = _MomentPoster(brain: brain, session: historySession);
                      } else if (index == 1) {
                        child = _CurvePoster(brain: brain, session: historySession);
                      } else {
                        child = _AnnualPoster(brain: brain);
                      }

                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: RepaintBoundary(
                              key: keys[index],
                              child: child,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: i == currentPage ? 12 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: i == currentPage ? AppColors.amberGold : Colors.white24,
                    ),
                  )),
                ),

                // ── Action Buttons (Fixed Bottom Area) ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ActionButton(
                        label: 'DOWNLOAD / 保存海报',
                        icon: Icons.file_download_outlined,
                        onTap: () async {
                          final bytes = await _capture(keys[currentPage]);
                          await Gal.putImageBytes(bytes);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('已保存至相册 / SAVED TO GALLERY')),
                            );
                          }
                        },
                        isPrimary: true,
                      ),
                      const SizedBox(height: 12),
                      _ActionButton(
                        label: 'SYSTEM SHARE / 系统分享',
                        icon: Icons.chat_bubble_outline,
                        onTap: () async {
                          final bytes = await _capture(keys[currentPage]);
                          final tempDir = await getTemporaryDirectory();
                          final file = await File('${tempDir.path}/druk_share.png').create();
                          await file.writeAsBytes(bytes);
                          await Share.shareXFiles([XFile(file.path)], text: 'Druk - 微醺志');
                        },
                        isPrimary: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Future<Uint8List> _capture(GlobalKey key) async {
    final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}

// ── Shared Base Poster Header/Footer ───────────
class _PosterShell extends StatelessWidget {
  final Widget child;
  final String? footerState;
  final String? footerLabel;
  
  const _PosterShell({
    required this.child, 
    this.footerState, 
    this.footerLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 640,
      color: const Color(0xFF141210), // Deep brown-black
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Druk-微醺志',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      color: AppColors.amberGold,
                    ),
                  ),
                  Text(
                    DateTime.now().toString().substring(0, 16),
                    style: GoogleFonts.robotoMono(fontSize: 8, color: Colors.white24),
                  ),
                ],
              ),
              _LogoD(),
            ],
          ),
          
          Expanded(child: child),

          const SizedBox(height: 12),
          // Disclaimer
          Text(
            '免责声明：本应用计算出的 BAC 理论值仅供娱乐和参考，不可作为判断是否涉及酒驾的标准。请以实际检测为准。切勿酒后驾驶。',
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSerifSc(fontSize: 6, height: 1.5, color: Colors.white12),
          ),
          const SizedBox(height: 8),
          Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PHOTO GENERATED BY DRUK APP', style: GoogleFonts.robotoMono(fontSize: 7, fontWeight: FontWeight.bold, color: Colors.white54)),
                  Text('图片由 Druk 微醺志 生成', style: GoogleFonts.notoSerifSc(fontSize: 7, color: Colors.white38)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(footerState?.toUpperCase() ?? 'ANNUAL REVIEW', style: GoogleFonts.robotoMono(fontSize: 7, fontWeight: FontWeight.bold, color: Colors.white54)),
                  Text(footerLabel ?? '年度饮酒报告', style: GoogleFonts.notoSerifSc(fontSize: 7, color: Colors.white38)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Poster 1: Moment (Based on Image 3) ────────
class _MomentPoster extends StatelessWidget {
  final AlcoholBrain brain;
  final DrinkSession? session;
  const _MomentPoster({required this.brain, this.session});

  @override
  Widget build(BuildContext context) {
    final double bac = session?.peakBAC ?? brain.bacPercentage;
    final String state = session != null ? "历史回顾" : brain.currentStateNameZh;

    final int seed = (session?.id ?? "").hashCode.abs();
    final bool hasCustom = session?.customQuote != null && session!.customQuote!.isNotEmpty;
    final String quoteText;
    final String quoteSub;
    
    if (hasCustom) {
      quoteText = session!.customQuote!;
      quoteSub = "";
    } else {
      final quotes = QuotesDB.shared.neutralQuotes;
      final mq = quotes[seed % quotes.length];
      quoteText = mq.quote;
      quoteSub = mq.translation.toUpperCase();
    }

    return _PosterShell(
      footerState: 'MOMENT LEDGER',
      footerLabel: '当前状态',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Row(
            children: [
              Container(width: 2, height: 100, color: AppColors.amberGold),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ESTIMATED BAC', style: GoogleFonts.robotoMono(fontSize: 8, letterSpacing: 1.5, color: Colors.white24)),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(bac.toStringAsFixed(3), style: GoogleFonts.robotoMono(fontSize: 48, fontWeight: FontWeight.w900, color: AppColors.amberGold)),
                      Text('%', style: GoogleFonts.robotoMono(fontSize: 18, color: AppColors.amberGold.withOpacity(0.5))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('$state / ${brain.persona.rawValue.toUpperCase()}', style: GoogleFonts.notoSerifSc(fontSize: 16, fontStyle: FontStyle.italic, color: AppColors.amberGold)),
                  const SizedBox(height: 2),
                  Text('LOGGED AT ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}', style: GoogleFonts.robotoMono(fontSize: 8, color: Colors.white24)),
                ],
              ),
            ],
          ),
          const Spacer(),
          Text('“$quoteText”', style: GoogleFonts.notoSerifSc(fontSize: 22, fontWeight: FontWeight.w600, height: 1.4, color: Colors.white)),
          const SizedBox(height: 10),
          Text(quoteSub, style: GoogleFonts.playfairDisplay(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.white38)),
          const Spacer(),
          Row(
            children: [
              CircleAvatar(radius: 14, backgroundImage: AssetImage('assets/images/${brain.persona.avatarImageName}.png')),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(brain.persona.zhName, style: GoogleFonts.notoSerifSc(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(brain.persona.rawValue.toUpperCase(), style: GoogleFonts.robotoMono(fontSize: 7, color: Colors.white24)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ── Poster 2: Curve (Based on Image 2) ─────────
class _CurvePoster extends StatelessWidget {
  final AlcoholBrain brain;
  final DrinkSession? session;
  const _CurvePoster({required this.brain, this.session});

  @override
  Widget build(BuildContext context) {
    final List<BACPoint> points = session != null ? brain.getPointsForEntries(session!.entries) : brain.getChartPoints();
    final double bac = points.isEmpty ? 0.0 : points.map((p) => p.y).reduce((a, b) => a > b ? a : b);
    final DateTime? peakTime = session != null ? session!.startTime.add(const Duration(minutes: 45)) : brain.peakBACTime;
    final double totalVol = session != null ? session!.entries.fold(0.0, (s, e) => s + e.volumeML) : brain.totalLiquidVolumeML;
    
    final int seed = (session?.id ?? "").hashCode.abs();
    final bool hasCustom = session?.customQuote != null && session!.customQuote!.isNotEmpty;
    final String qText;
    final String qSub;
    
    if (hasCustom) {
      qText = session!.customQuote!;
      qSub = "";
    } else {
      final quotes = QuotesDB.shared.neutralQuotes;
      final pq = quotes[seed % quotes.length];
      qText = pq.quote;
      qSub = pq.translation.toUpperCase();
    }

    return _PosterShell(
      footerState: 'METABOLISM CURVE',
      footerLabel: '代谢曲线',
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            '“$qText”', 
            textAlign: TextAlign.center, 
            style: GoogleFonts.notoSerifSc(fontSize: 16, fontWeight: FontWeight.w600, height: 1.5, color: Colors.white70)
          ),
          const SizedBox(height: 6),
          Text(
            qSub, 
            textAlign: TextAlign.center, 
            style: GoogleFonts.playfairDisplay(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.white24)
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(bac.toStringAsFixed(3), style: GoogleFonts.robotoMono(fontSize: 56, fontWeight: FontWeight.w900, color: AppColors.amberGold)),
              Text('%', style: GoogleFonts.robotoMono(fontSize: 20, color: AppColors.amberGold.withOpacity(0.5))),
            ],
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('METABOLISM CURVE / 代谢曲线', style: GoogleFonts.robotoMono(fontSize: 8, letterSpacing: 1.5, color: Colors.white24)),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 100,
            width: double.infinity,
            child: CustomPaint(
              painter: _RealCurvePainter(points: points),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                Expanded(child: _SubStat(label: '本次摄入 / INTAKE', value: '${totalVol.toInt()} ML')),
                Container(width: 1, height: 24, color: Colors.white10),
                Expanded(child: _SubStat(label: '峰值时间 / PEAK AT', value: peakTime != null ? '${peakTime.hour}:${peakTime.minute.toString().padLeft(2,'0')}' : '--:--')),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _RealCurvePainter extends CustomPainter {
  final List<BACPoint> points;
  _RealCurvePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    
    final paint = Paint()
      ..color = AppColors.amberGold
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double maxY = points.map((p) => p.y).reduce((a, b) => a > b ? a : b);
    final double ceiling = maxY > 0.08 ? maxY * 1.2 : 0.10;

    double getX(double x) => x * size.width;
    double getY(double y) => size.height - (y / ceiling * size.height);

    final path = Path();
    path.moveTo(getX(points[0].x), getY(points[0].y));
    
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final xc = getX((p1.x + p2.x) / 2);
      final yc = getY((p1.y + p2.y) / 2);
      path.quadraticBezierTo(getX(p1.x), getY(p1.y), xc, yc);
    }
    path.lineTo(getX(points.last.x), getY(points.last.y));
    
    canvas.drawPath(path, paint);
    
    // Gradient fill
    final fillPath = Path.from(path)
      ..lineTo(getX(points.last.x), size.height)
      ..lineTo(getX(points.first.x), size.height)
      ..close();
    
    canvas.drawPath(fillPath, Paint()..shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColors.amberGold.withOpacity(0.15), Colors.transparent],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ── Poster 3: Annual (Based on Image 1) ────────
class _AnnualPoster extends StatelessWidget {
  final AlcoholBrain brain;
  const _AnnualPoster({required this.brain});

  @override
  Widget build(BuildContext context) {
    final allSessions = brain.getAllSessions();

    // Annual Review always uses high-quality neutral quotes
    final annualQuote = QuotesDB.shared.neutralQuotes[DateTime.now().year % QuotesDB.shared.neutralQuotes.length];

    return _PosterShell(
      footerState: 'ANNUAL REVIEW',
      footerLabel: '年度回顾',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          // ── Header Quote ────────────────────
          Text('“${annualQuote.quote}”', maxLines: 4, overflow: TextOverflow.ellipsis, style: GoogleFonts.notoSerifSc(fontSize: 14, fontWeight: FontWeight.bold, height: 1.4, color: Colors.white70)),
          const SizedBox(height: 4),
          Text(annualQuote.translation, maxLines: 3, overflow: TextOverflow.ellipsis, style: GoogleFonts.robotoMono(fontSize: 7, color: Colors.white24)),
          
          const Spacer(),

          // ── Main Heatmap (The Hero) ─────────
          Center(
            child: Column(
              children: [
                Text(
                  '${DateTime.now().year} FREQUENCY MATRIX / 饮酒频次矩阵', 
                  style: GoogleFonts.robotoMono(fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 2, color: AppColors.amberGold.withOpacity(0.5))
                ),
                const SizedBox(height: 12),
                Container(
                  width: 260, // Restrict width to naturally shrink height
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: HistoryHeatMap(sessions: allSessions, isPosterMode: true),
                ),
              ],
            ),
          ),
          
          const Spacer(),

          // ── Bottom Summary Box ──────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text('累计场次 / SESSIONS', style: GoogleFonts.robotoMono(fontSize: 7, color: Colors.white24)),
                      const SizedBox(height: 4),
                      Text('${allSessions.length}', style: GoogleFonts.robotoMono(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                    ],
                  ),
                ),
                Container(width: 1, height: 30, color: Colors.white10),
                Expanded(
                  child: Column(
                    children: [
                      Text('年度总量 / ANNUAL INTENSITY', style: GoogleFonts.robotoMono(fontSize: 7, color: Colors.white24)),
                      const SizedBox(height: 4),
                      Text('${brain.historyTotalAlcoholGrams.toInt()} g', style: GoogleFonts.robotoMono(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.amberGold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Shared UI Elements ─────────────────────────

class _SubStat extends StatelessWidget {
  final String label;
  final String value;
  const _SubStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.robotoMono(fontSize: 7, color: Colors.white24)),
        const SizedBox(height: 8),
        Text(value, style: GoogleFonts.robotoMono(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }
}

class _LogoD extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.amberGold.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.amberGold.withOpacity(0.15),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.5),
        child: Image.asset(
          'assets/images/app_icon.png',
          width: 44,
          height: 44,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;
  
  const _ActionButton({required this.label, required this.icon, required this.onTap, required this.isPrimary});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.amberGold : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          border: isPrimary ? null : Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: isPrimary ? Colors.black : Colors.white70),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.robotoMono(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isPrimary ? Colors.black : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
