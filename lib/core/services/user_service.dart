import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_identity.dart';
import '../storage/user_storage.dart';

final userServiceProvider = Provider<UserService>((ref) {
  final userStorage = ref.read(userStorageProvider);
  return UserService(userStorage);
});

class UserService {
  final UserStorage _userStorage;

  UserService(this._userStorage);

  Future<UserIdentity> getCurrentUser() async {
    try {
      return await _userStorage.getUser();
    } catch (e) {
      return UserIdentity.empty();
    }
  }

  Future<UserIdentity> updateBirthDate(DateTime birthDate) async {
    final currentUser = await getCurrentUser();
    final updatedUser = currentUser.copyWith(birthDate: birthDate);
    await _userStorage.saveUser(updatedUser);
    return updatedUser;
  }

  Future<UserIdentity> updateName(String name) async {
    final currentUser = await getCurrentUser();
    final updatedUser = currentUser.copyWith(name: name);
    await _userStorage.saveUser(updatedUser);
    return updatedUser;
  }

  Future<UserIdentity> updateGender(Gender gender) async {
    final currentUser = await getCurrentUser();
    final updatedUser = currentUser.copyWith(gender: gender);
    await _userStorage.saveUser(updatedUser);
    return updatedUser;
  }

  Future<UserIdentity> updateLocation(String location) async {
    final currentUser = await getCurrentUser();
    final updatedUser = currentUser.copyWith(location: location);
    await _userStorage.saveUser(updatedUser);
    return updatedUser;
  }
} 