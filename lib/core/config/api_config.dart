/// API 配置
class ApiConfig {
  // API 版本
  static const _apiVersion = 'v1';

  // 環境配置
  static const _devBaseUrl = 'https://dev-api.alllucky.tw';
  static const _prodBaseUrl = 'https://api.alllucky.tw';
  static const _testBaseUrl = 'https://test-api.alllucky.tw';

  // 運勢相關端點
  static const _fortuneEndpoint = '/fortune';
  static const dailyFortuneEndpoint = '$_fortuneEndpoint/daily';
  static const studyFortuneEndpoint = '$_fortuneEndpoint/study';
  static const careerFortuneEndpoint = '$_fortuneEndpoint/career';
  static const loveFortuneEndpoint = '$_fortuneEndpoint/love';

  // 黃曆相關端點
  static const _almanacEndpoint = '/almanac';
  static const dailyAlmanacEndpoint = '$_almanacEndpoint/daily';
  static const monthAlmanacEndpoint = '$_almanacEndpoint/month';
  static const lunarDateEndpoint = '$_almanacEndpoint/lunar';

  // 超時設置
  static const connectTimeout = 30000;
  static const receiveTimeout = 30000;
  static const sendTimeout = 30000;

  // 重試設置
  static const maxRetries = 3;
  static const retryDelay = Duration(seconds: 1);
  static const cacheMaxAge = Duration(hours: 1);
  static const maxCacheSize = 10 * 1024 * 1024; // 10MB

  // 認證相關
  static const authTokenKey = 'auth_token';
  static const refreshTokenKey = 'refresh_token';
  static const deviceIdKey = 'device_id';

  // 公開端點
  static const publicEndpoints = [
    '/auth/login',
    '/auth/register',
    '/auth/forgot-password',
  ];

  /// 獲取基礎 URL
  static String get baseUrl {
    const env = String.fromEnvironment('FLUTTER_ENV', defaultValue: 'dev');
    switch (env) {
      case 'prod':
        return '$_prodBaseUrl/$_apiVersion';
      case 'test':
        return '$_testBaseUrl/$_apiVersion';
      default:
        return '$_devBaseUrl/$_apiVersion';
    }
  }

  /// 獲取請求頭
  static Map<String, String> get headers {
    const apiKey = String.fromEnvironment('API_KEY');
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (apiKey.isNotEmpty) 'X-API-Key': apiKey,
      'X-API-Version': _apiVersion,
      'X-Platform': 'mobile',
      'X-Client-Version': const String.fromEnvironment('VERSION', defaultValue: '0.1.0'),
    };
  }

  /// 獲取緩存控制
  static Map<String, String> get cacheControl {
    return {
      'Cache-Control': 'no-cache',
      'Pragma': 'no-cache',
      'Expires': '0',
    };
  }

  /// 獲取請求限制
  static Map<String, String> get rateLimits {
    return {
      'X-RateLimit-Limit': '100',
      'X-RateLimit-Window': '60',
    };
  }

  /// 檢查是否為生產環境
  static bool get isProduction {
    const env = String.fromEnvironment('FLUTTER_ENV', defaultValue: 'dev');
    return env == 'prod';
  }

  /// 檢查是否為測試環境
  static bool get isTest {
    const env = String.fromEnvironment('FLUTTER_ENV', defaultValue: 'dev');
    return env == 'test';
  }

  /// 檢查是否為開發環境
  static bool get isDevelopment {
    const env = String.fromEnvironment('FLUTTER_ENV', defaultValue: 'dev');
    return env == 'dev';
  }

  static bool isPublicEndpoint(String path) {
    return publicEndpoints.any((endpoint) => path.startsWith(endpoint));
  }

  static Map<String, String> getAuthHeaders(String token) {
    return {
      ...headers,
      'Authorization': 'Bearer $token',
    };
  }
} 