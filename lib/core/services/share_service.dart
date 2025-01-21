import 'package:share_plus/share_plus.dart';
import '../utils/logger.dart';

class ShareService {
  static final ShareService _instance = ShareService._internal();
  final _logger = Logger('ShareService');
  
  factory ShareService() => _instance;
  
  ShareService._internal();

  Future<void> shareText(String text, {String? subject}) async {
    try {
      await Share.share(
        text,
        subject: subject,
      );
      _logger.info('分享文本成功');
    } catch (e, stack) {
      _logger.error('分享文本失敗', e, stack);
      rethrow;
    }
  }

  Future<void> shareFiles(
    List<String> filePaths, {
    List<String>? mimeTypes,
    String? subject,
    String? text,
  }) async {
    try {
      final files = filePaths.map((path) => XFile(path)).toList();
      
      await Share.shareXFiles(
        files,
        text: text,
        subject: subject,
        mimeTypes: mimeTypes,
      );
      
      _logger.info('分享文件成功：${filePaths.join(", ")}');
    } catch (e, stack) {
      _logger.error('分享文件失敗', e, stack);
      rethrow;
    }
  }
} 