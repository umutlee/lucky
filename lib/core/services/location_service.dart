import 'package:geolocator/geolocator.dart';
import '../utils/logger.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  final _logger = Logger('LocationService');
  
  factory LocationService() => _instance;
  
  LocationService._internal();

  Future<Position> getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requestedPermission = await Geolocator.requestPermission();
        if (requestedPermission == LocationPermission.denied) {
          throw '位置權限被拒絕';
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw '位置權限被永久拒絕，請在系統設置中開啟';
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw '位置服務未開啟';
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );

      _logger.info('獲取當前位置：${position.latitude}, ${position.longitude}');
      return position;
    } catch (e, stack) {
      _logger.error('獲取位置失敗', e, stack);
      rethrow;
    }
  }

  Future<double> getDistanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    try {
      final distance = Geolocator.distanceBetween(
        startLatitude,
        startLongitude,
        endLatitude,
        endLongitude,
      );
      
      _logger.info('計算距離：$distance 米');
      return Future.value(distance);
    } catch (e, stack) {
      _logger.error('計算距離失敗', e, stack);
      rethrow;
    }
  }
} 