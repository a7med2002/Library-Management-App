import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'objectbox_service.dart';

class StoreService {
  StoreService._();

  static final _db = FirebaseFirestore.instance;
  static String? _storeId;

  // ✅ Store ID ثابت للتطبيق كله
  static const String _fixedStoreId = 'dar_miqdad_store';

  static String get storeId => _fixedStoreId;

  static void clearStoreId() => _storeId = null;

  // ═══════════════════════════════════════════════════════════
  static Future<String> initStore({
    required String uid,
    required String email,
  }) async {
    debugPrint('🏪 initStore — uid: $uid, email: $email');

    // ✅ تأكد إن الـ store document موجود
    final storeDoc = await _db.collection('stores').doc(_fixedStoreId).get();

    if (!storeDoc.exists) {
      // أنشئه لأول مرة
      await _db.collection('stores').doc(_fixedStoreId).set({
        'name': 'مكتبة دار المقداد',
        'currency': '₪',
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint('🆕 Store created: $_fixedStoreId');
    }

    // ✅ سجّل اليوزر في users collection
    await _db.collection('users').doc(uid).set({
      'storeId': _fixedStoreId,
      'email': email,
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // ✅ حدّث ObjectBox
    _updateLocalStoreId(uid);

    debugPrint('✅ Store ready: $_fixedStoreId');
    return _fixedStoreId;
  }

  static void _updateLocalStoreId(String uid) {
    final user = ObjectBoxService.getUser();
    if (user != null) {
      user.storeId = _fixedStoreId;
      ObjectBoxService.saveUser(user);
    }
  }

  static Future<bool> isAdmin(String email) async {
    try {
      final doc = await _db.collection('stores').doc(_fixedStoreId).get();

      final admins = List<String>.from(doc.data()?['admins'] ?? []);
      return admins.contains(email);
    } catch (e) {
      return false;
    }
  }

  static Future<void> addAdmin(String email) async {
    await _db.collection('stores').doc(_fixedStoreId).update({
      'admins': FieldValue.arrayUnion([email]),
    });
  }

  static Future<void> removeAdmin(String email) async {
    await _db.collection('stores').doc(_fixedStoreId).update({
      'admins': FieldValue.arrayRemove([email]),
    });
  }
}
