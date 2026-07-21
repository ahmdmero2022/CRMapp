class Deal {
  Deal({
    required this.id,
    required this.title,
    required this.value,
    required this.stageId,
    this.contactId,
    this.contactName,
    this.companyId,
    this.companyName,
    this.ownerId,
    this.expectedCloseDate,
    required this.probability,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final double value;
  final String stageId;
  final String? contactId;
  final String? contactName;
  final String? companyId;
  final String? companyName;
  final String? ownerId;
  final String? expectedCloseDate;
  final int probability;
  final String status;
  final String? notes;
  final String createdAt;
  final String updatedAt;

  factory Deal.fromJson(Map<String, dynamic> json) => Deal(
        id: json['id'] as String,
        title: json['title'] as String,
        value: (json['value'] as num?)?.toDouble() ?? 0,
        stageId: json['stageId'] as String,
        contactId: json['contactId'] as String?,
        contactName: json['contactName'] as String?,
        companyId: json['companyId'] as String?,
        companyName: json['companyName'] as String?,
        ownerId: json['ownerId'] as String?,
        expectedCloseDate: json['expectedCloseDate'] as String?,
        probability: (json['probability'] as num?)?.toInt() ?? 50,
        status: json['status'] as String,
        notes: json['notes'] as String?,
        createdAt: json['createdAt'] as String,
        updatedAt: json['updatedAt'] as String,
      );

  Deal copyWith({String? stageId, String? status}) => Deal(
        id: id,
        title: title,
        value: value,
        stageId: stageId ?? this.stageId,
        contactId: contactId,
        contactName: contactName,
        companyId: companyId,
        companyName: companyName,
        ownerId: ownerId,
        expectedCloseDate: expectedCloseDate,
        probability: probability,
        status: status ?? this.status,
        notes: notes,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
