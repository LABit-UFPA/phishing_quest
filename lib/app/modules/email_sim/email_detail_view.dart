import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:phishing_quest/app/data/models/email_content.model.dart';
import 'package:phishing_quest/app/data/models/inbox_item.model.dart';
import 'package:phishing_quest/app/global_ui/app_theme.dart';
import 'package:phishing_quest/app/global_ui/components/email_preview_card.dart';
import 'package:phishing_quest/app/global_ui/components/phishing_link_popup.dart';
import 'package:phishing_quest/app/modules/email_sim/email_sim_controller.dart';
import 'package:phishing_quest/app/modules/email_sim/email_sim_routes.dart';
import 'package:phishing_quest/app/modules/email_sim/widgets/attempt_feedback_dialog.dart';
import 'package:phishing_quest/app/modules/email_sim/widgets/decision_sheet.dart';

class EmailDetailView extends GetView<EmailSimController> {
  const EmailDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final item = controller.itemById(args['itemId'] as String);
    if (item == null) {
      return Scaffold(backgroundColor: AppTheme.colors.backgroundDark);
    }
    final email = item.content;

    return Scaffold(
      backgroundColor: AppTheme.colors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.colors.backgroundCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          // Cosmetic icons for realism
          IconButton(
            icon: Icon(Icons.star_border, color: AppTheme.colors.textMuted),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: AppTheme.colors.textMuted),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: AppTheme.colors.textMuted),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subject
                  FadeInDown(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
                      color: AppTheme.colors.backgroundCard,
                      child: Text(
                        email.subject,
                        style: AppTheme.textStyles.title.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  // Sender info
                  FadeInDown(
                    delay: const Duration(milliseconds: 100),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
                      decoration: BoxDecoration(
                        color: AppTheme.colors.backgroundCard,
                        border: Border(
                          bottom: BorderSide(
                            color: AppTheme.colors.surfaceBorder.withOpacity(0.3),
                          ),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 22.r,
                            backgroundColor: _avatarColor(email.senderName).withOpacity(0.2),
                            child: Text(
                              email.avatarInitial,
                              style: TextStyle(
                                color: _avatarColor(email.senderName),
                                fontWeight: FontWeight.w700,
                                fontSize: 16.sp,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        email.senderName,
                                        style: AppTheme.textStyles.posLabel.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      _formatDateTime(item.receivedAt),
                                      style: AppTheme.textStyles.prepreLabel.copyWith(
                                        color: AppTheme.colors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  email.sender,
                                  style: AppTheme.textStyles.label.copyWith(
                                    color: AppTheme.colors.textSecondary,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'Para: ${email.recipient}',
                                  style: AppTheme.textStyles.prepreLabel.copyWith(
                                    color: AppTheme.colors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Email body
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.all(16.r),
                      padding: EdgeInsets.all(20.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _buildEmailBody(item),
                    ),
                  ),
                  // Links section
                  if (email.links.isNotEmpty)
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 16.w),
                        padding: EdgeInsets.all(14.r),
                        decoration: BoxDecoration(
                          color: AppTheme.colors.backgroundCard,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: AppTheme.colors.surfaceBorder.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.link, size: 16.sp, color: AppTheme.colors.textMuted),
                                SizedBox(width: 6.w),
                                Text(
                                  'Links neste e-mail:',
                                  style: AppTheme.textStyles.label.copyWith(
                                    color: AppTheme.colors.textMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            ...email.links.map((link) => Padding(
                                  padding: EdgeInsets.only(bottom: 6.h),
                                  child: LinkDestination(link: link, onTap: () => _onLinkTap(item, link)),
                                )),
                          ],
                        ),
                      ),
                    ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
          // Bottom action
          Obx(() {
            final isEvaluated = controller.isEvaluated(item.id);
            final isSubmitting = controller.isSubmitting.value;
            final enabled = !isEvaluated && !isSubmitting;
            return Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppTheme.colors.backgroundCard,
                border: Border(
                  top: BorderSide(color: AppTheme.colors.surfaceBorder.withOpacity(0.3)),
                ),
              ),
              child: SafeArea(
                top: false,
                child: GestureDetector(
                  onTap: enabled ? () => _decide(item) : null,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      gradient: enabled
                          ? LinearGradient(colors: [
                              AppTheme.colors.accent,
                              AppTheme.colors.accent.withOpacity(0.8),
                            ])
                          : null,
                      color: enabled ? null : AppTheme.colors.surfaceBorder,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isSubmitting)
                          SizedBox(
                            height: 20.h,
                            width: 20.h,
                            child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        else
                          Icon(
                            isEvaluated ? Icons.check_circle : Icons.shield_rounded,
                            color: isEvaluated ? AppTheme.colors.textMuted : Colors.white,
                            size: 22.sp,
                          ),
                        SizedBox(width: 8.w),
                        Text(
                          isSubmitting
                              ? 'Registrando decisão...'
                              : isEvaluated
                                  ? 'Já avaliado'
                                  : 'Avaliar este e-mail',
                          style: AppTheme.textStyles.subTitle.copyWith(
                            color: isEvaluated ? AppTheme.colors.textMuted : Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _decide(InboxItemModel item) async {
    final decision = await DecisionSheet.show();
    if (decision == null) return;

    final result = await controller.submitDecision(item, decision);
    if (result == null) return;

    await AttemptFeedbackDialog.show(
      result,
      clickedMaliciousLink: controller.maliciousClicks.contains(item.id),
    );
    if (Get.currentRoute == EmailSimRoutes.detail) {
      Get.back();
    }
  }

  TextStyle get _bodyStyle => TextStyle(
        color: const Color(0xFF1E293B),
        fontSize: 13.sp,
        height: 1.7,
        fontFamily: 'serif',
      );

  /// Corpo do e-mail com os links clicaveis no lugar em que aparecem.
  /// O texto do link e procurado no corpo; se nao estiver la, o link fica
  /// so na lista abaixo do corpo.
  Widget _buildEmailBody(InboxItemModel item) {
    final email = item.content;
    if (email.links.isEmpty) {
      return Text(email.body, style: _bodyStyle);
    }

    final spans = <InlineSpan>[];
    String remaining = email.body;

    for (final link in email.links) {
      final idx = remaining.indexOf(link.text);
      if (idx < 0 || link.text.isEmpty) continue;
      if (idx > 0) {
        spans.add(TextSpan(text: remaining.substring(0, idx), style: _bodyStyle));
      }
      spans.add(TextSpan(
        text: link.text,
        style: _bodyStyle.copyWith(
          color: const Color(0xFF2563EB),
          decoration: TextDecoration.underline,
          decorationColor: const Color(0xFF2563EB),
        ),
        recognizer: TapGestureRecognizer()..onTap = () => _onLinkTap(item, link),
      ));
      remaining = remaining.substring(idx + link.text.length);
    }

    if (remaining.isNotEmpty) {
      spans.add(TextSpan(text: remaining, style: _bodyStyle));
    }

    return RichText(text: TextSpan(children: spans));
  }

  /// O link nunca e aberto. A API diz se era malicioso: se era, o alerta
  /// aparece e o clique desconta pontos; se nao, o jogador so e avisado
  /// de que o ambiente e simulado, sem revelar o rotulo.
  Future<void> _onLinkTap(InboxItemModel item, EmailLink link) async {
    final alreadyPenalized = controller.maliciousClicks.contains(item.id);
    final malicious = await controller.onLinkTapped(item, link);

    if (malicious == true) {
      Get.dialog(
        PhishingLinkPopup(
          url: link.href,
          penalty: alreadyPenalized ? 0 : EmailSimController.maliciousClickPenalty,
          onDismiss: () => Get.back(),
        ),
        barrierDismissible: false,
        useSafeArea: false,
      );
    } else {
      Get.snackbar(
        'Ambiente simulado',
        'O link não foi aberto. Destino: ${link.href}',
        backgroundColor: AppTheme.colors.backgroundCard,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(12.r),
        duration: const Duration(seconds: 3),
      );
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Color _avatarColor(String name) {
    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFFEF4444),
      const Color(0xFF22C55E),
      const Color(0xFFF97316),
      const Color(0xFF8B5CF6),
      const Color(0xFF06B6D4),
      const Color(0xFFEC4899),
    ];
    final hash = name.codeUnits.fold<int>(0, (prev, c) => prev + c);
    return colors[hash % colors.length];
  }
}
