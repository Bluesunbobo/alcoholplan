import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:druk/constants/app_colors.dart';
import 'package:druk/logic/alcohol_brain.dart';
import 'package:druk/models/country_law.dart';

class BACChart extends StatelessWidget {
  final List<BACPoint> points;
  final CountryLaw country;
  final bool showNowLine;
  final DateTime? startTime;
  final DateTime? soberTime;

  const BACChart({
    super.key,
    required this.points,
    required this.country,
    this.showNowLine = true,
    this.startTime,
    this.soberTime,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: BACCurvePainter(
        points: points,
        country: country,
        showNowLine: showNowLine,
        startTime: startTime,
        soberTime: soberTime,
      ),
    );
  }
}

class BACCurvePainter extends CustomPainter {
  final List<BACPoint> points;
  final CountryLaw country;
  final bool showNowLine;
  final DateTime? startTime;
  final DateTime? soberTime;

  // Constants for layout
  static const double leftInset = 42.0; 
  static const double bottomInset = 35.0;

  BACCurvePainter({
    required this.points,
    required this.country,
    required this.showNowLine,
    this.startTime,
    this.soberTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final double chartWidth = size.width - leftInset - 10;
    final double chartHeight = size.height - bottomInset;

    // ── Dynamic Bounds Calculation ─────────────
    final double rawMax = points.map((p) => p.y).fold(0.0, (a, b) => a > b ? a : b);
    
    // Standardized ceiling logic for human-friendly ticks
    double ceiling;
    if (rawMax <= 0.04) {
      ceiling = 0.04;
    } else if (rawMax <= 0.08) {
      ceiling = 0.08;
    } else if (rawMax <= 0.12) {
      ceiling = 0.12;
    } else if (rawMax <= 0.16) {
      ceiling = 0.16;
    } else {
      ceiling = (rawMax * 1.2 / 0.04).ceil() * 0.04;
    }

    double getX(double x) => leftInset + (x * chartWidth);
    double getY(double y) => chartHeight - (y / ceiling * chartHeight);

    // ── 1. Draw Y-Axis Ticks (Vertical) ────────
    _drawYAxisLabels(canvas, size, ceiling, chartHeight);

    // ── 2. Draw X-Axis Ticks (Time Intervals) ──
    if (startTime != null && soberTime != null) {
      _drawXAxisTimeTicks(canvas, size, chartWidth, chartHeight);
    }

    // ── 3. Draw Legal Threshold Lines (Background) ──
    
    // 0.080% DWI
    if (country.dwiLimit != null) {
      _drawLimitLine(
        canvas, size, country.dwiLimit!, 
        "🇨🇳 中国 DWI 0.080%", 
        const Color(0xFFE57373).withOpacity(0.4), 
        ceiling,
        chartWidth,
        chartHeight,
      );
    }

    // 0.050% Philosophical Point
    _drawLimitLine(
      canvas, size, 0.05, 
      "★ 0.05% 哲学黄金点 / PHILOSOPHICAL POINT", 
      AppColors.amberGold.withOpacity(0.6), 
      ceiling,
      chartWidth,
      chartHeight,
      isDashed: true,
    );

    // 0.020% DUI
    _drawLimitLine(
      canvas, size, country.duiLimit, 
      "🇨🇳 中国 DUI 0.020%", 
      AppColors.amberGold.withOpacity(0.35), 
      ceiling,
      chartWidth,
      chartHeight,
    );

    // ── 4. Draw Curve & Area Gradient ──────────
    final curvePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

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
    
    // Area Gradient Fill
    final fillPath = Path.from(path)
      ..lineTo(getX(points.last.x), getY(0))
      ..lineTo(getX(points.first.x), getY(0))
      ..close();
    
    canvas.drawPath(fillPath, Paint()..shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.primary.withOpacity(0.25),
        AppColors.primary.withOpacity(0.0),
      ],
    ).createShader(Rect.fromLTRB(0, 0, size.width, size.height)));

    canvas.drawPath(path, curvePaint);

    // ── 5. NOW Indicator ──────────────────
    if (showNowLine && startTime != null && soberTime != null) {
      _drawNowIndicator(canvas, size, ceiling, chartWidth, chartHeight);
    }
    
