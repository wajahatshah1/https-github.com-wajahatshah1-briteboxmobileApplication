class UserProfile {
  final String customerId;
  final String name;
  final String phoneNumber;

  UserProfile({
    required this.customerId,
    required this.name,
    required this.phoneNumber,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      customerId: json['customerId'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
    );
  }
}
