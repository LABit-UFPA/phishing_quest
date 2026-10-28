import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:phishing_quest/app/global_ui/app_theme.dart';
import 'package:phishing_quest/app/global_ui/components/game_card.dart';
import 'package:phishing_quest/app/modules/play/play_controller.dart';

class PlayView extends StatelessWidget {
  const PlayView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PlayController());

    return Scaffold(
      backgroundColor: AppTheme.colors.backgroundDark,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                FadeInDown(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Jogar', style: AppTheme.textStyles.display),
                        SizedBox(height: 4.h),
                        Text(
                          'Escolha um modo de jogo',
                          style: AppTheme.textStyles.posLabel.copyWith(
                            color: AppTheme.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                // Game Mode Selection
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Text(
                    'Modo de Jogo',
                    style: AppTheme.textStyles.subTitle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                FadeInUp(
                  child: Obx(() {
                    final isQuizSelected = controller.selectedMode.value == GameMode.quiz;
                    return GameCard(
                      hasGlow: isQuizSelected,
                      glowColor: AppTheme.colors.accent,
                      onTap: () => controller.selectMode(GameMode.quiz),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(14.r),
                            decoration: BoxDecoration(
                              color: isQuizSelected
                                  ? AppTheme.colors.accent.withOpacity(0.2)
                                  : AppTheme.colors.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: Icon(
                              Icons.quiz_rounded,
                              color: isQuizSelected ? AppTheme.colors.accent : AppTheme.colors.textSecondary,
                              size: 32.sp,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Quiz Clássico',
                                  style: AppTheme.textStyles.subTitle.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isQuizSelected ? AppTheme.colors.accent : null,
                                  ),
                                ),
                                Text(
                                  'Até 5 questões de múltipla escolha por partida',
                                  style: AppTheme.textStyles.label.copyWith(
                                    color: AppTheme.colors.textSecondary,
                                  ),
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ),
                          if (isQuizSelected)
                            Icon(
                              Icons.check_circle,
                              color: AppTheme.colors.accent,
                              size: 24.sp,
                            ),
                        ],
                      ),
                    );
                  }),
                ),
                SizedBox(height: 12.h),
                FadeInUp(
                  delay: const Duration(milliseconds: 100),
                  child: Obx(() {
                    final isEmailSelected = controller.selectedMode.value == GameMode.emailSim;
                    return GameCard(
                      hasGlow: isEmailSelected,
                      glowColor: AppTheme.colors.primary,
                      onTap: () => controller.selectMode(GameMode.emailSim),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(14.r),
                            decoration: BoxDecoration(
                              color: isEmailSelected
                                  ? AppTheme.colors.primary.withOpacity(0.2)
                                  : AppTheme.colors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: Icon(
                              Icons.mail_outline_rounded,
                              color: isEmailSelected ? AppTheme.colors.primary : AppTheme.colors.textSecondary,
                              size: 32.sp,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Simulação de Email',
                                  style: AppTheme.textStyles.subTitle.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isEmailSelected ? AppTheme.colors.primary : null,
                                  ),
                                ),
                                Text(
                                  'Identifique phishing em uma caixa de entrada',
                                  style: AppTheme.textStyles.label.copyWith(
                                    color: AppTheme.colors.textSecondary,
                                  ),
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ),
                          if (isEmailSelected)
                            Icon(
                              Icons.check_circle,
                              color: AppTheme.colors.primary,
                              size: 24.sp,
                            ),
                        ],
                      ),
                    );
                  }),
                ),
                SizedBox(height: 28.h),
                // Show category selection only if Quiz mode is selected
                Obx(() {
                  if (controller.selectedMode.value != GameMode.quiz) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Categories
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Text(
                          'Categorias',
                          style: AppTheme.textStyles.subTitle.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      ...controller.categories.asMap().entries.map((entry) {
                        final category = entry.value;
                        final index = entry.key;
                        final icons = {'🏢': Icons.business, '🧠': Icons.psychology, '🔒': Icons.lock};
                        final iconData = icons[category.icon] ?? Icons.category;

                        return FadeInUp(
                          delay: Duration(milliseconds: index * 100),
                          child: Obx(() {
                            final isSelected = controller.selectedCategory.value?.id == category.id;
                            return GameCard(
                              hasGlow: isSelected,
                              glowColor: AppTheme.colors.primary,
                              onTap: () => controller.selectCategory(category),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(14.r),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppTheme.colors.primary.withOpacity(0.2)
                                          : AppTheme.colors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(14.r),
                                    ),
                                    child: Icon(
                                      iconData,
                                      color: isSelected ? AppTheme.colors.primary : AppTheme.colors.textSecondary,
                                      size: 28.sp,
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          category.categoryName,
                                          style: AppTheme.textStyles.subTitle.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: isSelected ? AppTheme.colors.primary : null,
                                          ),
                                        ),
                                        if (category.description != null)
                                          Text(
                                            category.description!,
                                            style: AppTheme.textStyles.label.copyWith(
                                              color: AppTheme.colors.textSecondary,
                                            ),
                                            maxLines: 2,
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle,
                                      color: AppTheme.colors.primary,
                                      size: 24.sp,
                                    ),
                                ],
                              ),
                            );
                          }),
                        );
                      }),
                      SizedBox(height: 12.h),
                    ],
                  );
                }),
                SizedBox(height: 20.h),
                // Start Game Button
                FadeInUp(
                  child: Obx(() {
                    final isEmailMode = controller.selectedMode.value == GameMode.emailSim;
                    final hasSelection = isEmailMode || controller.selectedCategory.value != null;
                    final buttonText = isEmailMode ? 'Abrir caixa de entrada' : 'Iniciar partida';
                    
                    return GestureDetector(
                      onTap: hasSelection ? controller.startGame : null,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 16.w),
                        padding: EdgeInsets.symmetric(vertical: 18.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.r),
                          gradient: hasSelection
                              ? LinearGradient(
                                  colors: [
                                    isEmailMode ? AppTheme.colors.primary : AppTheme.colors.accent,
                                    (isEmailMode ? AppTheme.colors.primary : AppTheme.colors.accent).withOpacity(0.8),
                                  ],
                                )
                              : null,
                          color: hasSelection ? null : AppTheme.colors.surfaceBorder,
                          boxShadow: hasSelection
                              ? [
                                  BoxShadow(
                                    color: (isEmailMode ? AppTheme.colors.primary : AppTheme.colors.accent).withOpacity(0.4),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isEmailMode ? Icons.mail_outline_rounded : Icons.play_arrow_rounded,
                              color: hasSelection ? Colors.white : AppTheme.colors.textMuted,
                              size: 28.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              buttonText,
                              style: AppTheme.textStyles.title.copyWith(
                                color: hasSelection ? Colors.white : AppTheme.colors.textMuted,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
