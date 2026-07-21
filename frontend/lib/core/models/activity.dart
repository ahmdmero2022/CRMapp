class Activity {
  Activity({
    required this.id,
    required this.type,
    required this.content,
    required this.relatedType,
    required this.relatedId,
    this.ownerId,
    this.ownerName,
    required this.createdAt,
  });

  final String id;
  final String type;
  final String content;
  final String relatedType;
  final String relatedId;
  final String? ownerId;
  final String? ownerName;
  final String createdAt;

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
        id: json['id'] as String,
        type: json['type'] as String,
        content: json['content'] as String,
        relatedType: json['relatedType'] as String,
        relatedId: json['relatedId'] as String,
        ownerId: json['ownerId'] as String?,
        ownerName: json['ownerName'] as String?,
        createdAt: json['createdAt'] as String,
      );
}
