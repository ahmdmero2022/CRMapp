class Contact {
  Contact({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.jobTitle,
    this.companyId,
    this.companyName,
    this.ownerId,
    this.tags,
    this.notes,
    required this.avatarColor,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final String? jobTitle;
  final String? companyId;
  final String? companyName;
  final String? ownerId;
  final String? tags;
  final String? notes;
  final String avatarColor;
  final String createdAt;
  final String updatedAt;

  String get fullName => '$firstName $lastName';
  String get initials =>
      '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'
          .toUpperCase();

  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
        id: json['id'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        jobTitle: json['jobTitle'] as String?,
        companyId: json['companyId'] as String?,
        companyName: json['companyName'] as String?,
        ownerId: json['ownerId'] as String?,
        tags: json['tags'] as String?,
        notes: json['notes'] as String?,
        avatarColor: json['avatarColor'] as String,
        createdAt: json['createdAt'] as String,
        updatedAt: json['updatedAt'] as String,
      );
}
