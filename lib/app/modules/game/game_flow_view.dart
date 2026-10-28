import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:phishing_quest/app/global_ui/app_theme.dart';
import 'package:phishing_quest/app/global_ui/components/email_preview_card.dart';
import 'package:phishing_quest/app/global_ui/components/progress_bar.dart';
import 'package:phishing_quest/app/modules/game/game_flow_controller.dart';

class GameFlowView extends GetView<GameFlowController> {
  const GameFlowView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => _showExitDialog(context),
        ),
        title: Obx(() => Text(
          'Pergunta ${controller.currentIndex.value + 1}/${controller.questions.length}',
          style: AppTheme.textStyles.posLabel.copyWith(color: AppTheme.colors.textSecondary),
        )),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                SizedBox(height: 16.h),
                Text(
                  'Carregando questões...',
                  style: AppTheme.textStyles.posLabel.copyWith(
                    color: AppTheme.colors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.loadError.value != null || controller.questions.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(24.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    controller.loadError.value ?? 'Nenhuma questão nesta categoria ainda.',
                    style: AppTheme.textStyles.posLabel,
                    textAlign: TextAlign.center,
                  ),
                  if (controller.loadError.value != null) ...[
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: controller.loadQuestions,
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.colors.primary),
                      child: const Text('Tentar de novo', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            // Progress Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Obx(() => GameProgressBar(
                progress: controller.progress,
                label: controller.categoryName,
              )),
            ),
            SizedBox(height: 8.h),
            // Question Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Email Preview if available
                    Obx(() {
                      final email = controller.currentQuestion.context;
                      if (email != null) {
                        return FadeIn(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 16.h),
                            child: EmailPreviewCard(email: email),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    // Question Text
                    FadeInUp(
                      child: Obx(() => Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: AppTheme.colors.backgroundCard,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: AppTheme.colors.surfaceBorder,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          controller.currentQuestion.questionText,
                          style: AppTheme.textStyles.subTitle.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      )),
                    ),
                    SizedBox(height: 16.h),
                    // Answer Options
                    Obx(() => Column(
                      children: controller.currentAnswers.asMap().entries.map((entry) {
                        final answer = entry.value;
                        final index = entry.key;
                        final letters = ['A', 'B', 'C', 'D'];
                        final letter = index < letters.length ? letters[index] : '${index + 1}';

                        return Obx(() {
                          final isSelected = controller.selectedAnswer.value?.id == answer.id;
                          final result = controller.currentResult.value;
                          final isCorrectOption = result != null && result.correctAnswerId == answer.id;
                          final isWrongPick = result != null && isSelected && !result.isCorrect;
                          final optionColor = isCorrectOption
                              ? AppTheme.colors.success
                              : isWrongPick
                                  ? AppTheme.colors.error
                                  : AppTheme.colors.primary;
                          final highlighted = isSelected || isCorrectOption;
                          return FadeInRight(
                            delay: Duration(milliseconds: index * 80),
                            child: GestureDetector(
                              onTap: () => controller.selectAnswer(answer),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: EdgeInsets.only(bottom: 10.h),
                                padding: EdgeInsets.all(14.r),
                                decoration: BoxDecoration(
                                  color: highlighted
                                      ? optionColor.withOpacity(0.15)
                                      : AppTheme.colors.backgroundCard,
                                  borderRadius: BorderRadius.circular(14.r),
                                  border: Border.all(
                                    color: highlighted
                                        ? optionColor
                                        : AppTheme.colors.surfaceBorder,
                                    width: highlighted ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36.r,
                                      height: 36.r,
                                      decoration: BoxDecoration(
                                        color: highlighted
                                            ? optionColor
                                            : AppTheme.colors.surfaceBorder,
                                        borderRadius: BorderRadius.circular(10.r),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        letter,
                                        style: AppTheme.textStyles.posLabel.copyWith(
                                          color: highlighted ? Colors.white : AppTheme.colors.textSecondary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Text(
                                        answer.answerText,
                                        style: AppTheme.textStyles.posLabel.copyWith(
                                          color: highlighted ? AppTheme.colors.textPrimary : null,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        });
                      }).toList(),
                    )),
                    SizedBox(height: 12.h),
                    // Correcao da questao
                    Obx(() {
                      final result = controller.currentResult.value;
                      if (result == null) return const SizedBox.shrink();
                      final color = result.isCorrect ? AppTheme.colors.success : AppTheme.colors.error;
                      final points = result.isCorrect
                          ? (result.pointsAwarded > 0 ? '+${result.pointsAwarded} pontos no ranking' : 'Questão já pontuada antes')
                          : 'Nenhum ponto nesta questão';
                      return FadeIn(
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(14.r),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(color: color.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(result.isCorrect ? Icons.check_circle : Icons.cancel, color: color, size: 24.sp),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      result.isCorrect ? 'Resposta correta!' : 'Resposta incorreta.',
                                      style: AppTheme.textStyles.posLabel.copyWith(color: color, fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      points,
                                      style: AppTheme.textStyles.label.copyWith(color: AppTheme.colors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
            // Submit Button
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppTheme.colors.backgroundCard,
                border: Border(top: BorderSide(color: AppTheme.colors.surfaceBorder)),
              ),
              child: SafeArea(
                top: false,
                child: Obx(() {
                  final isAnswered = controller.isAnswered;
                  final hasSelection = controller.selectedAnswer.value != null;
                  final isSubmitting = controller.isSubmitting.value;
                  final onTap = isAnswered
                      ? controller.next
                      : (hasSelection && !isSubmitting)
                          ? controller.submitAnswer
                          : null;

                  return GestureDetector(
                    onTap: onTap,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        gradient: hasSelection
                            ? LinearGradient(colors: [
                                AppTheme.colors.primary,
                                AppTheme.colors.primary.withOpacity(0.8),
                              ])
                            : null,
                        color: hasSelection ? null : AppTheme.colors.surfaceBorder,
                      ),
                      child: Center(
                        child: isSubmitting
                            ? SizedBox(
                                height: 22.h,
                                width: 22.h,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                !isAnswered
                                    ? 'Confirmar'
                                    : controller.isLastQuestion
                                        ? 'Ver resultado'
                                        : 'Próxima',
                                style: AppTheme.textStyles.subTitle.copyWith(
                                  color: hasSelection ? Colors.white : AppTheme.colors.textMuted,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.colors.backgroundCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Sair da partida?', style: AppTheme.textStyles.subTitle),
        content: Text(
          'As respostas já enviadas continuam valendo para o ranking.',
          style: AppTheme.textStyles.posLabel.copyWith(
            color: AppTheme.colors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancelar', style: TextStyle(color: AppTheme.colors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.back();
            },
            child: Text('Sair', style: TextStyle(color: AppTheme.colors.error)),
          ),
        ],
      ),
    );
  }
}
