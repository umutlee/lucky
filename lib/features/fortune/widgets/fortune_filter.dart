import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/filter_criteria.dart';
import '../../../core/models/fortune_type.dart';
import '../../../core/providers/filter_provider.dart';
import '../../../core/utils/logger.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'dart:async';

class FortuneFilter extends ConsumerStatefulWidget {
  const FortuneFilter({super.key});

  @override
  ConsumerState<FortuneFilter> createState() => _FortuneFilterState();
}

class _FortuneFilterState extends ConsumerState<FortuneFilter> with SingleTickerProviderStateMixin {
  final Logger _logger = Logger('FortuneFilter');
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  Timer? _debounceTimer;
  final Map<FortuneType, Color> _colorCache = {};
  final Map<FortuneType, String> _labelCache = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    _initializeCache();
    _controller.forward();
  }

  void _initializeCache() {
    for (var type in FortuneType.values) {
      _colorCache[type] = _getFortuneTypeColor(type);
      _labelCache[type] = _getFortuneTypeLabel(type);
    }
  }

  void _updateScoreRangeDebounced(double start, double end) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        ref.read(filterCriteriaProvider.notifier).updateScoreRange(start, end);
        _logger.info('更新分數範圍: $start - $end');
      }
    });
  }

  Color _getFortuneTypeColor(FortuneType type) {
    switch (type) {
      case FortuneType.daily:
        return AppColors.primary;
      case FortuneType.study:
        return AppColors.secondary;
      case FortuneType.career:
        return AppColors.accent;
      case FortuneType.love:
        return AppColors.error;
    }
  }

  String _getFortuneTypeLabel(FortuneType type) {
    switch (type) {
      case FortuneType.daily:
        return '每日運勢';
      case FortuneType.study:
        return '學業運勢';
      case FortuneType.career:
        return '事業運勢';
      case FortuneType.love:
        return '愛情運勢';
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final criteria = ref.watch(filterCriteriaProvider);
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(theme),
                const SizedBox(height: 16),
                _buildFortuneTypeFilter(criteria),
                const SizedBox(height: 16),
                _buildScoreRangeFilter(criteria),
                const SizedBox(height: 16),
                _buildLuckyDayFilter(criteria),
                const SizedBox(height: 16),
                _buildDirectionsFilter(criteria),
                const SizedBox(height: 16),
                _buildActivitiesFilter(criteria),
                const SizedBox(height: 16),
                _buildDateRangeFilter(criteria),
                const SizedBox(height: 16),
                _buildSortingOptions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '篩選條件',
          style: AppTextStyles.titleLarge.copyWith(
            color: theme.primaryColor,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            ref.read(filterCriteriaProvider.notifier).reset();
            _logger.info('重置所有篩選條件');
          },
          tooltip: '重置篩選',
        ),
      ],
    );
  }

  Widget _buildFortuneTypeFilter(FilterCriteria criteria) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('運勢類型', style: AppTextStyles.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: FortuneType.values.map((type) {
            final isSelected = criteria.fortuneType == type;
            return FilterChip(
              label: Text(_labelCache[type]!),
              selected: isSelected,
              onSelected: (selected) {
                ref.read(filterCriteriaProvider.notifier).updateFortuneType(
                  selected ? type : null,
                );
              },
              backgroundColor: _colorCache[type]!.withOpacity(0.1),
              selectedColor: _colorCache[type]!.withOpacity(0.2),
              labelStyle: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? _colorCache[type] : Colors.grey,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildScoreRangeFilter(FilterCriteria criteria) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('分數範圍', style: AppTextStyles.titleMedium),
        RangeSlider(
          values: RangeValues(
            criteria.minScore ?? 0,
            criteria.maxScore ?? 100,
          ),
          min: 0,
          max: 100,
          divisions: 100,
          labels: RangeLabels(
            '${(criteria.minScore ?? 0).toInt()}',
            '${(criteria.maxScore ?? 100).toInt()}',
          ),
          onChanged: (values) {
            _updateScoreRangeDebounced(values.start, values.end);
          },
        ),
      ],
    );
  }

  Widget _buildLuckyDayFilter(FilterCriteria criteria) {
    return SwitchListTile(
      title: Text('僅顯示吉日', style: AppTextStyles.titleMedium),
      value: criteria.isLuckyDay ?? false,
      onChanged: (value) {
        ref.read(filterCriteriaProvider.notifier).updateLuckyDay(value);
      },
    );
  }

  Widget _buildDirectionsFilter(FilterCriteria criteria) {
    final directions = ['東', '南', '西', '北', '東南', '東北', '西南', '西北'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('吉利方位', style: AppTextStyles.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: directions.map((direction) {
            final isSelected = criteria.luckyDirections?.contains(direction) ?? false;
            return FilterChip(
              label: Text(direction),
              selected: isSelected,
              onSelected: (selected) {
                final currentDirections = List<String>.from(criteria.luckyDirections ?? []);
                if (selected) {
                  currentDirections.add(direction);
                } else {
                  currentDirections.remove(direction);
                }
                ref.read(filterCriteriaProvider.notifier).updateLuckyDirections(currentDirections);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActivitiesFilter(FilterCriteria criteria) {
    final activities = ['工作', '學習', '運動', '旅遊', '投資', '交友', '購物', '娛樂'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('適合活動', style: AppTextStyles.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: activities.map((activity) {
            final isSelected = criteria.activities?.contains(activity) ?? false;
            return FilterChip(
              label: Text(activity),
              selected: isSelected,
              onSelected: (selected) {
                final currentActivities = List<String>.from(criteria.activities ?? []);
                if (selected) {
                  currentActivities.add(activity);
                } else {
                  currentActivities.remove(activity);
                }
                ref.read(filterCriteriaProvider.notifier).updateActivities(currentActivities);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateRangeFilter(FilterCriteria criteria) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('日期範圍', style: AppTextStyles.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () async {
                  final dateRange = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2024),
                    lastDate: DateTime(2026),
                    initialDateRange: DateTimeRange(
                      start: criteria.startDate ?? DateTime.now(),
                      end: criteria.endDate ?? DateTime.now().add(const Duration(days: 7)),
                    ),
                  );
                  if (dateRange != null) {
                    ref.read(filterCriteriaProvider.notifier).updateDateRange(
                      dateRange.start,
                      dateRange.end,
                    );
                  }
                },
                child: Text(
                  criteria.startDate == null ? '選擇日期範圍' :
                  '${_formatDate(criteria.startDate!)} - ${_formatDate(criteria.endDate!)}',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSortingOptions() {
    final criteria = ref.watch(filterCriteriaProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('排序選項', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<SortField>(
                value: criteria.sortField,
                decoration: const InputDecoration(
                  labelText: '排序欄位',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: SortField.date,
                    child: Text('日期'),
                  ),
                  DropdownMenuItem(
                    value: SortField.score,
                    child: Text('分數'),
                  ),
                  DropdownMenuItem(
                    value: SortField.type,
                    child: Text('類型'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref.read(filterCriteriaProvider.notifier).updateSortField(value);
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<SortOrder>(
                value: criteria.sortOrder,
                decoration: const InputDecoration(
                  labelText: '排序順序',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: SortOrder.descending,
                    child: Text('降序'),
                  ),
                  DropdownMenuItem(
                    value: SortOrder.ascending,
                    child: Text('升序'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref.read(filterCriteriaProvider.notifier).updateSortOrder(value);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }
} 