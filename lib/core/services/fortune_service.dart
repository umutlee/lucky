import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/fortune.dart';
import '../models/user_settings.dart';
import 'zodiac_fortune_service.dart';
import 'user_settings_service.dart';

final fortuneServiceProvider = Provider((ref) {
  final zodiacFortuneService = ref.watch(zodiacFortuneServiceProvider);
  final userSettingsService = ref.watch(userSettingsServiceProvider);
  return FortuneService(zodiacFortuneService, userSettingsService);
});

class FortuneService {
  final ZodiacFortuneService _zodiacFortuneService;
  final UserSettingsService _userSettingsService;
  final _uuid = const Uuid();

  FortuneService(this._zodiacFortuneService, this._userSettingsService);

  // 生成運勢
  Future<Fortune> generateFortune(String type) async {
    // 獲取用戶設置
    final userSettings = await _userSettingsService.loadSettings();
    
    // 基礎運勢分數（根據各種因素計算）
    final baseScore = _calculateBaseScore(type, userSettings);
    
    // 生成基礎運勢對象
    final baseFortune = Fortune(
      id: _uuid.v4(),
      description: _generateDescription(type, baseScore),
      score: baseScore,
      type: type,
      date: DateTime.now(),
      recommendations: _generateBaseRecommendations(type, baseScore),
      zodiac: userSettings.zodiac,
      zodiacAffinity: {},
    );
    
    // 使用生肖運勢服務增強運勢
    return _zodiacFortuneService.enhanceFortuneWithZodiac(
      baseFortune,
      userSettings.zodiac,
    );
  }

  // 計算基礎運勢分數
  int _calculateBaseScore(String type, UserSettings settings) {
    // 基礎隨機分數
    final random = DateTime.now().millisecondsSinceEpoch % 41 + 30; // 30-70的基礎分數
    
    // 根據用戶偏好調整分數
    if (settings.preferredFortuneTypes.contains(type)) {
      return (random * 1.2).round().clamp(0, 100); // 偏好類型有加成
    }
    
    return random;
  }

  // 生成基礎描述
  String _generateDescription(String type, int score) {
    if (score >= 80) {
      return '今天的$type運勢非常好，充滿機遇';
    } else if (score >= 60) {
      return '今天的$type運勢不錯，保持平常心';
    } else if (score >= 40) {
      return '今天的$type運勢普通，需要多加努力';
    } else {
      return '今天的$type運勢欠佳，謹慎行事';
    }
  }

  // 生成基礎建議
  List<String> _generateBaseRecommendations(String type, int score) {
    final recommendations = <String>[];
    
    // 根據運勢類型生成建議
    switch (type) {
      case '學習':
        if (score >= 80) {
          recommendations.add('今天是學習新知識的好時機');
          recommendations.add('可以嘗試挑戰困難的課題');
        } else if (score >= 60) {
          recommendations.add('循序漸進地學習效果會更好');
        } else {
          recommendations.add('建議複習已學過的內容');
          recommendations.add('避免操之過急');
        }
        break;
        
      case '事業':
        if (score >= 80) {
          recommendations.add('適合展開新的工作計劃');
          recommendations.add('與同事合作會有好結果');
        } else if (score >= 60) {
          recommendations.add('按部就班完成工作任務');
        } else {
          recommendations.add('謹慎處理重要決策');
          recommendations.add('多做準備和規劃');
        }
        break;
        
      case '財運':
        if (score >= 80) {
          recommendations.add('可以考慮新的投資機會');
          recommendations.add('財務決策較為順利');
        } else if (score >= 60) {
          recommendations.add('適合理財規劃和預算');
        } else {
          recommendations.add('避免重大財務決策');
          recommendations.add('注意開支控制');
        }
        break;
        
      case '人際':
        if (score >= 80) {
          recommendations.add('適合社交活動和建立新關係');
          recommendations.add('溝通會很順暢');
        } else if (score >= 60) {
          recommendations.add('保持良好的人際互動');
        } else {
          recommendations.add('避免衝突和爭執');
          recommendations.add('多聆聽少說話');
        }
        break;
        
      default:
        if (score >= 80) {
          recommendations.add('今天運勢很好，可以多嘗試新事物');
        } else if (score >= 60) {
          recommendations.add('保持平常心，按計劃行事');
        } else {
          recommendations.add('凡事多加小心，避免衝動');
        }
    }
    
    return recommendations;
  }
} 