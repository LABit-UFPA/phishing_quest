import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phishing_quest/app/global_ui/app_theme.dart';
import 'package:phishing_quest/app/global_ui/components/rating_stars.dart';

/// Avaliacao da justificativa pelo modelo de linguagem: nota de 0 a 5,
/// comentario, pontos fortes e pontos a melhorar.
class FeedbackPanel extends StatefulWidget {
  final String title;
  final int? aiRating;
  final String? feedback;
  final List<String>? strengths;
  final List<String>? improvements;
  final bool initiallyExpanded;

  const FeedbackPanel({
    this.title = 'Avaliação da sua justificativa',
    this.aiRating,
    this.feedback,
    this.strengths,
    this.improvements,
    this.initiallyExpanded = true,
    super.key,
  });

  @override
  State<FeedbackPanel> createState() => _FeedbackPanelState();
}

class _FeedbackPanelState extends State<FeedbackPanel> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.aiRating == null && widget.feedback == null) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: AppTheme.colors.backgroundCard,
        border: Border.all(
          color: AppTheme.colors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(16.r),
              bottom: _isExpanded ? Radius.zero : Radius.circular(16.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: AppTheme.colors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.psychology,
                      color: AppTheme.colors.primary,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: AppTheme.textStyles.subTitle.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (widget.aiRating != null)
                          RatingStars(rating: widget.aiRating!, starSize: 16.sp, showLabel: true),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more,
                      color: AppTheme.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content
          AnimatedCrossFade(
            firstChild: _buildContent(),
            secondChild: const SizedBox(width: double.infinity),
            crossFadeState: _isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.feedback != null) ...[
            Divider(color: AppTheme.colors.surfaceBorder.withOpacity(0.3)),
            SizedBox(height: 8.h),
            Text(
              widget.feedback!,
              style: AppTheme.textStyles.posLabel.copyWith(
                color: AppTheme.colors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
          if (widget.strengths != null && widget.strengths!.isNotEmpty) ...[
            SizedBox(height: 16.h),
            _buildSection(
              icon: Icons.check_circle,
              title: 'Pontos Fortes',
              items: widget.strengths!,
              color: AppTheme.colors.success,
            ),
          ],
          if (widget.improvements != null && widget.improvements!.isNotEmpty) ...[
            SizedBox(height: 16.h),
            _buildSection(
              icon: Icons.lightbulb,
              title: 'Para Melhorar',
              items: widget.improvements!,
              color: AppTheme.colors.accent,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required List<String> items,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16.sp),
            SizedBox(width: 6.w),
            Text(
              title,
              style: AppTheme.textStyles.posLabel.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ...items.map((item) => Padding(
          padding: EdgeInsets.only(left: 8.w, bottom: 4.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('•  ', style: TextStyle(color: color, fontSize: 14.sp)),
              Expanded(
                child: Text(
                  item,
                  style: AppTheme.textStyles.label.copyWith(
                    color: AppTheme.colors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}
