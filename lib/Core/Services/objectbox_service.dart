import 'package:flutter/material.dart';
import 'package:library_managment/core/models/user_model.dart';
import 'package:library_managment/objectbox.g.dart';

class ObjectBoxService {
  static Store? _store;
  static Box<UserModel>? _userBox;

  static Future<void> init() async {
    if (_store != null) {
      // لو مفتوح مسبقاً تحقق إذا مش مغلق
      try {
        if (!_store!.isClosed()) return;
      } catch (_) {}
    }
    _store = await openStore();
    _userBox = _store!.box<UserModel>();
    debugPrint('✅ ObjectBox Store opened');
  }

  static bool get isReady => _store != null && _userBox != null;

  static void saveUser(UserModel user) {
    _ensureReady();
    _userBox!.removeAll();
    _userBox!.put(user);
  }

  static UserModel? getUser() {
    if (!isReady) return null;
    final users = _userBox!.getAll();
    return users.isNotEmpty ? users.first : null;
  }

  static void clearUser() {
    if (!isReady) return;
    _userBox!.removeAll();
  }

  static bool get isLoggedIn {
    final user = getUser();
    return user != null && user.isLoggedIn;
  }

  static void _ensureReady() {
    if (!isReady) {
      throw Exception(
        'ObjectBox not ready. Make sure init() is called in main()',
      );
    }
  }
}