    _drawBottomBarLabels(canvas, size, chartWidth, chartHeight);
  }

  void _drawYAxisLabels(Canvas canvas, Size size, double ceiling, double chartHeight) {
    // Generate 4 fixed sections (5 ticks total)
    final double step = ceiling / 4;
    final List<double> ticks = List.generate(5, (i) => i * step);
    
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 0.5;

    for (var tick in ticks) {
      final y = chartHeight - (tick / ceiling * chartHeight);
      
      // Horizontal grid line
      canvas.drawLine(Offset(leftInset, y), Offset(size.width, y), paint);

      // Label
      final tp = TextPainter(
        text: TextSpan(
          text: tick.toStringAsFixed(3),
          style: GoogleFonts.robotoMono(fontSize: 8, color: Colors.white.withOpacity(0.25)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftInset - tp.width - 8, y - tp.height / 2));
    }
  }

  void _drawXAxisTimeTicks(Canvas canvas, Size size, double chartWidth, double chartHeight) {
    if (startTime == null || soberTime == null) return;
    final totalDuration = soberTime!.difference(startTime!);
    final totalHours = totalDuration.inHours;
    
    // Dynamic step based on total hours to avoid crowding
    // Aim for ~6 labels max
    int step = (totalHours / 5).ceil();
    if (step < 2) step = 2; // Min 2 hours interval for clarity

    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 0.5;

    for (int i = 0; i <= totalHours; i += step) {
      final tickTime = startTime!.add(Duration(hours: i));
      if (tickTime.isAfter(soberTime!)) continue;
      
      final elapsed = tickTime.difference(startTime!);
      final x = leftInset + ((elapsed.inSeconds / totalDuration.inSeconds) * chartWidth);

      // Vertical grid line
      canvas.drawLine(Offset(x, 0), Offset(x, chartHeight), gridPaint);

      // Time label
      final tp = TextPainter(
        text: TextSpan(
          text: "${tickTime.hour.toString().padLeft(2, '0')}:00",
          style: GoogleFonts.robotoMono(fontSize: 8, color: Colors.white.withOpacity(0.2)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, chartHeight + 6));
    }
  }

  void _drawLimitLine(Canvas canvas, Size size, double value, String label, Color color, double ceiling, double chartWidth, double chartHeight, {bool isDashed = true}) {
    final y = chartHeight - (value / ceiling * chartHeight);
    if (y < 0 || y > chartHeight) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Dotted line
    double dashWidth = 3, dashSpace = 3, startX = 0;
    while (startX < chartWidth) {
      canvas.drawLine(Offset(leftInset + startX, y), Offset(leftInset + startX + dashWidth, y), paint);
      startX += dashWidth + dashSpace;
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: GoogleFonts.robotoMono(
          fontSize: 7.5,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
          color: color.withOpacity(0.9),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(size.width - textPainter.width - 4, y - textPainter.height - 4));
  }

  void _drawNowIndicator(Canvas canvas, Size size, double ceiling, double chartWidth, double chartHeight) {
    final now = DateTime.now();
    final totalDuration = soberTime!.difference(startTime!);
    final elapsed = now.difference(startTime!);
    final xPercent = (elapsed.inSeconds / totalDuration.inSeconds).clamp(0.0, 1.0);
    final x = leftInset + (xPercent * chartWidth);
    
    // Vertical Dashed Line
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 1.0;
    
    double dashHeight = 4, dashSpace = 4, startY = 0;
    while (startY < chartHeight) {
      canvas.drawLine(Offset(x, startY), Offset(x, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }

    // Glow effect for the NOW dot
    canvas.drawCircle(Offset(x, 0), 6.0, Paint()..color = Colors.white.withOpacity(0.1)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    canvas.drawCircle(Offset(x, 0), 3.0, Paint()..color = Colors.white);
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'NOW',
        style: GoogleFonts.robotoMono(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(x - textPainter.width / 2, -18));
  }

  void _drawBottomBarLabels(Canvas canvas, Size size, double chartWidth, double chartHeight) {
    if (startTime == null || soberTime == null) return;
    final tp = TextPainter(textDirection: TextDirection.ltr);

    // Start
    tp.text = TextSpan(
      text: "${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}",
      style: GoogleFonts.robotoMono(fontSize: 10, color: Colors.white.withOpacity(0.3)),
    );
    tp.layout();
    tp.paint(canvas, Offset(leftInset, chartHeight + 28));

    // NOW
    tp.text = TextSpan(
      text: "当前 / NOW",
      style: GoogleFonts.notoSerifSc(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.amberGold),
    );
    tp.layout();
    tp.paint(canvas, Offset(leftInset + (chartWidth / 2) - (tp.width / 2), chartHeight + 28));

    // End
    tp.text = TextSpan(
      text: "${soberTime!.hour.toString().padLeft(2, '0')}:${soberTime!.minute.toString().padLeft(2, '0')}",
      style: GoogleFonts.robotoMono(fontSize: 10, color: Colors.white.withOpacity(0.3)),
    );
    tp.layout();
    tp.paint(canvas, Offset(size.width - tp.width, chartHeight + 28));
  }

  @override
  bool shouldRepaint(covariant BACCurvePainter oldDelegate) => true;
}
