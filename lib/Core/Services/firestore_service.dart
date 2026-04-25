import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:library_managment/core/Services/store_service.dart';
import '../models/receiving_account_model.dart';
import 'auth_service.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  // ─── Helper ───────────────────────────────────────────────
  static String get _uid {
    final uid =
        AuthService.currentUser?.uid ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw Exception('المستخدم غير مسجل الدخول');
    }
    return uid;
  }

  static CollectionReference _storeCol(String col) => _db
      .collection('stores')
      .doc('dar_miqdad_store')
      .collection(col);

  // ═══════════════════════════════════════════════════════════
  // ACCOUNTS
  // ═══════════════════════════════════════════════════════════
  static Stream<List<ReceivingAccountModel>> accountsStream() {
    return _storeCol('accounts')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (doc) => ReceivingAccountModel.fromMap(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  static Future<void> addAccount(ReceivingAccountModel account) async {
    await _storeCol('accounts').add(account.toMap());
  }

  static Future<void> updateAccount(ReceivingAccountModel account) async {
    await _storeCol('accounts').doc(account.id).update(account.toMap());
  }

  static Future<void> deleteAccount(String id) async {
    await _storeCol('accounts').doc(id).delete();
  }

  // ═══════════════════════════════════════════════════════════
  // PAYMENTS
  // ═══════════════════════════════════════════════════════════
  static Stream<List<Map<String, dynamic>>> paymentsStream(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return _storeCol('payments')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThan: Timestamp.fromDate(end))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>},
              )
              .toList(),
        );
  }

  static Future<void> addPayment(Map<String, dynamic> data) async {
    await _storeCol('payments').add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': AuthService.currentUser?.uid ?? '',
    });
  }

  static Future<void> deletePayment(String id) async {
    await _storeCol('payments').doc(id).delete();
  }

  static Future<List<Map<String, dynamic>>> getPaymentsByDate(
    DateTime date,
  ) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final snap = await _storeCol('payments')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThan: Timestamp.fromDate(end))
        .get();
    return snap.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  // ═══════════════════════════════════════════════════════════
  // TRANSFERS
  // ═══════════════════════════════════════════════════════════
  static Stream<List<Map<String, dynamic>>> transfersStream() {
    return _storeCol('transfers')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>},
              )
              .toList(),
        );
  }

  static Future<void> addTransfer(Map<String, dynamic> data) async {
    await _storeCol('transfers').add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': AuthService.currentUser?.uid ?? '',
    });
  }

  static Future<void> updateTransferStatus(String id, String status) async {
    await _storeCol('transfers').doc(id).update({'status': status});
  }

  static Future<void> deleteTransfer(String id) async {
    await _storeCol('transfers').doc(id).delete();
  }

  static Future<List<Map<String, dynamic>>> getTransfersByDate(
    DateTime date,
  ) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final snap = await _storeCol('transfers')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThan: Timestamp.fromDate(end))
        .get();
    return snap.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  // ═══════════════════════════════════════════════════════════
  // SETTINGS
  // ═══════════════════════════════════════════════════════════
  static Future<Map<String, dynamic>?> getSettings() async {
    final doc = await _db.collection('stores').doc(StoreService.storeId).get();
    return doc.data();
  }

  static Future<void> updateSettings(Map<String, dynamic> data) async {
    await _db.collection('stores').doc(StoreService.storeId).update(data);
  }

  // ═══════════════════════════════════════════════════════════
  // OUTGOING TRANSFERS
  // ═══════════════════════════════════════════════════════════
  static Stream<List<Map<String, dynamic>>> outgoingTransfersStream() {
    return _storeCol('outgoing_transfers')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>},
              )
              .toList(),
        );
  }

  static Future<void> addOutgoingTransfer(Map<String, dynamic> data) async {
    await _storeCol('outgoing_transfers').add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': AuthService.currentUser?.uid ?? '',
    });
  }

  static Future<void> deleteOutgoingTransfer(String id) async {
    await _storeCol('outgoing_transfers').doc(id).delete();
  }

  static Future<List<Map<String, dynamic>>> getOutgoingTransfersByDate(
    DateTime date,
  ) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final snap = await _storeCol('outgoing_transfers')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThan: Timestamp.fromDate(end))
        .get();
    return snap.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  // ═══════════════════════════════════════════════════════════
  // FCM TOKENS
  // ═══════════════════════════════════════════════════════════
  static Future<void> saveToken(String token) async {
    final uid = AuthService.currentUser?.uid ?? '';
    await _db.collection('users').doc(uid).collection('tokens').doc(token).set({
      'token': token,
      'platform': 'android',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ═══════════════════════════════════════════════════════════
  // NOTIFICATIONS — Firestore trigger
  // ═══════════════════════════════════════════════════════════
  static Future<void> createNotification({
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? extra,
  }) async {
    // نحفظ الـ notification في collection مشتركة
    // Cloud Function رح تتفعل وترسل للكل
    await _db.collection('notifications').add({
      'title': title,
      'body': body,
      'type': type,
      'createdBy': _uid,
      'createdAt': FieldValue.serverTimestamp(),
      'storeId': _uid, // لاحقاً لو في multi-store
      ...?extra,
    });
  }
}
