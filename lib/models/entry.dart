import 'package:cloud_firestore/cloud_firestore.dart';

class Entry {
  final String id;
  final String concept;
  final double hours;
  final double rate; // €/h en el momento de crear el entry (independiente del hourlyRate actual del user)
  final String tag;
  final DateTime date;

  const Entry({
    required this.id,
    required this.concept,
    required this.hours,
    required this.rate,
    required this.tag,
    required this.date,
  });

  double get amount => hours * rate;

  factory Entry.fromMap(Map<String, dynamic> data, String id) {
    return Entry(
      id: id,
      concept: data['concept'] as String,
      hours: (data['hours'] as num).toDouble(),
      rate: (data['rate'] as num).toDouble(),
      tag: data['tag'] as String? ?? 'General',
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'concept': concept,
      'hours': hours,
      'rate': rate,
      'tag': tag,
      'date': Timestamp.fromDate(date),
    };
  }
}