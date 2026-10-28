import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:phishing_quest/app/data/enumerators/difficulty.enum.dart';
import 'package:phishing_quest/app/data/models/admin_item.model.dart';
import 'package:phishing_quest/app/global_ui/app_theme.dart';
import 'package:phishing_quest/app/global_ui/components/difficulty_chip.dart';
import 'package:phishing_quest/app/global_ui/components/email_preview_card.dart';
import 'package:phishing_quest/app/global_ui/components/game_card.dart';
import 'package:phishing_quest/app/modules/admin/admin_controller.dart';

/// Curadoria do banco de itens (pesquisador e administrador).
class AdminView extends StatelessWidget {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminController());

    return Scaffold(
      backgroundColor: AppTheme.colors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('Curadoria', style: AppTheme.textStyles.title),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: controller.loadItems,
        color: AppTheme.colors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GenerateCard(controller: controller),
              SizedBox(height: 20.h),
              Text('Banco de itens', style: AppTheme.textStyles.subTitle.copyWith(fontWeight: FontWeight.w600)),
              SizedBox(height: 4.h),
              Text(
                'Itens gerados entram como rascunho e só chegam ao jogo depois de revisados e publicados.',
                style: AppTheme.textStyles.label.copyWith(color: AppTheme.colors.textMuted),
              ),
              SizedBox(height: 12.h),
              Obx(() => Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: ItemStatus.values.map((s) {
                      final selected = controller.status.value == s;
                      return ChoiceChip(
                        label: Text(s.label),
                        selected: selected,
                        onSelected: (_) => controller.selectStatus(s),
                        selectedColor: AppTheme.colors.primary.withOpacity(0.25),
                        backgroundColor: AppTheme.colors.backgroundCard,
                        labelStyle: AppTheme.textStyles.label.copyWith(
                          color: selected ? AppTheme.colors.textPrimary : AppTheme.colors.textSecondary,
                        ),
                        showCheckmark: false,
                      );
                    }).toList(),
                  )),
              SizedBox(height: 12.h),
              Obx(() {
                if (controller.isLoading.value) {
                  return Padding(
                    padding: EdgeInsets.all(24.r),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }
                if (controller.loadError.value != null) {
                  return Text(
                    controller.loadError.value!,
                    style: AppTheme.textStyles.label.copyWith(color: AppTheme.colors.error),
                  );
                }
                if (controller.items.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child: Center(
                      child: Text(
                        'Nenhum item neste estado.',
                        style: AppTheme.textStyles.label.copyWith(color: AppTheme.colors.textMuted),
                      ),
                    ),
                  );
                }
                return Column(
                  children: controller.items
                      .map((item) => _ItemTile(item: item, onTap: () => _openItem(controller, item)))
                      .toList(),
                );
              }),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  void _openItem(AdminController controller, AdminItemModel item) {
    Get.bottomSheet(
      _ItemDetail(controller: controller, item: item),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

class _GenerateCard extends StatelessWidget {
  final AdminController controller;
  const _GenerateCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GameCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: AppTheme.colors.accent, size: 22.sp),
              SizedBox(width: 8.w),
              Text('Gerar rascunho', style: AppTheme.textStyles.subTitle.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'E-mails são gerados pelo PhishForge, com pistas anotadas e atributos da Phish Scale. Os demais canais usam o gerador por template.',
            style: AppTheme.textStyles.label.copyWith(color: AppTheme.colors.textMuted, height: 1.4),
          ),
          SizedBox(height: 14.h),
          Obx(() => DropdownButtonFormField<String>(
                value: controller.channel.value,
                dropdownColor: AppTheme.colors.backgroundCard,
                decoration: _inputDecoration('Canal'),
                style: AppTheme.textStyles.posLabel,
                items: itemChannels.entries
                    .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                    .toList(),
                onChanged: (value) => controller.channel.value = value ?? 'email',
              )),
          SizedBox(height: 12.h),
          Obx(() => SwitchListTile(
                value: controller.isMalicious.value,
                onChanged: (v) => controller.isMalicious.value = v,
                contentPadding: EdgeInsets.zero,
                activeColor: AppTheme.colors.error,
                title: Text(
                  controller.isMalicious.value ? 'Malicioso (phishing)' : 'Legítimo',
                  style: AppTheme.textStyles.posLabel,
                ),
                subtitle: Text(
                  'Itens legítimos são necessários para medir falsos alarmes.',
                  style: AppTheme.textStyles.prepreLabel.copyWith(color: AppTheme.colors.textMuted),
                ),
              )),
          SizedBox(height: 8.h),
          Text('Dificuldade', style: AppTheme.textStyles.label.copyWith(fontWeight: FontWeight.w600)),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: Difficulty.values
                .map((d) => Obx(() => DifficultyChip(
                      difficulty: d,
                      isSelected: controller.selectedDifficulty.value == d,
                      onTap: () => controller.selectDifficulty(d),
                    )))
                .toList(),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: controller.contextController,
            maxLines: 2,
            style: AppTheme.textStyles.posLabel,
            decoration: _inputDecoration('Contexto (opcional)', hint: 'Ex.: atualização cadastral bancária'),
          ),
          SizedBox(height: 14.h),
          Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: controller.isGenerating.value ? null : controller.generate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.colors.primary,
                    disabledBackgroundColor: AppTheme.colors.surfaceBorder,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  ),
                  icon: controller.isGenerating.value
                      ? SizedBox(
                          height: 18.h,
                          width: 18.h,
                          child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome, color: Colors.white),
                  label: Text(
                    controller.isGenerating.value ? 'Gerando (pode levar minutos)...' : 'Gerar rascunho',
                    style: AppTheme.textStyles.posLabel.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: AppTheme.textStyles.label.copyWith(color: AppTheme.colors.textSecondary),
      hintStyle: AppTheme.textStyles.label.copyWith(color: AppTheme.colors.textMuted),
      filled: true,
      fillColor: AppTheme.colors.backgroundDark,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final AdminItemModel item;
  final VoidCallback onTap;

  const _ItemTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = item.isMalicious ? AppTheme.colors.error : AppTheme.colors.success;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: AppTheme.colors.backgroundCard,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6.r)),
              child: Text(
                item.isMalicious ? 'PHISHING' : 'LEGÍTIMO',
                style: AppTheme.textStyles.prepreLabel.copyWith(color: color, fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTheme.textStyles.posLabel.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${itemChannels[item.channel] ?? item.channel} · ${item.source}',
                    style: AppTheme.textStyles.prepreLabel.copyWith(color: AppTheme.colors.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppTheme.colors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _ItemDetail extends StatelessWidget {
  final AdminController controller;
  final AdminItemModel item;

  const _ItemDetail({required this.controller, required this.item});

  static const _fieldLabels = {'subject': 'assunto', 'sender': 'remetente', 'body': 'corpo'};

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: AppTheme.colors.backgroundCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(color: AppTheme.colors.surfaceBorder, borderRadius: BorderRadius.circular(2.r)),
              ),
            ),
            SizedBox(height: 14.h),
            Text(item.title, style: AppTheme.textStyles.subTitle.copyWith(fontWeight: FontWeight.w700)),
            SizedBox(height: 6.h),
            Text(
              '${itemChannels[item.channel] ?? item.channel} · ${item.isMalicious ? 'malicioso' : 'legítimo'} · ${item.source}',
              style: AppTheme.textStyles.label.copyWith(color: AppTheme.colors.textMuted),
            ),
            SizedBox(height: 12.h),
            if (item.isEmail)
              EmailPreviewCard(email: item.email)
            else
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(color: AppTheme.colors.backgroundDark, borderRadius: BorderRadius.circular(12.r)),
                child: Text(
                  const JsonEncoder.withIndent('  ').convert(item.content),
                  style: TextStyle(color: AppTheme.colors.textSecondary, fontFamily: 'monospace', fontSize: 11.sp),
                ),
              ),
            SizedBox(height: 14.h),
            _section('Explicação', item.explanation.isEmpty ? '(sem explicação)' : item.explanation),
            _section(
              'Phish Scale (estimativa do gerador)',
              'Pistas: ${item.phishScaleCueCount ?? '-'} · Alinhamento da premissa: '
                  '${item.phishScalePremiseAlignment ?? '-'} · Dificuldade: ${item.difficultyEstimated ?? '-'}',
            ),
            Text('Pistas anotadas', style: AppTheme.textStyles.posLabel.copyWith(fontWeight: FontWeight.w700)),
            SizedBox(height: 6.h),
            FutureBuilder<List<ItemCueModel>>(
              future: controller.cuesOf(item),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const LinearProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Não foi possível carregar as pistas.', style: _muted);
                }
                final cues = snapshot.data ?? const [];
                if (cues.isEmpty) {
                  return Text('Nenhuma pista anotada.', style: _muted);
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: cues.map((cue) {
                    final label = controller.cueLabels[cue.cueId] ?? cue.cueId;
                    final where = cue.field != null ? ' (${_fieldLabels[cue.field] ?? cue.field})' : '';
                    final evidence = cue.evidence != null ? ': "${cue.evidence}"' : '';
                    return Padding(
                      padding: EdgeInsets.only(bottom: 4.h),
                      child: Text('• $label$where$evidence', style: _muted),
                    );
                  }).toList(),
                );
              },
            ),
            SizedBox(height: 16.h),
            Obx(() => _actions(controller.isActing.value)),
          ],
        ),
      ),
    );
  }

  TextStyle get _muted => AppTheme.textStyles.label.copyWith(color: AppTheme.colors.textSecondary, height: 1.4);

  Widget _section(String title, String body) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTheme.textStyles.posLabel.copyWith(fontWeight: FontWeight.w700)),
          SizedBox(height: 4.h),
          Text(body, style: _muted),
        ],
      ),
    );
  }

  Widget _actions(bool busy) {
    final buttons = <Widget>[];
    if (item.status == ItemStatus.draft.apiValue) {
      buttons.add(_button('Marcar como revisado', AppTheme.colors.primary, busy ? null : () => controller.markReviewed(item)));
    }
    if (item.status == ItemStatus.reviewed.apiValue) {
      buttons.add(_button('Publicar no jogo', AppTheme.colors.success, busy ? null : () => controller.publish(item)));
    }
    if (item.status == ItemStatus.draft.apiValue || item.status == ItemStatus.reviewed.apiValue) {
      buttons.add(_button('Rejeitar', AppTheme.colors.error, busy ? null : () => controller.reject(item)));
    }
    if (buttons.isEmpty) {
      return Text(
        item.status == ItemStatus.published.apiValue ? 'Item publicado: já é servido no jogo.' : 'Item rejeitado.',
        style: _muted,
      );
    }
    return Column(children: buttons);
  }

  Widget _button(String label, Color color, VoidCallback? onPressed) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          ),
          child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}
