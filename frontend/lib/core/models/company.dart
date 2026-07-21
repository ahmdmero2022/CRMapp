class Company {
  Company({
    required this.id,
    required this.name,
    this.industry,
    this.website,
    this.phone,
    this.address,
    this.notes,
    this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.contactCount = 0,
    this.dealCount = 0,
  });

  final String id;
  final String name;
  final String? industry;
  final String? website;
  final String? phone;
  final String? address;
  final String? notes;
  final String? ownerId;
  final String createdAt;
  final String updatedAt;
  final int contactCount;
  final int dealCount;

  factory Company.fromJson(Map<String, dynamic> json) => Company(
        id: json['id'] as String,
        name: json['name'] as String,
        industry: json['industry'] as String?,
        website: json['website'] as String?,
        phone: json['phone'] as String?,
        address: json['address'] as String?,
        notes: json['notes'] as String?,
        ownerId: json['ownerId'] as String?,
        createdAt: json['createdAt'] as String,
        updatedAt: json['updatedAt'] as String,
        contactCount: (json['contactCount'] as num?)?.toInt() ?? 0,
        dealCount: (json['dealCount'] as num?)?.toInt() ?? 0,
      );
}
