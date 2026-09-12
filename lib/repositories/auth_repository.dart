// lib/repositories/auth_repository.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:houra_app/models/houra_user.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required double hourlyRate,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = HouraUser(
      uid: credential.user!.uid,
      name: name,
      email: email,
      hourlyRate: hourlyRate,
    );

    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() => _auth.signOut();

    Stream<HouraUser?> watchCurrentUser() {
    final uid = currentUser?.uid;
    if (uid == null) return Stream.value(null);

    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return HouraUser.fromMap(doc.data()!, uid);
    });
  }

  Future<void> updateHourlyRate(double hourlyRate) async {
    final uid = currentUser?.uid;
    if (uid == null) return;
    await _firestore.collection('users').doc(uid).update({'hourlyRate': hourlyRate});
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final uid = user.uid;

    // 1. Borrar todas las entradas (subcolección)
    final entries = await _firestore.collection('users').doc(uid).collection('entries').get();
    for (final doc in entries.docs) {
      await doc.reference.delete();
    }

    // 2. Borrar el documento de perfil
    await _firestore.collection('users').doc(uid).delete();

    // 3. Borrar la cuenta de Auth (puede pedir reautenticación reciente)
    await user.delete();
  }

    Future<void> addCustomTag(String tag) async {
    final uid = currentUser?.uid;
    if (uid == null || tag.trim().isEmpty) return;
    await _firestore.collection('users').doc(uid).update({
      'customTags': FieldValue.arrayUnion([tag.trim()]),
    });
  }

    Future<void> updateGoalHours(double goalHours) async {
    final uid = currentUser?.uid;
    if (uid == null) return;
    await _firestore.collection('users').doc(uid).update({'goalHours': goalHours});
  }
}