class HouraUser {
  final String uid;
  final String name;
  final String email;
  final double hourlyRate;

  const HouraUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.hourlyRate,
  });

  factory HouraUser.fromMap(Map<String, dynamic> data, String uid) {
    return HouraUser(
      uid: uid,
      name: data['name'] as String,
      email: data['email'] as String,
      hourlyRate: (data['hourlyRate'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap(){
    return {
      'name': name,
      'email': email,
      'hourlyRate': hourlyRate,
    };
  }
}
