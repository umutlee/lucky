/// API 配置
class ApiConfig {
  static const String _devBaseUrl = 'https://dev-api.example.com';
  static const String _prodBaseUrl = 'https://api.example.com';
  
  // API 端點
  static const String _lunarEndpoint = '/lunar';
  static const String _fortuneEndpoint = '/fortune';
  static const String _studyFortuneEndpoint = '/study-fortune';
  static const String _careerFortuneEndpoint = '/career-fortune';
  static const String _loveFortuneEndpoint = '/love-fortune';

  // API Keys
  static const String lunarApiKey = 'your_lunar_api_key';
  static const String fortuneApiKey = 'your_fortune_api_key';
  static const String studyFortuneApiKey = 'your_study_fortune_api_key';
  static const String careerFortuneApiKey = 'your_career_fortune_api_key';
  static const String loveFortuneApiKey = 'your_love_fortune_api_key';

  // 獲取基礎 URL
  static String get baseUrl {
    const environment = String.fromEnvironment(
      'ENVIRONMENT',
      defaultValue: 'dev',
    );
    return environment == 'prod' ? _prodBaseUrl : _devBaseUrl;
  }

  // 獲取完整 API URL
  static String getLunarUrl() => '$baseUrl$_lunarEndpoint';
  static String getFortuneUrl() => '$baseUrl$_fortuneEndpoint';
  static String getStudyFortuneUrl() => '$baseUrl$_studyFortuneEndpoint';
  static String getCareerFortuneUrl() => '$baseUrl$_careerFortuneEndpoint';
  static String getLoveFortuneUrl() => '$baseUrl$_loveFortuneEndpoint';

  // API 超時設置
  static const Duration connectTimeout = Duration(seconds: 5);
  static const Duration receiveTimeout = Duration(seconds: 3);
  static const Duration sendTimeout = Duration(seconds: 3);

  // 重試設置
  static const int maxRetries = 3;
  static const Duration retryInterval = Duration(seconds: 1);
} 