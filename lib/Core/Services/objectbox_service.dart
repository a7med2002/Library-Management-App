//   _userBox = _store.box<UserModel>();
import 'package:library_managment/Core/models/user_model.dart';
import 'package:library_managment/objectbox.g.dart';

class ObjectBoxService {
  static Store? _store;
  static Box<UserModel>? _userBox;
  static bool _isInitialized = false;

  // ─── Init ─────────────────────────────────────────────────
  static Future<void> init() async {
    if (_isInitialized) return;
    _store = await openStore();
    _userBox = Box<UserModel>(_store!);
    _isInitialized = true;
  }

  // ─── Safety Check ─────────────────────────────────────────
  static Future<void> _ensureInitialized() async {
    if (!_isInitialized) await init();
  }

  // ─── User ──────────────────────────────────────────────────
  static Future<void> saveUser(UserModel user) async {
    await _ensureInitialized();
    _userBox!.removeAll();
    _userBox!.put(user);
  }

  static UserModel? getUser() {
    if (!_isInitialized || _userBox == null) return null;
    final users = _userBox!.getAll();
    return users.isNotEmpty ? users.first : null;
  }

  static Future<void> clearUser() async {
    await _ensureInitialized();
    _userBox!.removeAll();
  }

  static bool get isLoggedIn {
    if (!_isInitialized || _userBox == null) return false;
    final user = getUser();
    return user != null && user.isLoggedIn;
  }

  // ─── Close ────────────────────────────────────────────────
  static void close() {
    _store?.close();
    _isInitialized = false;
  }
}
