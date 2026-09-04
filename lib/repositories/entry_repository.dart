import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:houra_app/models/entry.dart';

class EntryRepository {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _entriesRef {
    final uid = _auth.currentUser!.uid;
    return _firestore.collection('users').doc(uid).collection('entries');
  }

  Future<void> addEntry({
    required String concept,
    required double hours,
    required double rate,
    required String tag,
    required DateTime date,
  }) async {
    final entry = Entry(
      id: '', // Firestore lo genera
      concept: concept,
      hours: hours,
      rate: rate,
      tag: tag,
      date: date,
    );
    await _entriesRef.add(entry.toMap());
  }

  Future<void> deleteEntry(String entryId) => _entriesRef.doc(entryId).delete();

  /// Stream de todos los entries, más recientes primero.
  Stream<List<Entry>> watchEntries() {
    return _entriesRef.orderBy('date', descending: true).snapshots().map(
      (snap) => snap.docs.map((d) => Entry.fromMap(d.data(), d.id)).toList(),
    );
  }
}