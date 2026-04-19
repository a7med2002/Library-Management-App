import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/receiving_account_model.dart';
import 'auth_service.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  // ─── Helper ───────────────────────────────────────────────
  static String get _uid {
  final uid = AuthService.currentUser?.uid ?? 
               FirebaseAuth.instance.currentUser?.uid;
  if (uid == null || uid.isEmpty) {
    throw Exception('المستخدم غير مسجل الدخول');
  }
  return uid;
}

  static CollectionReference _userCol(String col) =>
      _db.collection('users').doc(_uid).collection(col);

  // ═══════════════════════════════════════════════════════════
  // ACCOUNTS
  // ═══════════════════════════════════════════════════════════

  static Stream<List<ReceivingAccountModel>> accountsStream() {
    return _userCol('accounts')
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
    await _userCol('accounts').add(account.toMap());
  }

  static Future<void> updateAccount(ReceivingAccountModel account) async {
    await _userCol('accounts').doc(account.id).update(account.toMap());
  }

  static Future<void> deleteAccount(String accountId) async {
    await _userCol('accounts').doc(accountId).delete();
  }

  // ═══════════════════════════════════════════════════════════
  // PAYMENTS
  // ═══════════════════════════════════════════════════════════

  static Stream<List<Map<String, dynamic>>> paymentsStream(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    return _userCol('payments')
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
    await _userCol('payments').add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': _uid,
    });
  }

  static Future<void> deletePayment(String paymentId) async {
    await _userCol('payments').doc(paymentId).delete();
  }

  // ═══════════════════════════════════════════════════════════
  // TRANSFERS
  // ═══════════════════════════════════════════════════════════

  static Stream<List<Map<String, dynamic>>> transfersStream() {
    return _userCol('transfers')
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
    await _userCol('transfers').add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': _uid,
    });
  }

  static Future<void> updateTransferStatus(
    String transferId,
    String status,
  ) async {
    await _userCol('transfers').doc(transferId).update({'status': status});
  }

  static Future<void> deleteTransfer(String transferId) async {
    await _userCol('transfers').doc(transferId).delete();
  }

  // ═══════════════════════════════════════════════════════════
  // REPORT
  // ═══════════════════════════════════════════════════════════

  static Future<List<Map<String, dynamic>>> getPaymentsByDate(
    DateTime date,
  ) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final snap = await _userCol('payments')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThan: Timestamp.fromDate(end))
        .get();

    return snap.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  static Future<List<Map<String, dynamic>>> getTransfersByDate(
    DateTime date,
  ) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final snap = await _userCol('transfers')
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
    final doc = await _db.collection('users').doc(_uid).get();
    return doc.data();
  }

  static Future<void> updateSettings(Map<String, dynamic> data) async {
    await _db.collection('users').doc(_uid).set(data, SetOptions(merge: true));
  }
}
