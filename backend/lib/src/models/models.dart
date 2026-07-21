import 'package:sqlite3/sqlite3.dart';

class User {
  User({
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

  factory User.fromRow(Row r) => User(
        id: r['id'] as String,
        name: r['name'] as String,
        email: r['email'] as String,
        role: r['role'] as String,
        avatarColor: r['avatar_color'] as String,
        createdAt: r['created_at'] as String,
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

  factory Company.fromRow(Row r) => Company(
        id: r['id'] as String,
        name: r['name'] as String,
        industry: r['industry'] as String?,
        website: r['website'] as String?,
        phone: r['phone'] as String?,
        address: r['address'] as String?,
        notes: r['notes'] as String?,
        ownerId: r['owner_id'] as String?,
        createdAt: r['created_at'] as String,
        updatedAt: r['updated_at'] as String,
      );

  Company copyWithCounts({int? contactCount, int? dealCount}) => Company(
        id: id,
        name: name,
        industry: industry,
        website: website,
        phone: phone,
        address: address,
        notes: notes,
        ownerId: ownerId,
        createdAt: createdAt,
        updatedAt: updatedAt,
        contactCount: contactCount ?? this.contactCount,
        dealCount: dealCount ?? this.dealCount,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'industry': industry,
        'website': website,
        'phone': phone,
        'address': address,
        'notes': notes,
        'ownerId': ownerId,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'contactCount': contactCount,
        'dealCount': dealCount,
      };
}

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

  factory Contact.fromRow(Row r) => Contact(
        id: r['id'] as String,
        firstName: r['first_name'] as String,
        lastName: r['last_name'] as String,
        email: r['email'] as String?,
        phone: r['phone'] as String?,
        jobTitle: r['job_title'] as String?,
        companyId: r['company_id'] as String?,
        companyName: r.keys.contains('company_name')
            ? r['company_name'] as String?
            : null,
        ownerId: r['owner_id'] as String?,
        tags: r['tags'] as String?,
        notes: r['notes'] as String?,
        avatarColor: r['avatar_color'] as String,
        createdAt: r['created_at'] as String,
        updatedAt: r['updated_at'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'jobTitle': jobTitle,
        'companyId': companyId,
        'companyName': companyName,
        'ownerId': ownerId,
        'tags': tags,
        'notes': notes,
        'avatarColor': avatarColor,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}

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

  factory Lead.fromRow(Row r) => Lead(
        id: r['id'] as String,
        name: r['name'] as String,
        email: r['email'] as String?,
        phone: r['phone'] as String?,
        source: r['source'] as String?,
        status: r['status'] as String,
        companyName: r['company_name'] as String?,
        estimatedValue: (r['estimated_value'] as num).toDouble(),
        ownerId: r['owner_id'] as String?,
        notes: r['notes'] as String?,
        createdAt: r['created_at'] as String,
        updatedAt: r['updated_at'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'source': source,
        'status': status,
        'companyName': companyName,
        'estimatedValue': estimatedValue,
        'ownerId': ownerId,
        'notes': notes,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}

class PipelineStage {
  PipelineStage({
    required this.id,
    required this.name,
    required this.orderIndex,
    required this.color,
  });

  final String id;
  final String name;
  final int orderIndex;
  final String color;

  factory PipelineStage.fromRow(Row r) => PipelineStage(
        id: r['id'] as String,
        name: r['name'] as String,
        orderIndex: r['order_index'] as int,
        color: r['color'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'orderIndex': orderIndex,
        'color': color,
      };
}

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

  factory Deal.fromRow(Row r) => Deal(
        id: r['id'] as String,
        title: r['title'] as String,
        value: (r['value'] as num).toDouble(),
        stageId: r['stage_id'] as String,
        contactId: r['contact_id'] as String?,
        contactName: r.keys.contains('contact_name')
            ? r['contact_name'] as String?
            : null,
        companyId: r['company_id'] as String?,
        companyName: r.keys.contains('company_name')
            ? r['company_name'] as String?
            : null,
        ownerId: r['owner_id'] as String?,
        expectedCloseDate: r['expected_close_date'] as String?,
        probability: r['probability'] as int,
        status: r['status'] as String,
        notes: r['notes'] as String?,
        createdAt: r['created_at'] as String,
        updatedAt: r['updated_at'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'value': value,
        'stageId': stageId,
        'contactId': contactId,
        'contactName': contactName,
        'companyId': companyId,
        'companyName': companyName,
        'ownerId': ownerId,
        'expectedCloseDate': expectedCloseDate,
        'probability': probability,
        'status': status,
        'notes': notes,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}

class Task {
  Task({
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

  factory Task.fromRow(Row r) => Task(
        id: r['id'] as String,
        title: r['title'] as String,
        description: r['description'] as String?,
        dueDate: r['due_date'] as String?,
        priority: r['priority'] as String,
        status: r['status'] as String,
        relatedType: r['related_type'] as String?,
        relatedId: r['related_id'] as String?,
        ownerId: r['owner_id'] as String?,
        createdAt: r['created_at'] as String,
        updatedAt: r['updated_at'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'dueDate': dueDate,
        'priority': priority,
        'status': status,
        'relatedType': relatedType,
        'relatedId': relatedId,
        'relatedLabel': relatedLabel,
        'ownerId': ownerId,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}

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

  factory Activity.fromRow(Row r) => Activity(
        id: r['id'] as String,
        type: r['type'] as String,
        content: r['content'] as String,
        relatedType: r['related_type'] as String,
        relatedId: r['related_id'] as String,
        ownerId: r['owner_id'] as String?,
        ownerName: r.keys.contains('owner_name')
            ? r['owner_name'] as String?
            : null,
        createdAt: r['created_at'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'content': content,
        'relatedType': relatedType,
        'relatedId': relatedId,
        'ownerId': ownerId,
        'ownerName': ownerName,
        'createdAt': createdAt,
      };
}
