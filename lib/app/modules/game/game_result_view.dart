import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:phishing_quest/app/data/services/auth_service.dart';
import 'package:phishing_quest/app/global_ui/app_theme.dart';
import 'package:phishing_quest/app/global_ui/components/score_badge.dart';
import 'package:phishing_quest/app/modules/game/game_flow_controller.dart';
import 'package:phishing_quest/app/modules/main_shell/main_shell_module.dart';

class GameResultView extends StatelessWidget {
  const GameResultView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final answers = args['answers'] as List<QuizRoundAnswer>;
    final roundPoints = args['roundPoints'] as int;
    final categoryId = args['categoryId'] as String;
    final categoryName = args['categoryName'] as String;
    final rankingScore = Get.find<AuthService>().currentUser.value?.totalScore ?? 0;

    final correctCount = answers.where((a) => a.result.isCorrect).length;
    final accuracy = answers.isEmpty ? 0.0 : correctCount / answers.length;

    return Scaffold(
      backgroundColor: AppTheme.colors.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Column(
            children: [
              // Header
              FadeInDown(
                child: Text('Resultado', style: AppTheme.textStyles.display),
              ),
              SizedBox(height: 4.h),
              FadeInDown(
                delay: const Duration(milliseconds: 100),
                child: Text(
                  categoryName,
                  style: AppTheme.textStyles.posLabel.copyWith(color: AppTheme.colors.textSecondary),
                ),
              ),
              SizedBox(height: 24.h),
              // Pontos desta partida
              ZoomIn(
                delay: const Duration(milliseconds: 200),
                child: ScoreBadge(score: roundPoints, size: 130.r),
              ),
              SizedBox(height: 8.h),
              Text(
                'pontos nesta partida',
                style: AppTheme.textStyles.label.copyWith(color: AppTheme.colors.textSecondary),
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
                        icon: Icons.check_circle_outline,
                        color: AppTheme.colors.success,
                        value: '$correctCount/${answers.length}',
                        label: 'Acertos',
                      ),
                    ),
                    Expanded(
                      child: _StatItem(
                        icon: Icons.percent,
                        color: AppTheme.colors.primary,
                        value: '${(accuracy * 100).round()}%',
                        label: 'Precisão',
                      ),
                    ),
                    Expanded(
                      child: _StatItem(
                        icon: Icons.emoji_events_outlined,
                        color: AppTheme.colors.accent,
                        value: '$rankingScore',
                        label: 'No ranking',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              // Per-question breakdown
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Questões',
                      style: AppTheme.textStyles.subTitle.copyWith(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 12.h),
                    ...answers.asMap().entries.map((entry) => _QuestionResult(index: entry.key, answer: entry.value)),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              // Action Buttons
              FadeInUp(
                delay: const Duration(milliseconds: 500),
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
                              style: AppTheme.textStyles.posLabel.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () => Get.offNamed('/game', arguments: {
                          'categoryId': categoryId,
                          'categoryName': categoryName,
                        }),
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
                              'Jogar de novo',
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

class _QuestionResult extends StatelessWidget {
  final int index;
  final QuizRoundAnswer answer;

  const _QuestionResult({required this.index, required this.answer});

  @override
  Widget build(BuildContext context) {
    final result = answer.result;
    final color = result.isCorrect ? AppTheme.colors.success : AppTheme.colors.error;
    final correctText = answer.correctAnswerText;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppTheme.colors.backgroundCard,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(result.isCorrect ? Icons.check_circle : Icons.cancel, color: color, size: 20.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  '${index + 1}. ${answer.question.questionText}',
                  style: AppTheme.textStyles.posLabel.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '+${result.pointsAwarded}',
                style: AppTheme.textStyles.label.copyWith(
                  color: AppTheme.colors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (!result.isCorrect && correctText != null) ...[
            SizedBox(height: 8.h),
            Text(
              'Resposta correta: $correctText',
              style: AppTheme.textStyles.label.copyWith(color: AppTheme.colors.textSecondary, height: 1.4),
            ),
          ],
          if (result.isCorrect && result.pointsAwarded == 0) ...[
            SizedBox(height: 8.h),
            Text(
              'Você já tinha acertado esta questão antes; só o primeiro acerto pontua.',
              style: AppTheme.textStyles.label.copyWith(color: AppTheme.colors.textMuted, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}

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
        Text(value, style: AppTheme.textStyles.title.copyWith(fontWeight: FontWeight.w700)),
        Text(label, style: AppTheme.textStyles.label.copyWith(color: AppTheme.colors.textSecondary)),
      ],
    );
  }
}
