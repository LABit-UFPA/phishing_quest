import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:phishing_quest/app/data/models/participant.model.dart';
import 'package:phishing_quest/app/data/models/user_stats.model.dart';
import 'package:phishing_quest/app/global_ui/app_theme.dart';
import 'package:phishing_quest/app/global_ui/components/game_card.dart';
import 'package:phishing_quest/app/global_ui/components/score_badge.dart';
import 'package:phishing_quest/app/modules/profile/profile_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: AppTheme.colors.backgroundDark,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = controller.auth.currentUser.value;
          final stats = controller.stats.value;

          return RefreshIndicator(
            color: AppTheme.colors.primary,
            backgroundColor: AppTheme.colors.backgroundCard,
            onRefresh: controller.loadStats,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Column(
                children: [
                  // Profile Header
                  FadeInDown(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.r),
                      decoration: BoxDecoration(
                        color: AppTheme.colors.backgroundCard,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40.r,
                            backgroundColor: AppTheme.colors.primary.withOpacity(0.2),
                            child: Text(
                              (user?.username.isNotEmpty ?? false) ? user!.username[0].toUpperCase() : 'U',
                              style: TextStyle(
                                color: AppTheme.colors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 32.sp,
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            user?.username ?? 'Jogador',
                            style: AppTheme.textStyles.title.copyWith(fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            user?.email ?? '',
                            style: AppTheme.textStyles.label.copyWith(color: AppTheme.colors.textSecondary),
                          ),
                          if (user != null && user.canCurate) ...[
                            SizedBox(height: 6.h),
                            Text(
                              user.role.label,
                              style: AppTheme.textStyles.prepreLabel.copyWith(color: AppTheme.colors.accent),
                            ),
                          ],
                          SizedBox(height: 16.h),
                          ScoreBadge(score: user?.totalScore ?? 0, size: 80.r),
                          SizedBox(height: 4.h),
                          Text(
                            'pontos no ranking',
                            style: AppTheme.textStyles.prepreLabel.copyWith(color: AppTheme.colors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (controller.loadError.value != null) ...[
                    SizedBox(height: 12.h),
                    Text(
                      controller.loadError.value!,
                      style: AppTheme.textStyles.label.copyWith(color: AppTheme.colors.error),
                    ),
                  ],
                  if (stats != null) ...[
                    SizedBox(height: 16.h),
                    FadeInUp(
                      delay: const Duration(milliseconds: 100),
                      child: _DetectionCard(stats: stats),
                    ),
                    SizedBox(height: 16.h),
                    FadeInUp(
                      delay: const Duration(milliseconds: 200),
                      child: _CueAccuracyCard(cues: stats.byCue),
                    ),
                  ],
                  SizedBox(height: 16.h),
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: _ParticipationCard(controller: controller, participant: controller.participant),
                  ),
                  SizedBox(height: 24.h),
                  // Logout
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: GestureDetector(
                      onTap: controller.logout,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          color: AppTheme.colors.error.withOpacity(0.1),
                          border: Border.all(color: AppTheme.colors.error.withOpacity(0.3)),
                        ),
                        child: Center(
                          child: Text(
                            'Sair da Conta',
                            style: AppTheme.textStyles.posLabel.copyWith(
                              color: AppTheme.colors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Deteccao de sinal ─────────────────────────────────────────────────────────
class _DetectionCard extends StatelessWidget {
  final UserStatsModel stats;
  const _DetectionCard({required this.stats});

  String _percent(double value) => '${(value * 100).round()}%';

  @override
  Widget build(BuildContext context) {
    return GameCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Desempenho na caixa de entrada',
            style: AppTheme.textStyles.subTitle.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 4.h),
          Text(
            '${stats.totalAttempts} decisões',
            style: AppTheme.textStyles.label.copyWith(color: AppTheme.colors.textMuted),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  value: stats.dPrime.toStringAsFixed(2),
                  label: "Sensibilidade (d')",
                  hint: 'Quanto maior, melhor você separa phishing de legítimo',
                  color: AppTheme.colors.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _Metric(
                  value: stats.criterion.toStringAsFixed(2),
                  label: 'Critério (c)',
                  hint: stats.criterionReading,
                  color: AppTheme.colors.accent,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(child: _SmallMetric(value: _percent(stats.accuracy), label: 'Acurácia')),
              Expanded(child: _SmallMetric(value: _percent(stats.hitRate), label: 'Acertos em phishing')),
              Expanded(child: _SmallMetric(value: _percent(stats.falseAlarmRate), label: 'Falsos alarmes')),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String value;
  final String label;
  final String hint;
  final Color color;

  const _Metric({required this.value, required this.label, required this.hint, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppTheme.textStyles.title.copyWith(color: color, fontWeight: FontWeight.w800)),
          Text(label, style: AppTheme.textStyles.label.copyWith(fontWeight: FontWeight.w600)),
          SizedBox(height: 4.h),
          Text(
            hint,
            style: AppTheme.textStyles.prepreLabel.copyWith(color: AppTheme.colors.textMuted, height: 1.3),
          ),
        ],
      ),
    );
  }
}

class _SmallMetric extends StatelessWidget {
  final String value;
  final String label;

  const _SmallMetric({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTheme.textStyles.subTitle.copyWith(fontWeight: FontWeight.w700)),
        Text(
          label,
          style: AppTheme.textStyles.prepreLabel.copyWith(color: AppTheme.colors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ── Acuracia por pista ────────────────────────────────────────────────────────
class _CueAccuracyCard extends StatelessWidget {
  final List<CuePerformance> cues;
  const _CueAccuracyCard({required this.cues});

  @override
  Widget build(BuildContext context) {
    final sorted = [...cues]..sort((a, b) => a.accuracy.compareTo(b.accuracy));

    return GameCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Acurácia por pista',
            style: AppTheme.textStyles.subTitle.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 4.h),
          Text(
            'Mensagens com cada sinal de phishing que você julgou certo',
            style: AppTheme.textStyles.label.copyWith(color: AppTheme.colors.textMuted),
          ),
          SizedBox(height: 14.h),
          if (sorted.isEmpty)
            Text(
              'Avalie mensagens na caixa de entrada para ver seu desempenho por pista.',
              style: AppTheme.textStyles.label.copyWith(color: AppTheme.colors.textSecondary),
            )
          else
            ...sorted.map((cue) => _CueBar(cue: cue)),
        ],
      ),
    );
  }
}

class _CueBar extends StatelessWidget {
  final CuePerformance cue;
  const _CueBar({required this.cue});

  @override
  Widget build(BuildContext context) {
    final accuracy = cue.accuracy.clamp(0.0, 1.0);
    final color = accuracy >= 0.75
        ? AppTheme.colors.success
        : accuracy >= 0.5
            ? AppTheme.colors.accent
            : AppTheme.colors.error;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  cue.labelPt.isNotEmpty ? cue.labelPt : cue.cueCode,
                  style: AppTheme.textStyles.label.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '${(accuracy * 100).round()}% · ${cue.correct}/${cue.answered}',
                style: AppTheme.textStyles.label.copyWith(color: AppTheme.colors.textSecondary),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: LinearProgressIndicator(
              value: accuracy,
              minHeight: 8.h,
              backgroundColor: AppTheme.colors.surfaceBorder,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Participacao na pesquisa ──────────────────────────────────────────────────
class _ParticipationCard extends StatelessWidget {
  final ProfileController controller;
  final ParticipantModel? participant;

  const _ParticipationCard({required this.controller, required this.participant});

  String _date(DateTime? value) {
    if (value == null) return '';
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    final active = participant?.active ?? false;

    return GameCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Participação na pesquisa',
            style: AppTheme.textStyles.subTitle.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          if (participant == null)
            _line('Você ainda não aceitou participar. Sem isso, a caixa de entrada fica indisponível.')
          else if (active) ...[
            _line('Participando desde ${_date(participant!.consentedAt)}.'),
            if (participant!.cohortName != null) _line('Turma: ${participant!.cohortName}'),
            _line('Termo aceito: ${participant!.consentVersion}'),
          ] else
            _line('Consentimento retirado em ${_date(participant!.withdrawnAt)}. Suas decisões não estão sendo registradas.'),
          SizedBox(height: 12.h),
          if (active)
            Obx(() => OutlinedButton(
                  onPressed: controller.isWithdrawing.value ? null : () => _confirmWithdraw(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.colors.error.withOpacity(0.6)),
                    minimumSize: Size(double.infinity, 44.h),
                  ),
                  child: Text('Retirar consentimento', style: TextStyle(color: AppTheme.colors.error)),
                ))
          else
            ElevatedButton(
              onPressed: controller.participate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.colors.primary,
                minimumSize: Size(double.infinity, 44.h),
              ),
              child: const Text('Participar da pesquisa', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }

  Widget _line(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Text(text, style: AppTheme.textStyles.label.copyWith(color: AppTheme.colors.textSecondary, height: 1.4)),
    );
  }

  void _confirmWithdraw(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.colors.backgroundCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Retirar consentimento?', style: AppTheme.textStyles.subTitle),
        content: Text(
          'Suas próximas decisões na caixa de entrada não serão registradas e seus dados saem da exportação '
          'usada nas análises. Você ainda pode jogar o quiz e pode voltar a participar depois.',
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
              controller.withdrawConsent();
            },
            child: Text('Retirar', style: TextStyle(color: AppTheme.colors.error)),
          ),
        ],
      ),
    );
  }
}
