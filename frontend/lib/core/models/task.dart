class CrmTask {
  CrmTask({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    required this.priority,
    required this.status,
    this.relatedType,
    this.relatedId,
    this.relatedLabel,
    this.ownerId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String? description;
  final String? dueDate;
  final String priority;
  final String status;
  final String? relatedType;
  final String? relatedId;
  final String? relatedLabel;
  final String? ownerId;
  final String createdAt;
  final String updatedAt;

  bool get isCompleted => status == 'completed';
  bool get isOverdue {
    if (isCompleted || dueDate == null) return false;
    final due = DateTime.tryParse(dueDate!);
    if (due == null) return false;
    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);
    return due.isBefore(todayDateOnly);
  }

  factory CrmTask.fromJson(Map<String, dynamic> json) => CrmTask(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        dueDate: json['dueDate'] as String?,
        priority: json['priority'] as String,
        status: json['status'] as String,
        relatedType: json['relatedType'] as String?,
        relatedId: json['relatedId'] as String?,
        relatedLabel: json['relatedLabel'] as String?,
        ownerId: json['ownerId'] as String?,
        createdAt: json['createdAt'] as String,
        updatedAt: json['updatedAt'] as String,
      );
}
