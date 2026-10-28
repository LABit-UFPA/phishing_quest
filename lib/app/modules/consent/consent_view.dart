import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:phishing_quest/app/data/constants/consent_term.dart';
import 'package:phishing_quest/app/global_ui/app_theme.dart';
import 'package:phishing_quest/app/modules/consent/consent_controller.dart';

class ConsentView extends GetView<ConsentController> {
  const ConsentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.colors.backgroundCard,
        elevation: 0,
        automaticallyImplyLeading: controller.canGoBack,
        title: Text('Participação na pesquisa', style: AppTheme.textStyles.subTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (controller.isReturning) ...[
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: AppTheme.colors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppTheme.colors.warning.withOpacity(0.3)),
                        ),
                        child: Text(
                          'Você retirou o consentimento antes. Para voltar a jogar a caixa de entrada, aceite o termo de novo.',
                          style: AppTheme.textStyles.label.copyWith(color: AppTheme.colors.textSecondary, height: 1.4),
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],
                    Text(consentTermTitle, style: AppTheme.textStyles.title.copyWith(fontWeight: FontWeight.w700)),
                    SizedBox(height: 4.h),
                    Text(
                      'Versão $consentTermVersion',
                      style: AppTheme.textStyles.prepreLabel.copyWith(color: AppTheme.colors.textMuted),
                    ),
                    SizedBox(height: 16.h),
                    ...consentTermSections.map((section) => Padding(
                          padding: EdgeInsets.only(bottom: 14.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                section.heading,
                                style: AppTheme.textStyles.posLabel.copyWith(
                                  color: AppTheme.colors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                section.body,
                                style: AppTheme.textStyles.label.copyWith(
                                  color: AppTheme.colors.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        )),
                    SizedBox(height: 8.h),
                    Text(
                      'Código da turma (opcional)',
                      style: AppTheme.textStyles.posLabel.copyWith(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 6.h),
                    TextField(
                      controller: controller.cohortCodeController,
                      textCapitalization: TextCapitalization.characters,
                      style: AppTheme.textStyles.posLabel,
                      decoration: InputDecoration(
                        hintText: 'Ex.: A7K2QP',
                        hintStyle: AppTheme.textStyles.label.copyWith(color: AppTheme.colors.textMuted),
                        helperText: 'Informado por quem aplica o estudo. Liga você ao ranking da turma.',
                        helperStyle: AppTheme.textStyles.prepreLabel.copyWith(color: AppTheme.colors.textMuted),
                        helperMaxLines: 2,
                        filled: true,
                        fillColor: AppTheme.colors.backgroundCard,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Obx(() => CheckboxListTile(
                          value: controller.hasReadTerm.value,
                          onChanged: (v) => controller.hasReadTerm.value = v ?? false,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: AppTheme.colors.primary,
                          title: Text(
                            'Li o termo e concordo em participar da pesquisa.',
                            style: AppTheme.textStyles.label.copyWith(color: AppTheme.colors.textPrimary),
                          ),
                        )),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
              decoration: BoxDecoration(
                color: AppTheme.colors.backgroundCard,
                border: Border(top: BorderSide(color: AppTheme.colors.surfaceBorder.withOpacity(0.3))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: controller.decline,
                      child: Text('Agora não', style: TextStyle(color: AppTheme.colors.textSecondary)),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    flex: 2,
                    child: Obx(() {
                      final enabled = controller.hasReadTerm.value && !controller.isSubmitting.value;
                      return ElevatedButton(
                        onPressed: enabled ? controller.accept : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.colors.primary,
                          disabledBackgroundColor: AppTheme.colors.surfaceBorder,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                        ),
                        child: controller.isSubmitting.value
                            ? SizedBox(
                                height: 20.h,
                                width: 20.h,
                                child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                'Aceito participar',
                                style: AppTheme.textStyles.posLabel.copyWith(
                                  color: enabled ? Colors.white : AppTheme.colors.textMuted,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
