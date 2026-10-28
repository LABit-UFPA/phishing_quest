import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:phishing_quest/app/data/services/auth_service.dart';
import 'package:phishing_quest/app/global_ui/app_theme.dart';
import 'package:phishing_quest/app/modules/admin/admin_view.dart';
import 'package:phishing_quest/app/modules/dashboard/dashboard_view.dart';
import 'package:phishing_quest/app/modules/main_shell/main_shell_controller.dart';
import 'package:phishing_quest/app/modules/play/play_view.dart';
import 'package:phishing_quest/app/modules/profile/profile_view.dart';
import 'package:phishing_quest/app/modules/ranking/ranking_view.dart';

class MainShellView extends GetView<MainShellController> {
  const MainShellView({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();

    return Obx(() {
      final canCurate = authService.canCurate;
      final pages = <Widget>[
        const DashboardView(),
        const PlayView(),
        const RankingView(),
        const ProfileView(),
        if (canCurate) const AdminView(),
      ];

      final items = <BottomNavigationBarItem>[
        _buildNavItem(Icons.dashboard_rounded, 'Início', 0),
        _buildNavItem(Icons.play_circle_fill_rounded, 'Jogar', 1),
        _buildNavItem(Icons.emoji_events_rounded, 'Ranking', 2),
        _buildNavItem(Icons.person_rounded, 'Perfil', 3),
        if (canCurate) _buildNavItem(Icons.fact_check_rounded, 'Curadoria', 4),
      ];

      // Ensure index is within bounds
      final maxIndex = pages.length - 1;
      if (controller.currentIndex.value > maxIndex) {
        controller.currentIndex.value = 0;
      }

      return Scaffold(
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: pages,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppTheme.colors.backgroundCard,
            border: Border(
              top: BorderSide(
                color: AppTheme.colors.surfaceBorder.withOpacity(0.3),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: items.length > 4 ? 4.w : 8.w,
                vertical: 8.h,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(items.length, (index) {
                  final isSelected = controller.currentIndex.value == index;
                  final item = items[index];
                  return Flexible(
                    child: _NavBarItem(
                      icon: (item.icon as Icon).icon!,
                      label: item.label!,
                      isSelected: isSelected,
                      onTap: () => controller.changePage(index),
                      isCompact: items.length > 4,
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      );
    });
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label, int index) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      label: label,
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isCompact;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 8.w : 16.w,
          vertical: 8.h,
        ),
        decoration: isSelected
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                color: AppTheme.colors.primary.withOpacity(0.15),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.colors.primary : AppTheme.colors.textMuted,
              size: isCompact ? 22.sp : 24.sp,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.colors.primary : AppTheme.colors.textMuted,
                fontSize: isCompact ? 9.sp : 10.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
