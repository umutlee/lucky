/// API 錯誤碼配置
class ApiErrorCodes {
  // 客戶端錯誤 (4xx)
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int methodNotAllowed = 405;
  static const int tooManyRequests = 429;

  // 服務器錯誤 (5xx)
  static const int serverError = 500;
  static const int serviceUnavailable = 503;
  static const int gatewayTimeout = 504;

  // 自定義錯誤碼 (1xxx)
  static const int networkError = 1001;
  static const int parseError = 1002;
  static const int cancelError = 1003;
  static const int timeoutError = 1004;
  static const int cacheError = 1005;
  static const int invalidResponse = 1006;

  // 業務錯誤碼 (2xxx)
  static const int invalidDate = 2001;
  static const int invalidZodiac = 2002;
  static const int invalidIdentity = 2003;
  static const int dataNotAvailable = 2004;
  static const int subscriptionRequired = 2005;

  /// 獲取錯誤信息
  static String getErrorMessage(int code) {
    switch (code) {
      // 客戶端錯誤
      case badRequest:
        return '請求參數錯誤';
      case unauthorized:
        return '請先登入';
      case forbidden:
        return '無權訪問';
      case notFound:
        return '請求的資源不存在';
      case methodNotAllowed:
        return '請求方法不允許';
      case tooManyRequests:
        return '請求過於頻繁，請稍後再試';

      // 服務器錯誤
      case serverError:
        return '服務器錯誤，請稍後重試';
      case serviceUnavailable:
        return '服務暫時不可用，請稍後重試';
      case gatewayTimeout:
        return '服務響應超時，請稍後重試';

      // 自定義錯誤
      case networkError:
        return '網絡連接失敗，請檢查網絡設置';
      case parseError:
        return '數據解析錯誤';
      case cancelError:
        return '請求已取消';
      case timeoutError:
        return '請求超時，請稍後重試';
      case cacheError:
        return '緩存讀取失敗';
      case invalidResponse:
        return '無效的響應數據';

      // 業務錯誤
      case invalidDate:
        return '日期格式無效';
      case invalidZodiac:
        return '星座信息無效';
      case invalidIdentity:
        return '身份信息無效';
      case dataNotAvailable:
        return '暫無相關數據';
      case subscriptionRequired:
        return '需要訂閱會員';

      // 默認錯誤信息
      default:
        return '未知錯誤($code)';
    }
  }

  /// 是否是客戶端錯誤
  static bool isClientError(int code) => code >= 400 && code < 500;

  /// 是否是服務器錯誤
  static bool isServerError(int code) => code >= 500 && code < 600;

  /// 是否是網絡錯誤
  static bool isNetworkError(int code) => code == networkError;

  /// 是否是業務錯誤
  static bool isBusinessError(int code) => code >= 2000 && code < 3000;

  /// 是否需要重試
  static bool shouldRetry(int code) {
    return isServerError(code) || 
           code == networkError || 
           code == timeoutError;
  }

  /// 是否需要清除緩存
  static bool shouldClearCache(int code) {
    return code == cacheError || 
           code == invalidResponse || 
           code == unauthorized;
  }
} 