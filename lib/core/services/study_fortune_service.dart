import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/study_fortune.dart';
import '../models/user_settings.dart';
import '../models/zodiac.dart';
import '../utils/logger.dart';
import 'package:uuid/uuid.dart';

final studyFortuneServiceProvider = Provider<StudyFortuneService>((ref) {
  return StudyFortuneService();
});

/// 學習運勢服務
class StudyFortuneService {
  final _logger = Logger('StudyFortuneService');
  final _uuid = const Uuid();

  /// 生成學習運勢
  Future<StudyFortune> generateStudyFortune(UserSettings settings) async {
    try {
      // 計算基礎分數
      final baseScore = _calculateBaseScore(settings);
      
      // 計算各項指標
      final efficiencyScore = _calculateEfficiencyScore(baseScore);
      final memoryScore = _calculateMemoryScore(baseScore);
      final examScore = _calculateExamScore(baseScore);
      
      // 生成最佳學習時段
      final bestStudyHours = _generateBestStudyHours();
      
      // 根據用戶設置和分數生成適合學習的科目
      final suitableSubjects = _generateSuitableSubjects(baseScore);
      
      // 生成學習建議
      final studyTips = _generateStudyTips(baseScore, settings);
      
      // 生成運勢描述
      final description = _generateDescription(baseScore, settings);

      return StudyFortune(
        id: _uuid.v4(),
        overallScore: baseScore,
        efficiencyScore: efficiencyScore,
        memoryScore: memoryScore,
        examScore: examScore,
        bestStudyHours: bestStudyHours,
        suitableSubjects: suitableSubjects,
        studyTips: studyTips,
        description: description,
      );
    } catch (e, stack) {
      _logger.error('生成學習運勢失敗', e, stack);
      rethrow;
    }
  }

  /// 計算基礎分數
  int _calculateBaseScore(UserSettings settings) {
    // 基礎隨機分數 (30-70)
    final random = DateTime.now().millisecondsSinceEpoch % 41 + 30;
    
    // 根據生肖調整分數
    var score = random;
    switch (settings.zodiac) {
      case Zodiac.rabbit:
      case Zodiac.snake:
      case Zodiac.monkey:
        score = (score * 1.2).round(); // 這些生肖在學習方面有優勢
        break;
      default:
        break;
    }
    
    return score.clamp(0, 100);
  }

  /// 計算學習效率分數
  int _calculateEfficiencyScore(int baseScore) {
    // 基於基礎分數計算，但加入一些隨機變化
    final variance = DateTime.now().millisecondsSinceEpoch % 21 - 10; // -10 到 10 的變化
    return (baseScore + variance).clamp(0, 100);
  }

  /// 計算記憶力分數
  int _calculateMemoryScore(int baseScore) {
    // 基於基礎分數計算，但加入一些隨機變化
    final variance = DateTime.now().millisecondsSinceEpoch % 21 - 10;
    return (baseScore + variance).clamp(0, 100);
  }

  /// 計算考試運勢分數
  int _calculateExamScore(int baseScore) {
    // 基於基礎分數計算，但加入一些隨機變化
    final variance = DateTime.now().millisecondsSinceEpoch % 21 - 10;
    return (baseScore + variance).clamp(0, 100);
  }

  /// 生成最佳學習時段
  List<String> _generateBestStudyHours() {
    final hours = <String>[];
    
    // 早上時段
    if (DateTime.now().millisecondsSinceEpoch % 2 == 0) {
      hours.add('06:00-08:00');
      hours.add('09:00-11:00');
    }
    
    // 下午時段
    if (DateTime.now().millisecondsSinceEpoch % 3 == 0) {
      hours.add('14:00-16:00');
      hours.add('16:00-18:00');
    }
    
    // 晚上時段
    if (DateTime.now().millisecondsSinceEpoch % 4 == 0) {
      hours.add('19:00-21:00');
      hours.add('21:00-23:00');
    }
    
    return hours.isNotEmpty ? hours : ['09:00-11:00', '14:00-16:00', '19:00-21:00'];
  }

  /// 生成適合學習的科目
  List<String> _generateSuitableSubjects(int baseScore) {
    final allSubjects = [
      '數學', '物理', '化學', '生物',
      '語文', '英語', '歷史', '地理',
      '政治', '音樂', '美術', '體育',
      '計算機', '經濟', '哲學'
    ];
    
    // 根據分數決定返回的科目數量
    final count = baseScore >= 80 ? 5 : (baseScore >= 60 ? 4 : 3);
    
    // 隨機選擇科目
    final selected = <String>[];
    final random = DateTime.now().millisecondsSinceEpoch;
    
    while (selected.length < count && allSubjects.isNotEmpty) {
      final index = random % allSubjects.length;
      selected.add(allSubjects[index]);
      allSubjects.removeAt(index);
    }
    
    return selected;
  }

  /// 生成學習建議
  List<String> _generateStudyTips(int baseScore, UserSettings settings) {
    final tips = <String>[];
    
    // 基於分數的建議
    if (baseScore >= 80) {
      tips.addAll([
        '今天是學習效率的黃金時期，建議多安排重要科目',
        '適合挑戰較難的知識點',
        '可以嘗試參加考試或競賽'
      ]);
    } else if (baseScore >= 60) {
      tips.addAll([
        '保持穩定的學習節奏',
        '適合複習已學內容',
        '注意勞逸結合'
      ]);
    } else {
      tips.addAll([
        '今天可能較難集中注意力，建議調整學習計劃',
        '可以選擇較輕鬆的科目',
        '注意休息，避免過度疲勞'
      ]);
    }
    
    return tips;
  }

  /// 生成運勢描述
  String _generateDescription(int baseScore, UserSettings settings) {
    if (baseScore >= 80) {
      return '今天的學習運勢非常好！你的思維特別清晰，記憶力和理解力都處於巔峰狀態。這是深入學習和突破難點的最佳時機，建議多安排重要科目的學習。';
    } else if (baseScore >= 60) {
      return '今天的學習運勢不錯。雖然可能會遇到一些小困難，但只要保持專注和耐心，依然可以取得不錯的學習效果。建議合理安排時間，注意勞逸結合。';
    } else {
      return '今天的學習運勢稍顯平平。可能會感到注意力不集中或理解較為困難，建議適當調整學習計劃，可以多做一些複習和鞏固的工作。注意調整心態，保持耐心。';
    }
  }
} 