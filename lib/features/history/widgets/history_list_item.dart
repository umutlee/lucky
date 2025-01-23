import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/history_record.dart';

class HistoryListItem extends StatelessWidget {
  final HistoryRecord record;
  final dateFormat = DateFormat('yyyy/MM/dd HH:mm');

  HistoryListItem({
    super.key,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(
          record.fortuneType == '今日運勢' 
            ? Icons.stars 
            : Icons.explore,
          color: Theme.of(context).primaryColor,
        ),
        title: Text(
          '${record.fortuneType} - ${record.fortuneResult}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          dateFormat.format(record.timestamp),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: IconButton(
          icon: Icon(
            record.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: record.isFavorite ? Colors.red : null,
          ),
          onPressed: () {
            // TODO: 實現收藏功能
          },
        ),
        onTap: () {
          // TODO: 導航到詳情頁面
        },
      ),
    );
  }
} 