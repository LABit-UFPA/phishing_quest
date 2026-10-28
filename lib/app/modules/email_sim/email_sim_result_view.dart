import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:phishing_quest/app/global_ui/app_theme.dart';
import 'package:phishing_quest/app/global_ui/components/rating_stars.dart';
import 'package:phishing_quest/app/global_ui/components/score_badge.dart';
import 'package:phishing_quest/app/modules/email_sim/email_sim_controller.dart';
import 'package:phishing_quest/app/modules/main_shell/main_shell_module.dart';

/// Resumo da rodada. Mostra so o que o jogador ja viu no feedback de
/// cada decisao: acerto, cliques e, na condicao formativa, a nota da
/// justificativa.
class EmailSimResultView extends GetView<EmailSimController> {
  const EmailSimResultView({super.key});

  @override
  Widget build(BuildContext context) {
    final items = controller.inbox.where((i) => controller.isEvaluated(i.id)).toList();
    final results = controller.results;
    final totalScore = controller.totalScore.value;

    final correctCount = results.values.where((r) => r.isCorrect).length;
    final evaluatedCount = results.length;
    final accuracy = evaluatedCount == 0 ? 0.0 : correctCount / evaluatedCount;
    final linksClicked = controller.maliciousClicks.length;

    return Scaffold(
      backgroundColor: AppTheme.colors.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Column(
            children: [
              // Header
              FadeInDown(
                child: Text(
                  'Resultado da rodada',
                  style: AppTheme.textStyles.display,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 4.h),
              FadeInDown(
                delay: const Duration(milliseconds: 100),
                child: Text(
                  'Caixa de entrada simulada',
                  style: AppTheme.textStyles.posLabel.copyWith(
                    color: AppTheme.colors.textSecondary,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              // Score Badge
              ZoomIn(
                delay: const Duration(milliseconds: 200),
                child: ScoreBadge(score: totalScore, size: 130.r),
              ),
              SizedBox(height: 24.h),
              // Stats Row
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: _StatItem(
                        icon: Icons.email_outlined,
                        color: AppTheme.colors.primary,
                        value: '$evaluatedCount',
                        label: 'Avaliados',
                      ),
                    ),
                    Expanded(
                      child: _StatItem(
                        icon: Icons.check_circle_outline,
                        color: AppTheme.colors.success,
                        value: '$correctCount',
                        label: 'Acertos',
                      ),
                    ),
                    Expanded(
                      child: _StatItem(
                        icon: Icons.link_off,
                        color: AppTheme.colors.error,
                        value: '$linksClicked',
                        label: 'Links maliciosos',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 28.h),
              // Donut Chart
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: Container(
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    color: AppTheme.colors.backgroundCard,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Column(
                    children: [
                      Text('Desempenho', style: AppTheme.textStyles.subTitle),
                      SizedBox(height: 16.h),
                      SizedBox(
                        height: 150.h,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 3,
                            centerSpaceRadius: 40.r,
                            sections: [
                              PieChartSectionData(
                                value: correctCount.toDouble(),
                                color: AppTheme.colors.success,
                                title: '$correctCount',
                                titleStyle: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                radius: 35.r,
                              ),
                              PieChartSectionData(
                                value: (evaluatedCount - correctCount).toDouble(),
                                color: AppTheme.colors.error,
                                title: '${evaluatedCount - correctCount}',
                                titleStyle: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                radius: 35.r,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _LegendDot(color: AppTheme.colors.success, label: 'Corretas'),
                          SizedBox(width: 24.w),
                          _LegendDot(color: AppTheme.colors.error, label: 'Erradas'),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: AppTheme.colors.backgroundDark,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.percent, color: AppTheme.colors.accent, size: 20.sp),
                            SizedBox(width: 8.w),
                            Text(
                              'Precisão: ${(accuracy * 100).toInt()}%',
                              style: AppTheme.textStyles.posLabel.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              // Per-email breakdown
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detalhes por e-mail',
                      style: AppTheme.textStyles.subTitle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    ...items.map((item) {
                      final email = item.content;
                      final result = results[item.id]!;
                      final wasCorrect = result.isCorrect;
                      final didClickLink = controller.maliciousClicks.contains(item.id);
                      final userSaidPhishing = controller.verdicts[item.id];
                      final points = controller.pointsFor(item.id);
                      final evaluation = result.evaluation;

                      return Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        padding: EdgeInsets.all(14.r),
                        decoration: BoxDecoration(
                          color: AppTheme.colors.backgroundCard,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: wasCorrect
                                ? AppTheme.colors.success.withOpacity(0.3)
                                : AppTheme.colors.error.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  wasCorrect ? Icons.check_circle : Icons.cancel,
                                  color: wasCorrect ? AppTheme.colors.success : AppTheme.colors.error,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        email.senderName,
                                        style: AppTheme.textStyles.posLabel.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        email.subject,
                                        style: AppTheme.textStyles.label.copyWith(
                                          color: AppTheme.colors.textSecondary,
                                          fontSize: 12.sp,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  points >= 0 ? '+$points pts' : '$points pts',
                                  style: AppTheme.textStyles.label.copyWith(
                                    color: points >= 0 ? AppTheme.colors.accent : AppTheme.colors.error,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                if (userSaidPhishing != null)
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: AppTheme.colors.backgroundDark,
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Text(
                                      'Você: ${userSaidPhishing ? "Phishing" : "Legítimo"}',
                                      style: AppTheme.textStyles.label.copyWith(
                                        fontSize: 10.sp,
                                        color: AppTheme.colors.textMuted,
                                      ),
                                    ),
                                  ),
                                if (didClickLink) ...[
                                  SizedBox(width: 8.w),
                                  Icon(Icons.link_off, color: AppTheme.colors.error, size: 14.sp),
                                ],
                                const Spacer(),
                                if (result.isFormative && evaluation != null)
                                  RatingStars(rating: evaluation.score, starSize: 14.sp),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              // Action Buttons
              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Get.offAllNamed(MainShellModule.path),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r),
                            color: AppTheme.colors.backgroundCard,
                            border: Border.all(color: AppTheme.colors.surfaceBorder),
                          ),
                          child: Center(
                            child: Text(
                              'Início',
                              style: AppTheme.textStyles.posLabel.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: controller.nextRound,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r),
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.colors.primary,
                                AppTheme.colors.primary.withOpacity(0.8),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Nova rodada',
                              style: AppTheme.textStyles.posLabel.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper widgets
class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28.sp),
        SizedBox(height: 6.h),
        Text(
          value,
          style: AppTheme.textStyles.title.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: AppTheme.textStyles.label.copyWith(
            color: AppTheme.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10.r,
          height: 10.r,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 6.w),
        Text(label, style: AppTheme.textStyles.label.copyWith(color: AppTheme.colors.textSecondary)),
      ],
    );
  }
}
