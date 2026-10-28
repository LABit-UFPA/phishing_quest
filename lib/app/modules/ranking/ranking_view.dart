import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:phishing_quest/app/data/models/ranking_entry.model.dart';
import 'package:phishing_quest/app/global_ui/app_theme.dart';
import 'package:phishing_quest/app/modules/ranking/ranking_controller.dart';

class RankingView extends StatelessWidget {
  const RankingView({super.key});

  int _listOffset(RankingController controller) => controller.ranking.length >= 3 ? 3 : 0;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RankingController());

    return Scaffold(
      backgroundColor: AppTheme.colors.backgroundDark,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            color: AppTheme.colors.primary,
            backgroundColor: AppTheme.colors.backgroundCard,
            onRefresh: controller.loadRanking,
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: FadeInDown(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.scope.value == RankingScope.cohort ? 'Ranking da Turma' : 'Ranking Global',
                            style: AppTheme.textStyles.display,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Pontos dos acertos no quiz',
                            style: AppTheme.textStyles.posLabel.copyWith(
                              color: AppTheme.colors.textSecondary,
                            ),
                          ),
                          if (controller.hasCohort) ...[
                            SizedBox(height: 12.h),
                            SegmentedButton<RankingScope>(
                              segments: const [
                                ButtonSegment(value: RankingScope.global, label: Text('Global')),
                                ButtonSegment(value: RankingScope.cohort, label: Text('Minha turma')),
                              ],
                              selected: {controller.scope.value},
                              onSelectionChanged: (value) => controller.setScope(value.first),
                              showSelectedIcon: false,
                            ),
                          ],
                          if (controller.loadError.value != null) ...[
                            SizedBox(height: 12.h),
                            Text(
                              controller.loadError.value!,
                              style: AppTheme.textStyles.label.copyWith(color: AppTheme.colors.error),
                            ),
                          ],
                          if (controller.loadError.value == null && controller.ranking.isEmpty) ...[
                            SizedBox(height: 24.h),
                            Text(
                              'Ninguém pontuou ainda. Acerte questões do quiz para aparecer aqui.',
                              style: AppTheme.textStyles.label.copyWith(color: AppTheme.colors.textMuted),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                // Podium Top 3
                if (controller.ranking.length >= 3)
                  SliverToBoxAdapter(
                    child: FadeInUp(
                      delay: const Duration(milliseconds: 150),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                        child: _Podium(entries: controller.ranking.take(3).toList()),
                      ),
                    ),
                  ),
                // My rank card
                if (controller.myRank != null)
                  SliverToBoxAdapter(
                    child: FadeInUp(
                      delay: const Duration(milliseconds: 250),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.colors.primary.withOpacity(0.25),
                              AppTheme.colors.primary.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: AppTheme.colors.primary.withOpacity(0.4)),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Você',
                              style: AppTheme.textStyles.posLabel.copyWith(
                                color: AppTheme.colors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '#${controller.myRank!.position}',
                              style: AppTheme.textStyles.title.copyWith(
                                color: AppTheme.colors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Text(
                              '${controller.myRank!.score} pts',
                              style: AppTheme.textStyles.posLabel.copyWith(
                                color: AppTheme.colors.accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                // List (4th place onwards; everyone when there is no podium)
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final realIndex = index + _listOffset(controller);
                        if (realIndex >= controller.ranking.length) return null;
                        final entry = controller.ranking[realIndex];

                        return FadeInRight(
                          delay: Duration(milliseconds: 50 * index),
                          child: _RankingTile(entry: entry),
                        );
                      },
                      childCount: (controller.ranking.length - _listOffset(controller)).clamp(0, 999),
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 20.h)),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ── Podium ───────────────────────────────────────────────────────────────────
class _Podium extends StatelessWidget {
  final List<RankingEntryModel> entries;
  const _Podium({required this.entries});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppTheme.colors.backgroundCard,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place
          _PodiumColumn(
            entry: entries[1],
            height: 95.h,
            color: const Color(0xFFC0C0C0),
            medal: '🥈',
          ),
          SizedBox(width: 8.w),
          // 1st place
          _PodiumColumn(
            entry: entries[0],
            height: 125.h,
            color: const Color(0xFFFFD700),
            medal: '🥇',
          ),
          SizedBox(width: 8.w),
          // 3rd place
          _PodiumColumn(
            entry: entries[2],
            height: 75.h,
            color: const Color(0xFFCD7F32),
            medal: '🥉',
          ),
        ],
      ),
    );
  }
}

class _PodiumColumn extends StatelessWidget {
  final RankingEntryModel entry;
  final double height;
  final Color color;
  final String medal;

  const _PodiumColumn({
    required this.entry,
    required this.height,
    required this.color,
    required this.medal,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(medal, style: TextStyle(fontSize: 28.sp)),
          SizedBox(height: 4.h),
          CircleAvatar(
            radius: 22.r,
            backgroundColor: color.withOpacity(0.3),
            child: Text(
              entry.username.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            entry.username,
            style: AppTheme.textStyles.label.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 11.sp,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          Text(
            '${entry.score} pts',
            style: AppTheme.textStyles.label.copyWith(
              color: AppTheme.colors.accent,
              fontWeight: FontWeight.w700,
              fontSize: 11.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [color.withOpacity(0.6), color.withOpacity(0.15)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(10.r)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Ranking Tile ─────────────────────────────────────────────────────────────
class _RankingTile extends StatelessWidget {
  final RankingEntryModel entry;
  const _RankingTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppTheme.colors.backgroundCard,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32.w,
            child: Text(
              '#${entry.position}',
              style: AppTheme.textStyles.posLabel.copyWith(
                color: AppTheme.colors.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          CircleAvatar(
            radius: 18.r,
            backgroundColor: AppTheme.colors.primary.withOpacity(0.15),
            child: Text(
              entry.username.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: AppTheme.colors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.username,
                  style: AppTheme.textStyles.posLabel.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${entry.score} pontos',
                  style: AppTheme.textStyles.label.copyWith(
                    color: AppTheme.colors.textSecondary,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${entry.score}',
            style: AppTheme.textStyles.subTitle.copyWith(
              color: AppTheme.colors.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
