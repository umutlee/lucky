import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sqlite_preferences_service.dart';

/// 通知設置管理器
class NotificationNotifier extends StateNotifier<bool> {
  final SQLitePreferencesService _prefs;
  final String _key;

  NotificationNotifier(this._prefs, this._key) : super(true) {
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final value = await _prefs.getValue<bool>(_key);
    state = value ?? true;
  }

  Future<void> toggle() async {
    state = !state;
    await _prefs.setValue(_key, state);
  }
} 