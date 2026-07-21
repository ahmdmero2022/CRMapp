class Lead {
  Lead({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.source,
    required this.status,
    this.companyName,
    required this.estimatedValue,
    this.ownerId,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? source;
  final String status;
  final String? companyName;
  final double estimatedValue;
  final String? ownerId;
  final String? notes;
  final String createdAt;
  final String updatedAt;

  static const statuses = ['new', 'contacted', 'qualified', 'unqualified', 'converted'];

  factory Lead.fromJson(Map<String, dynamic> json) => Lead(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        source: json['source'] as String?,
        status: json['status'] as String,
        companyName: json['companyName'] as String?,
        estimatedValue: (json['estimatedValue'] as num?)?.toDouble() ?? 0,
        ownerId: json['ownerId'] as String?,
        notes: json['notes'] as String?,
        createdAt: json['createdAt'] as String,
        updatedAt: json['updatedAt'] as String,
      );
}
