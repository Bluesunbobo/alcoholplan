import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:druk/constants/app_colors.dart';
import 'package:druk/widgets/glass_card.dart';

class PhilosophyScreen extends StatelessWidget {
  const PhilosophyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceDim,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: AppColors.ivoryWarm),
              onPressed: () => Navigator.pop(context),
            ),
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                '微醺哲学 / Philosophy',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ivoryWarm,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.amberGold.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildPhilosophyCard(
                  "0.05% 的真实",
                  "THE 0.05% TRUTH",
                  "人类血液中天生缺少 0.05% 的酒精。这一小段距离，往往就是理性与本真之间的鸿沟。我们记录，不是为了沉溺，而是为了在这个精确的世界里，找回那一丝松动的、诚实的灵魂。",
                ),
                const SizedBox(height: 24),
                _buildPhilosophyCard(
                  "克制的艺术",
                  "THE ART OF RESTRAINT",
                  "真正的微醺是一场在悬崖边缘的华尔兹。多一分则坠入混沌，少一分则流于平庸。Druk 致力于通过数据化你的身体反应，帮助你精准定位那份属于你的‘黄金点’。",
                ),
                const SizedBox(height: 24),
                _buildPhilosophyCard(
                  "在当下，去生活",
                  "BE HERE, NOW",
                  "酒杯映照出的不仅是液体，更是时间的停滞。当你放下忧虑，只为此刻而饮时，酒精成为了时间的防腐剂。我们希望每一份记录，都能成为你人生故事里一个温暖的注脚。",
                ),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhilosophyCard(String titleZh, String titleEn, String content) {
    return GlassCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titleEn,
            style: GoogleFonts.robotoMono(
              fontSize: 10,
              letterSpacing: 2.0,
              fontWeight: FontWeight.bold,
              color: AppColors.amberGold.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            titleZh,
            style: GoogleFonts.notoSerifSc(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.ivoryWarm,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            content,
            style: GoogleFonts.notoSerifSc(
              fontSize: 15,
              height: 1.8,
              color: AppColors.ivoryWarm.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
