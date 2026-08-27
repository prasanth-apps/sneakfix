import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveUserData({
    required String uid,
    required String name,
    required String email,
    required String phone,
    required String district,
    required String role,
  }) async {
    await _db.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'phone': phone,
      'district': district,
      'role': role,
      'created_at': Timestamp.now(),
    });
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    var doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }
}
