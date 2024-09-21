class SignInData {
  final String username;
  final String password;

  SignInData({required this.username, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': username,
      'password': password,
    };
  }
}

class UserProfile {
  final int id;
  final String name;
  final String phoneNumber;

  UserProfile({
    required this.id,
    required this.name,
    required this.phoneNumber,
  });



  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']  ?? 0,
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
    );
  }
}
