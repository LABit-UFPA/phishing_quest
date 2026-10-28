import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:phishing_quest/app/data/models/category.model.dart';
import 'package:phishing_quest/app/data/services/auth_service.dart';
import 'package:phishing_quest/app/global_ui/app_theme.dart';
import 'package:phishing_quest/app/global_ui/components/game_card.dart';
import 'package:phishing_quest/app/global_ui/components/score_badge.dart';
import 'package:phishing_quest/app/modules/dashboard/dashboard_controller.dart';
import 'package:phishing_quest/app/modules/main_shell/main_shell_controller.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());
    final authService = Get.find<AuthService>();

    return Scaffold(
      backgroundColor: AppTheme.colors.backgroundDark,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: controller.loadData,
            color: AppTheme.colors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(bottom: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  FadeInDown(
                    duration: const Duration(milliseconds: 500),
                    child: _buildHeader(authService),
                  ),
                  SizedBox(height: 20.h),
                  // Quick Stats
                  FadeInLeft(
                    duration: const Duration(milliseconds: 600),
                    child: _buildQuickStats(controller),
                  ),
                  SizedBox(height: 24.h),
                  // Play CTA
                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    child: _buildPlayCTA(),
                  ),
                  SizedBox(height: 24.h),
                  // Categories
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Text(
                      'Categorias',
                      style: AppTheme.textStyles.title,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  ...controller.categories.asMap().entries.map((entry) {
                    return FadeInRight(
                      duration: const Duration(milliseconds: 400),
                      delay: Duration(milliseconds: entry.key * 100),
                      child: _buildCategoryCard(entry.value),
                    );
                  }),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader(AuthService authService) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.colors.backgroundCard,
            AppTheme.colors.backgroundDark,
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, ${authService.currentUser.value?.username ?? 'Jogador'}! 👋',
                  style: AppTheme.textStyles.title.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Pronto para testar seus conhecimentos?',
                  style: AppTheme.textStyles.label.copyWith(
                    color: AppTheme.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Obx(() => ScoreBadge(
                score: authService.currentUser.value?.totalScore ?? 0,
                size: 60.r,
              )),
        ],
      ),
    );
  }

  Widget _buildQuickStats(DashboardController controller) {
    final stats = controller.stats.value;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          _buildStatCard(
            icon: Icons.check_circle,
            value: '${((stats?.accuracy ?? 0) * 100).round()}%',
            label: 'Acurácia',
            color: AppTheme.colors.success,
          ),
          SizedBox(width: 12.w),
          _buildStatCard(
            icon: Icons.mail_outline,
            value: '${stats?.totalAttempts ?? 0}',
            label: 'Decisões',
            color: AppTheme.colors.primary,
          ),
          SizedBox(width: 12.w),
          _buildStatCard(
            icon: Icons.leaderboard,
            value: controller.userRank.value != null ? '#${controller.userRank.value}' : '-',
            label: 'Ranking',
            color: AppTheme.colors.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: AppTheme.colors.backgroundCard,
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24.sp),
            SizedBox(height: 8.h),
            Text(
              value,
              style: AppTheme.textStyles.title.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: AppTheme.textStyles.prepreLabel.copyWith(
                color: AppTheme.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayCTA() {
    return GestureDetector(
      onTap: () {
        final mainController = Get.find<MainShellController>();
        mainController.changePage(1);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.colors.primary,
              AppTheme.colors.primaryDark,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.colors.primary.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 32.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jogar Agora',
                    style: AppTheme.textStyles.title.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Quiz ou caixa de entrada simulada',
                    style: AppTheme.textStyles.label.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withOpacity(0.7),
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(CategoryModel category) {
    final icons = {'🏢': Icons.business, '🧠': Icons.psychology, '🔒': Icons.lock};
    final iconData = icons[category.icon] ?? Icons.category;

    return GameCard(
      onTap: () {
        final mainController = Get.find<MainShellController>();
        mainController.changePage(1);
      },
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppTheme.colors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(iconData, color: AppTheme.colors.primary, size: 28.sp),
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
                  ),
                ),
                if (category.description != null)
                  Text(
                    category.description!,
                    style: AppTheme.textStyles.label.copyWith(
                      color: AppTheme.colors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.colors.textMuted, size: 16.sp),
        ],
      ),
    );
  }
}
