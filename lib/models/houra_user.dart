class HouraUser {
  final String uid;
  final String name;
  final String email;
  final double hourlyRate;
  final List<String> customTags;

  const HouraUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.hourlyRate,
    this.customTags = const [],
  });

  factory HouraUser.fromMap(Map<String, dynamic> data, String uid) {
    return HouraUser(
      uid: uid,
      name: data['name'] as String,
      email: data['email'] as String,
      hourlyRate: (data['hourlyRate'] as num).toDouble(),
      customTags: (data['customTags'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'hourlyRate': hourlyRate,
      'customTags': customTags,
    };
  }
}