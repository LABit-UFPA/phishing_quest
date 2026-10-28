import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:phishing_quest/app/global_ui/app_theme.dart';

class PhishingLinkPopup extends StatelessWidget {
  final String url;
  final VoidCallback onDismiss;

  /// Pontos descontados por este clique (0 se a mensagem ja tinha sido
  /// penalizada).
  final int penalty;

  const PhishingLinkPopup({
    required this.url,
    required this.onDismiss,
    this.penalty = 0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.85),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pulsing shield icon
              Pulse(
                infinite: true,
                duration: const Duration(milliseconds: 1500),
                child: Container(
                  width: 120.r,
                  height: 120.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.colors.error.withOpacity(0.15),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.colors.error.withOpacity(0.3),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.gpp_bad_rounded,
                      size: 64.sp,
                      color: AppTheme.colors.error,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32.h),
              // Title
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: Text(
                  'CUIDADO!',
                  style: AppTheme.textStyles.display.copyWith(
                    color: AppTheme.colors.error,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: Text(
                  'Você clicou em um link malicioso!',
                  style: AppTheme.textStyles.title.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 24.h),
              // Warning message
              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: AppTheme.colors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: AppTheme.colors.error.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Em um cenário real, suas credenciais poderiam ter sido roubadas ou um malware instalado no seu dispositivo.'
                        '${penalty > 0 ? ' Foram descontados $penalty pontos.' : ''}',
                        style: AppTheme.textStyles.posLabel.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.link, size: 16.sp, color: AppTheme.colors.error),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                url,
                                style: TextStyle(
                                  color: AppTheme.colors.error,
                                  fontSize: 11.sp,
                                  fontFamily: 'monospace',
                                ),
                                overflow: TextOverflow.ellipsis,
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
              // Educational tip
              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: Container(
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    color: AppTheme.colors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: AppTheme.colors.primary.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: AppTheme.colors.accent, size: 22.sp),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Dica: antes de clicar, compare o texto do link com o destino real e confira o domínio.',
                          style: AppTheme.textStyles.label.copyWith(
                            color: AppTheme.colors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 32.h),
              // Dismiss button
              FadeInUp(
                delay: const Duration(milliseconds: 700),
                child: GestureDetector(
                  onTap: onDismiss,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.colors.error,
                          AppTheme.colors.error.withOpacity(0.8),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.colors.error.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Entendi',
                        style: AppTheme.textStyles.subTitle.copyWith(
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
      ),
    );
  }
}
