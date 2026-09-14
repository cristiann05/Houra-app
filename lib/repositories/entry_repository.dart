// lib/repositories/entry_repository.dart
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

  Future<void> updateEntry(
    String entryId, {
    required String concept,
    required double hours,
    required double rate,
    required String tag,
    required DateTime date,
  }) {
    return _entriesRef.doc(entryId).update({
      'concept': concept,
      'hours': hours,
      'rate': rate,
      'tag': tag,
      'date': Timestamp.fromDate(date),
    });
  }

  /// Stream de todos los entries, más recientes primero.
  Stream<List<Entry>> watchEntries() {
    return _entriesRef.orderBy('date', descending: true).snapshots().map(
      (snap) => snap.docs.map((d) => Entry.fromMap(d.data(), d.id)).toList(),
    );
  }

  /// Actualiza el campo `tag` de todas las entradas que usan `oldTag` a `newTag`.
  /// Se usa al renombrar una categoría, para que el historial quede consistente.
  Future<void> renameTagInEntries(String oldTag, String newTag) async {
    final snap = await _entriesRef.where('tag', isEqualTo: oldTag).get();
    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'tag': newTag});
    }
    await batch.commit();
  }
}