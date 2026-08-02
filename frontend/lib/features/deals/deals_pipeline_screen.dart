import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models/deal.dart';
import '../../core/models/pipeline_stage.dart';
import '../../core/providers/deals_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/hover_lift.dart';
import '../../widgets/section_header.dart';
import 'deal_detail_dialog.dart';
import 'deal_form_dialog.dart';

final _currency = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

class DealsPipelineScreen extends ConsumerWidget {
  const DealsPipelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stagesAsync = ref.watch(pipelineStagesProvider);
    final dealsAsync = ref.watch(dealsControllerProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: l10n.dealsPipelineTitle,
            subtitle: l10n.dealsPipelineSubtitle,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: stagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => ErrorState(message: err.toString()),
              data: (stages) => dealsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, st) => ErrorState(
                  message: err.toString(),
                  onRetry: () => ref.read(dealsControllerProvider.notifier).refresh(),
                ),
                data: (deals) => _KanbanBoard(stages: stages, deals: deals),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KanbanBoard extends ConsumerWidget {
  const _KanbanBoard({required this.stages, required this.deals});

  final List<PipelineStage> stages;
  final List<Deal> deals;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final stage in stages)
            _StageColumn(
              stage: stage,
              deals: deals.where((d) => d.stageId == stage.id).toList(),
            ),
        ],
      ),
    );
  }
}

class _StageColumn extends ConsumerWidget {
  const _StageColumn({required this.stage, required this.deals});

  final PipelineStage stage;
  final List<Deal> deals;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final color = AppTheme.stageColor(stage.color);
    final totalValue = deals.fold<double>(0, (sum, d) => sum + d.value);

    return DragTarget<Deal>(
      onWillAcceptWithDetails: (details) => details.data.stageId != stage.id,
      onAcceptWithDetails: (details) async {
        try {
          await ref
              .read(dealsControllerProvider.notifier)
              .moveToStage(details.data.id, stage.id);
        } catch (e) {
          if (context.mounted) showErrorSnackBar(context, e.toString());
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return Container(
          width: 300,
          margin: const EdgeInsetsDirectional.only(end: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isHovering
                ? color.withOpacity(0.08)
                : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHovering ? color : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(stage.name,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  Text('${deals.length}',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  IconButton(
                    icon: const Icon(Icons.add, size: 18),
                    tooltip: l10n.addDeal,
                    onPressed: () async {
                      final result =
                          await showDealFormDialog(context, initialStageId: stage.id);
                      if (result == null) return;
                      try {
                        await ref
                            .read(dealsControllerProvider.notifier)
                            .create(result.body);
                      } catch (e) {
                        if (context.mounted) showErrorSnackBar(context, e.toString());
                      }
                    },
                  ),
                ],
              ),
              Text(_currency.format(totalValue),
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12)),
              const SizedBox(height: 8),
              Expanded(
                child: deals.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Text(l10n.noDealsShort,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.outline)),
                        ),
                      )
                    : ListView.separated(
                        itemCount: deals.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) =>
                            _DealCard(deal: deals[index]),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DealCard extends StatelessWidget {
  const _DealCard({required this.deal});
  final Deal deal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final card = Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => showDealDetailDialog(context, deal.id),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(deal.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(_currency.format(deal.value),
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700)),
              if (deal.companyName != null || deal.contactName != null) ...[
                const SizedBox(height: 6),
                Text(
                  [deal.companyName, deal.contactName].whereType<String>().join(' · '),
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: deal.probability / 100,
                  minHeight: 4,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: 4),
              Text(l10n.probabilityPercentSuffix(deal.probability),
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );

    return Draggable<Deal>(
      data: deal,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(width: 276, child: card),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: card),
      child: HoverLift(child: card),
    );
  }
}
