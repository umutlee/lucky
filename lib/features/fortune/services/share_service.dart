import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/models/fortune.dart';

final shareServiceProvider = Provider<ShareService>((ref) => ShareService());

class ShareService {
  Future<void> shareFortune(Fortune fortune) async {
    final text = _generateShareText(fortune);
    await Share.share(text);
  }

  String _generateShareText(Fortune fortune) {
    final buffer = StringBuffer();
    
    // 添加標題
    buffer.writeln('【${_formatDate(fortune.date)} ${fortune.type}運勢】');
    buffer.writeln();
    
    // 添加分數
    buffer.writeln('運勢指數: ${fortune.score}分');
    buffer.writeln();
    
    // 添加描述
    buffer.writeln(fortune.description);
    buffer.writeln();
    
    // 添加建議
    if (fortune.recommendations.isNotEmpty) {
      buffer.writeln('今日建議:');
      for (var i = 0; i < fortune.recommendations.length; i++) {
        buffer.writeln('${i + 1}. ${fortune.recommendations[i]}');
      }
      buffer.writeln();
    }
    
    // 添加生肖相性
    if (fortune.zodiacAffinity.isNotEmpty) {
      buffer.writeln('生肖相性:');
      final sortedAffinities = fortune.zodiacAffinity.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      for (final entry in sortedAffinities.take(3)) {
        buffer.writeln('${entry.key}: ${entry.value}%');
      }
      buffer.writeln();
    }
    
    // 添加應用信息
    buffer.writeln('—— 來自運勢APP');
    
    return buffer.toString();
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
} 