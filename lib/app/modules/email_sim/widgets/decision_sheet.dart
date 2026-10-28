import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:phishing_quest/app/global_ui/app_theme.dart';
import 'package:phishing_quest/app/modules/email_sim/email_sim_controller.dart';

/// Folha de decisao: veredito, acao, confianca de 1 a 5 e justificativa.
/// Fecha devolvendo um [InboxDecision], ou null se o jogador desistir.
class DecisionSheet extends StatefulWidget {
  static const int minJustificationLength = 10;

  const DecisionSheet({super.key});

  static Future<InboxDecision?> show() {
    return Get.bottomSheet<InboxDecision>(
      const DecisionSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<DecisionSheet> createState() => _DecisionSheetState();
}

class _DecisionSheetState extends State<DecisionSheet> {
  final TextEditingController _justification = TextEditingController();
  bool? _verdict;
  InboxAction? _action;
  int? _confidence;

  bool get _isComplete =>
      _verdict != null &&
      _action != null &&
      _confidence != null &&
      _justification.text.trim().length >= DecisionSheet.minJustificationLength;

  @override
  void dispose() {
    _justification.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h + MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: AppTheme.colors.backgroundCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppTheme.colors.surfaceBorder,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            _sectionTitle('Esta mensagem é phishing?'),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: _verdictCard(
                    value: true,
                    icon: Icons.warning_rounded,
                    label: 'Sim, é phishing',
                    color: AppTheme.colors.error,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _verdictCard(
                    value: false,
                    icon: Icons.verified_user_rounded,
                    label: 'Não, é legítima',
                    color: AppTheme.colors.success,
                  ),
                ),
              ],
            ),
            SizedBox(height: 18.h),
            _sectionTitle('O que você faria com ela?'),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: InboxAction.values.map((action) {
                final selected = _action == action;
                return ChoiceChip(
                  label: Text(action.label),
                  selected: selected,
                  onSelected: (_) => setState(() => _action = action),
                  selectedColor: AppTheme.colors.primary.withOpacity(0.25),
                  backgroundColor: AppTheme.colors.backgroundDark,
                  side: BorderSide(color: selected ? AppTheme.colors.primary : AppTheme.colors.surfaceBorder),
                  labelStyle: AppTheme.textStyles.label.copyWith(
                    color: selected ? AppTheme.colors.textPrimary : AppTheme.colors.textSecondary,
                  ),
                  showCheckmark: false,
                );
              }).toList(),
            ),
            SizedBox(height: 18.h),
            _sectionTitle('Qual a sua confiança?'),
            SizedBox(height: 10.h),
            Row(
              children: List.generate(5, (index) {
                final value = index + 1;
                final selected = _confidence == value;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _confidence = value),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      decoration: BoxDecoration(
                        color: selected ? AppTheme.colors.primary : AppTheme.colors.backgroundDark,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: selected ? AppTheme.colors.primary : AppTheme.colors.surfaceBorder),
                      ),
                      child: Center(
                        child: Text(
                          '$value',
                          style: AppTheme.textStyles.subTitle.copyWith(
                            color: selected ? Colors.white : AppTheme.colors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('1 = nada confiante', style: _hintStyle),
                Text('5 = totalmente confiante', style: _hintStyle),
              ],
            ),
            SizedBox(height: 18.h),
            _sectionTitle('Por quê?'),
            SizedBox(height: 10.h),
            TextField(
              controller: _justification,
              onChanged: (_) => setState(() {}),
              maxLines: 3,
              maxLength: 1000,
              style: AppTheme.textStyles.posLabel,
              decoration: InputDecoration(
                hintText: 'Conte o que levou você a essa decisão (remetente, links, tom da mensagem...)',
                hintStyle: AppTheme.textStyles.label.copyWith(color: AppTheme.colors.textMuted),
                hintMaxLines: 3,
                filled: true,
                fillColor: AppTheme.colors.backgroundDark,
                counterStyle: _hintStyle,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: _isComplete
                  ? () => Get.back(result: (
                        verdict: _verdict!,
                        action: _action!,
                        confidence: _confidence!,
                        justification: _justification.text.trim(),
                      ))
                  : null,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  color: _isComplete ? AppTheme.colors.primary : AppTheme.colors.surfaceBorder,
                ),
                child: Center(
                  child: Text(
                    _isComplete ? 'Confirmar decisão' : 'Preencha todos os campos',
                    style: AppTheme.textStyles.subTitle.copyWith(
                      color: _isComplete ? Colors.white : AppTheme.colors.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle get _hintStyle => AppTheme.textStyles.prepreLabel.copyWith(color: AppTheme.colors.textMuted);

  Widget _sectionTitle(String text) {
    return Text(text, style: AppTheme.textStyles.posLabel.copyWith(fontWeight: FontWeight.w700));
  }

  Widget _verdictCard({
    required bool value,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final selected = _verdict == value;
    return GestureDetector(
      onTap: () => setState(() => _verdict = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: selected ? color.withOpacity(0.2) : AppTheme.colors.backgroundDark,
          border: Border.all(
            color: selected ? color : AppTheme.colors.surfaceBorder,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? color : AppTheme.colors.textMuted, size: 26.sp),
            SizedBox(height: 6.h),
            Text(
              label,
              style: AppTheme.textStyles.label.copyWith(
                color: selected ? color : AppTheme.colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
