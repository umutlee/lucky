import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/filter_criteria.dart';
import '../../../core/models/fortune.dart';
import '../../../core/providers/filter_provider.dart';
import '../../../core/utils/logger.dart';

class FortuneFilter extends ConsumerWidget {
  final Logger _logger = Logger('FortuneFilter');

  FortuneFilter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final criteria = ref.watch(filterCriteriaProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, ref),
            const Divider(),
            _buildFortuneTypeFilter(context, ref, criteria),
            _buildScoreRangeFilter(context, ref, criteria),
            _buildLuckyDayFilter(context, ref, criteria),
            _buildDirectionsFilter(context, ref, criteria),
            _buildActivitiesFilter(context, ref, criteria),
            _buildDateRangeFilter(context, ref, criteria),
            _buildSortingOptions(context, ref, criteria),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '篩選條件',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () {
            ref.read(filterCriteriaProvider.notifier).reset();
            _logger.info('重置篩選條件');
          },
          child: const Text('重置'),
        ),
      ],
    );
  }

  Widget _buildFortuneTypeFilter(
    BuildContext context,
    WidgetRef ref,
    FilterCriteria criteria,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('運勢類型'),
        Wrap(
          spacing: 8.0,
          children: FortuneType.values.map((type) {
            return FilterChip(
              label: Text(_getFortuneTypeLabel(type)),
              selected: criteria.fortuneType == type,
              onSelected: (selected) {
                ref.read(filterCriteriaProvider.notifier).updateFortuneType(
                  selected ? type : null,
                );
                _logger.info('選擇運勢類型: $type');
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildScoreRangeFilter(
    BuildContext context,
    WidgetRef ref,
    FilterCriteria criteria,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('分數範圍'),
        RangeSlider(
          values: RangeValues(
            criteria.minScore ?? 0,
            criteria.maxScore ?? 100,
          ),
          min: 0,
          max: 100,
          divisions: 10,
          labels: RangeLabels(
            '${criteria.minScore?.toInt() ?? 0}',
            '${criteria.maxScore?.toInt() ?? 100}',
          ),
          onChanged: (values) {
            ref.read(filterCriteriaProvider.notifier).updateScoreRange(
              values.start,
              values.end,
            );
            _logger.info('更新分數範圍: ${values.start} - ${values.end}');
          },
        ),
      ],
    );
  }

  Widget _buildLuckyDayFilter(
    BuildContext context,
    WidgetRef ref,
    FilterCriteria criteria,
  ) {
    return CheckboxListTile(
      title: const Text('只顯示吉日'),
      value: criteria.isLuckyDay ?? false,
      onChanged: (value) {
        ref.read(filterCriteriaProvider.notifier).updateLuckyDay(value);
        _logger.info('更新吉日篩選: $value');
      },
    );
  }

  Widget _buildDirectionsFilter(
    BuildContext context,
    WidgetRef ref,
    FilterCriteria criteria,
  ) {
    final directions = ['東', '南', '西', '北', '東南', '東北', '西南', '西北'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('吉利方位'),
        Wrap(
          spacing: 8.0,
          children: directions.map((direction) {
            return FilterChip(
              label: Text(direction),
              selected: criteria.luckyDirections?.contains(direction) ?? false,
              onSelected: (selected) {
                final currentDirections =
                    List<String>.from(criteria.luckyDirections ?? []);
                if (selected) {
                  currentDirections.add(direction);
                } else {
                  currentDirections.remove(direction);
                }
                ref
                    .read(filterCriteriaProvider.notifier)
                    .updateLuckyDirections(currentDirections);
                _logger.info('更新方位篩選: $direction - $selected');
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActivitiesFilter(
    BuildContext context,
    WidgetRef ref,
    FilterCriteria criteria,
  ) {
    final activities = [
      '求財',
      '考試',
      '求職',
      '結婚',
      '旅行',
      '搬家',
      '開業',
      '簽約',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('適合活動'),
        Wrap(
          spacing: 8.0,
          children: activities.map((activity) {
            return FilterChip(
              label: Text(activity),
              selected: criteria.activities?.contains(activity) ?? false,
              onSelected: (selected) {
                final currentActivities =
                    List<String>.from(criteria.activities ?? []);
                if (selected) {
                  currentActivities.add(activity);
                } else {
                  currentActivities.remove(activity);
                }
                ref
                    .read(filterCriteriaProvider.notifier)
                    .updateActivities(currentActivities);
                _logger.info('更新活動篩選: $activity - $selected');
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateRangeFilter(
    BuildContext context,
    WidgetRef ref,
    FilterCriteria criteria,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('日期範圍'),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () async {
                  final dateRange = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    initialDateRange: DateTimeRange(
                      start: criteria.startDate ?? DateTime.now(),
                      end: criteria.endDate ??
                          DateTime.now().add(const Duration(days: 30)),
                    ),
                  );

                  if (dateRange != null) {
                    ref.read(filterCriteriaProvider.notifier).updateDateRange(
                          dateRange.start,
                          dateRange.end,
                        );
                    _logger.info(
                        '更新日期範圍: ${dateRange.start} - ${dateRange.end}');
                  }
                },
                child: Text(
                  criteria.startDate != null && criteria.endDate != null
                      ? '${_formatDate(criteria.startDate!)} - ${_formatDate(criteria.endDate!)}'
                      : '選擇日期範圍',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSortingOptions(
    BuildContext context,
    WidgetRef ref,
    FilterCriteria criteria,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('排序方式'),
        Row(
          children: [
            DropdownButton<SortField>(
              value: criteria.sortField,
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(filterCriteriaProvider.notifier)
                      .updateSortField(value);
                  _logger.info('更新排序欄位: $value');
                }
              },
              items: SortField.values.map((field) {
                return DropdownMenuItem(
                  value: field,
                  child: Text(_getSortFieldLabel(field)),
                );
              }).toList(),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: Icon(
                criteria.sortOrder == SortOrder.ascending
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
              ),
              onPressed: () {
                ref.read(filterCriteriaProvider.notifier).updateSortOrder(
                      criteria.sortOrder == SortOrder.ascending
                          ? SortOrder.descending
                          : SortOrder.ascending,
                    );
                _logger.info('切換排序方式: ${criteria.sortOrder}');
              },
            ),
          ],
        ),
      ],
    );
  }

  String _getFortuneTypeLabel(FortuneType type) {
    switch (type) {
      case FortuneType.overall:
        return '總運';
      case FortuneType.study:
        return '學業運';
      case FortuneType.career:
        return '事業運';
      case FortuneType.love:
        return '愛情運';
    }
  }

  String _getSortFieldLabel(SortField field) {
    switch (field) {
      case SortField.date:
        return '日期';
      case SortField.score:
        return '分數';
      case SortField.compatibility:
        return '相容性';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }
} 