import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:druk/constants/app_colors.dart';
import 'package:druk/logic/alcohol_brain.dart';
import 'package:druk/widgets/session_card.dart';
import 'package:druk/widgets/history_heatmap.dart';
import 'package:druk/widgets/glass_card.dart';
import 'package:druk/models/quotes_db.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AlcoholBrain>(
      builder: (context, brain, _) {
        final sessions = brain.getAllSessions().reversed.toList();

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // ── Cinematic Vertical Line ────────
              Positioned(
                left: 35.5,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.0),
                        AppColors.primary.withOpacity(0.2),
                        AppColors.primary.withOpacity(0.05),
                        Colors.white.withOpacity(0.0),
                      ],
                      stops: const [0.0, 0.2, 0.8, 1.0],
                    ),
                  ),
                ),
              ),
              
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  
                  // ── Statistics Header ────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: _buildFrequencyCard(brain, sessions),
                    ),
                  ),
                  
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // ── Timeline Feed ────────────────
                  sessions.isEmpty
                    ? SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 60.0),
                            child: Text(
                              '暂无饮酒记录\nNO RECORDS YET',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.notoSerifSc(
                                fontSize: 14,
                                color: AppColors.onSurface.withOpacity(0.2),
                              ),
                            ),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final session = sessions[index];
                            final nextSession = index < sessions.length - 1 ? sessions[index + 1] : null;
                            
                            return Dismissible(
                              key: Key(session.id),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) {
                                brain.deleteSession(session.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('已删除该记录 / RECORD DELETED')),
                                );
                              },
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 32),
                                color: Colors.red.withOpacity(0.1),
                                child: const Icon(Icons.delete_outline, color: Colors.red),
                              ),
                              child: Column(
                                  children: [
                                    _buildTimelineItem(session),
                                    if (nextSession != null) _buildQuoteDivider(session),
                                  ],
                              ),
                            );
                          },
                          childCount: sessions.length,
                        ),
                      ),
                  
                  const SliverToBoxAdapter(child: SizedBox(height: 140)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFrequencyCard(AlcoholBrain brain, List<DrinkSession> historySessions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '饮酒频次统计',
              style: GoogleFonts.notoSerifSc(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              ' / STATISTICS',
              style: GoogleFonts.playfairDisplay(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: AppColors.onSurface.withOpacity(0.3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HistoryHeatMap(sessions: historySessions),
              const SizedBox(height: 28),
              Divider(color: Colors.white.withOpacity(0.05), height: 1),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '累计摄入酒精 / TOTAL ALCOHOL',
                        style: GoogleFonts.robotoMono(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: AppColors.onSurface.withOpacity(0.3),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${brain.historyTotalAlcoholGrams.toInt()}',
                            style: GoogleFonts.robotoMono(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'g',
                            style: GoogleFonts.robotoMono(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Icon(Icons.analytics_outlined, color: AppColors.primary.withOpacity(0.15), size: 40),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(DrinkSession session) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        children: [
          // Glowing Dot on the line
          Positioned(
            left: 11.5,
            top: 28,
            child: Container(
              width: 1,
              height: 1,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.8),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: OverflowBox(
                maxWidth: 8,
                maxHeight: 8,
                child: CircleAvatar(
                  radius: 3.5,
                  backgroundColor: AppColors.primary,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 44),
            child: SessionCard(session: session),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteDivider(DrinkSession session) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Container(
          width: 40,
          height: 1,
          color: AppColors.onSurface.withOpacity(0.05),
        ),
      ),
    );
  }
}
