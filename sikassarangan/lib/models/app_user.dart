class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    this.authProvider,
    this.firebaseUid,
    this.fcmToken,
  });

  final int id;
  final String email;
  final String name;
  final String? authProvider;
  final String? firebaseUid;
  final String? fcmToken;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: (json['id'] as num?)?.toInt() ?? 0,
      email: (json['email'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      authProvider: json['auth_provider']?.toString(),
      firebaseUid: json['firebase_uid']?.toString(),
      fcmToken: json['fcm_token']?.toString(),
    );
  }
}
