import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:phishing_quest/app/global_ui/app_theme.dart';
import 'package:phishing_quest/app/global_ui/components/inbox_email_tile.dart';
import 'package:phishing_quest/app/modules/email_sim/email_sim_controller.dart';

class EmailInboxView extends GetView<EmailSimController> {
  const EmailInboxView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.colors.backgroundCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => _showExitDialog(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mail_rounded, color: AppTheme.colors.primary, size: 22.sp),
            SizedBox(width: 8.w),
            Text('Caixa de Entrada', style: AppTheme.textStyles.subTitle),
          ],
        ),
        centerTitle: true,
        actions: [
          Obx(() => Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppTheme.colors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '${controller.evaluatedCount}/${controller.inbox.length}',
                  style: AppTheme.textStyles.label.copyWith(
                    color: AppTheme.colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          )),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.loadError.value != null) {
          return _buildMessage(
            icon: Icons.cloud_off_rounded,
            title: 'Não foi possível carregar a caixa de entrada',
            body: controller.loadError.value!,
            actionLabel: 'Tentar de novo',
            onAction: controller.loadInbox,
          );
        }

        if (controller.inbox.isEmpty) {
          return _buildMessage(
            icon: Icons.mark_email_read_outlined,
            title: 'Nenhuma mensagem nova',
            body: 'Você já viu todas as mensagens disponíveis nesta sessão. Volte mais tarde para novas mensagens e revisões.',
            actionLabel: 'Voltar',
            onAction: Get.back,
          );
        }

        return Column(
          children: [
            // Search bar (cosmetic)
            FadeInDown(
              child: Container(
                margin: EdgeInsets.all(12.r),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppTheme.colors.backgroundCard,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppTheme.colors.surfaceBorder.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: AppTheme.colors.textMuted, size: 20.sp),
                    SizedBox(width: 10.w),
                    Text(
                      'Pesquisar e-mails...',
                      style: AppTheme.textStyles.label.copyWith(color: AppTheme.colors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
            // Progress
            Obx(() => Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Text(
                    '${controller.inbox.length} e-mails',
                    style: AppTheme.textStyles.prepreLabel.copyWith(
                      color: AppTheme.colors.textMuted,
                    ),
                  ),
                  const Spacer(),
                  if (controller.evaluatedCount > 0)
                    Text(
                      '${controller.evaluatedCount} avaliados',
                      style: AppTheme.textStyles.prepreLabel.copyWith(
                        color: AppTheme.colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            )),
            SizedBox(height: 4.h),
            // Email list
            Expanded(
              child: Obx(() => ListView.builder(
                itemCount: controller.inbox.length,
                itemBuilder: (context, index) {
                  final item = controller.inbox[index];
                  final email = item.content;
                  final isEvaluated = controller.isEvaluated(item.id);
                  final wasCorrect = controller.wasCorrect(item.id);

                  return FadeInLeft(
                    delay: Duration(milliseconds: index * 60),
                    child: InboxEmailTile(
                      avatarInitial: email.avatarInitial,
                      senderName: email.senderName,
                      subject: email.subject,
                      preview: email.preview,
                      time: _formatTime(item.receivedAt),
                      isEvaluated: isEvaluated,
                      wasCorrect: wasCorrect,
                      onTap: () => controller.openItem(item),
                    ),
                  );
                },
              )),
            ),
            // Finish button
            Obx(() {
              if (controller.evaluatedCount == 0) return const SizedBox.shrink();

              return FadeInUp(
                child: Container(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
                  decoration: BoxDecoration(
                    color: AppTheme.colors.backgroundCard,
                    border: Border(
                      top: BorderSide(color: AppTheme.colors.surfaceBorder.withOpacity(0.3)),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: GestureDetector(
                      onTap: controller.allEvaluated ? controller.finishSimulation : null,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          gradient: controller.allEvaluated
                              ? LinearGradient(colors: [
                                  AppTheme.colors.accent,
                                  AppTheme.colors.accent.withOpacity(0.8),
                                ])
                              : null,
                          color: controller.allEvaluated ? null : AppTheme.colors.surfaceBorder,
                        ),
                        child: Center(
                          child: Text(
                            controller.allEvaluated
                                ? 'Finalizar rodada'
                                : 'Avalie todos os e-mails para finalizar',
                            style: AppTheme.textStyles.posLabel.copyWith(
                              color: controller.allEvaluated
                                  ? Colors.white
                                  : AppTheme.colors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      }),
    );
  }

  Widget _buildMessage({
    required IconData icon,
    required String title,
    required String body,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppTheme.colors.textMuted, size: 56.sp),
            SizedBox(height: 16.h),
            Text(title, style: AppTheme.textStyles.subTitle, textAlign: TextAlign.center),
            SizedBox(height: 8.h),
            Text(
              body,
              style: AppTheme.textStyles.label.copyWith(color: AppTheme.colors.textSecondary, height: 1.5),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.colors.primary),
              child: Text(actionLabel, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 60) return '${diff.inMinutes}min';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays == 1) return 'Ontem';
    return '${dt.day}/${dt.month}';
  }

  void _showExitDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.colors.backgroundCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Sair da caixa de entrada?', style: AppTheme.textStyles.subTitle),
        content: Text(
          'As decisões já enviadas ficam registradas. As mensagens não avaliadas podem voltar em outra sessão.',
          style: AppTheme.textStyles.posLabel.copyWith(color: AppTheme.colors.textSecondary),
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
