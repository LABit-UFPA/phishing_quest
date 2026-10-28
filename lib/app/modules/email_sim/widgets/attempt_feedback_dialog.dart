import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:phishing_quest/app/data/models/attempt_result.model.dart';
import 'package:phishing_quest/app/global_ui/app_theme.dart';
import 'package:phishing_quest/app/global_ui/components/feedback_panel.dart';

/// Feedback de uma decisao. Na condicao binaria, so o acerto ou erro; na
/// formativa, tambem a avaliacao da justificativa pelo modelo de
/// linguagem. A condicao vem do servidor, na resposta da tentativa.
class AttemptFeedbackDialog extends StatelessWidget {
  final AttemptResultModel result;
  final bool clickedMaliciousLink;
  final VoidCallback onClose;

  const AttemptFeedbackDialog({
    required this.result,
    required this.clickedMaliciousLink,
    required this.onClose,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isCorrect = result.isCorrect;
    final color = isCorrect ? AppTheme.colors.success : AppTheme.colors.error;
    final evaluation = result.evaluation;

    return Dialog(
      backgroundColor: AppTheme.colors.backgroundCard,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded, color: color, size: 64.sp),
              SizedBox(height: 12.h),
              Text(
                isCorrect ? 'Você acertou!' : 'Você errou.',
                style: AppTheme.textStyles.title.copyWith(color: color, fontWeight: FontWeight.w700),
              ),
              if (clickedMaliciousLink) ...[
                SizedBox(height: 12.h),
                _notice(
                  icon: Icons.link_off,
                  color: AppTheme.colors.error,
                  text: 'Você clicou em um link malicioso desta mensagem.',
                ),
              ],
              if (result.isFormative) ...[
                SizedBox(height: 16.h),
                if (evaluation != null) ...[
                  FeedbackPanel(
                    aiRating: evaluation.score,
                    feedback: evaluation.feedback.isEmpty ? null : evaluation.feedback,
                    strengths: evaluation.strengths,
                    improvements: evaluation.improvements,
                  ),
                  if (evaluation.acertoPorSorte) ...[
                    SizedBox(height: 10.h),
                    _notice(
                      icon: Icons.casino_outlined,
                      color: AppTheme.colors.warning,
                      text: 'A justificativa não sustenta a decisão: o acerto pode ter sido por sorte.',
                    ),
                  ],
                ] else if (result.evaluationError != null)
                  _notice(
                    icon: Icons.cloud_off_rounded,
                    color: AppTheme.colors.textMuted,
                    text: 'A avaliação da sua justificativa não está disponível agora. Sua decisão foi registrada.',
                  ),
              ],
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onClose,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.colors.primary,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  ),
                  child: Text(
                    'Voltar para a caixa de entrada',
                    style: AppTheme.textStyles.posLabel.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _notice({required IconData icon, required Color color, required String text}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: AppTheme.textStyles.label.copyWith(color: AppTheme.colors.textSecondary, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> show(AttemptResultModel result, {required bool clickedMaliciousLink}) {
    return Get.dialog(
      AttemptFeedbackDialog(
        result: result,
        clickedMaliciousLink: clickedMaliciousLink,
        onClose: () => Get.back(),
      ),
      barrierDismissible: false,
    );
  }
}
