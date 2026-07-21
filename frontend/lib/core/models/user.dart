class AppUser {
  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.avatarColor,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String avatarColor;
  final String createdAt;

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        role: json['role'] as String,
        avatarColor: json['avatarColor'] as String,
        createdAt: json['createdAt'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'avatarColor': avatarColor,
        'createdAt': createdAt,
      };
}
