/// API 配置
class ApiConfig {
  // API 版本
  static const String _apiVersion = 'v1';
  
  // API 基礎 URL
  static const String _devBaseUrl = 'https://dev-api.alllucky.tw';
  static const String _prodBaseUrl = 'https://api.alllucky.tw';
  static const String _testBaseUrl = 'https://test-api.alllucky.tw';
  
  // API 端點
  static const String _lunarEndpoint = '/lunar';
  static const String _almanacEndpoint = '/almanac';
  static const String _fortuneEndpoint = '/fortune';
  
  // 運勢 API 端點
  static const String _basicFortuneEndpoint = '$_fortuneEndpoint/basic';
  static const String _studyFortuneEndpoint = '$_fortuneEndpoint/study';
  static const String _careerFortuneEndpoint = '$_fortuneEndpoint/career';
  static const String _loveFortuneEndpoint = '$_fortuneEndpoint/love';

  // API Keys（從環境變量獲取）
  static String get apiKey => const String.fromEnvironment(
    'API_KEY',
    defaultValue: 'development_key',
  );

  // 獲取基礎 URL
  static String get baseUrl {
    const environment = String.fromEnvironment(
      'ENVIRONMENT',
      defaultValue: 'dev',
    );
    switch (environment) {
      case 'prod':
        return '$_prodBaseUrl/$_apiVersion';
      case 'test':
        return '$_testBaseUrl/$_apiVersion';
      default:
        return '$_devBaseUrl/$_apiVersion';
    }
  }

  // API URL 生成方法
  static String getLunarUrl() => '$baseUrl$_lunarEndpoint';
  static String getAlmanacUrl() => '$baseUrl$_almanacEndpoint';
  static String getBasicFortuneUrl() => '$baseUrl$_basicFortuneEndpoint';
  static String getStudyFortuneUrl() => '$baseUrl$_studyFortuneEndpoint';
  static String getCareerFortuneUrl() => '$baseUrl$_careerFortuneEndpoint';
  static String getLoveFortuneUrl() => '$baseUrl$_loveFortuneEndpoint';

  // API 超時設置
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
  static const Duration sendTimeout = Duration(seconds: 10);

  // 重試設置
  static const int maxRetries = 3;
  static const Duration retryInterval = Duration(seconds: 1);
  
  // 請求頭
  static Map<String, String> get headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'X-API-Key': apiKey,
    'X-API-Version': _apiVersion,
  };
  
  // 緩存控制
  static const Duration defaultCacheMaxAge = Duration(minutes: 5);
  static const int maxCacheSize = 100; // 條目數
  
  // 請求限制
  static const int rateLimit = 100; // 每分鐘請求數
  static const Duration rateLimitWindow = Duration(minutes: 1);
} 