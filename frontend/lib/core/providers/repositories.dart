import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../models/activity.dart';
import '../models/company.dart';
import '../models/contact.dart';
import '../models/dashboard_stats.dart';
import '../models/deal.dart';
import '../models/lead.dart';
import '../models/pipeline_stage.dart';
import '../models/search_result.dart';
import '../models/task.dart';
import '../models/user.dart';
import 'auth_provider.dart';
import 'list_notifier.dart';

Map<String, String> _pageQuery({
  required int page,
  required int pageSize,
  String? sortBy,
  String sortOrder = 'asc',
}) =>
    {
      'page': '$page',
      'pageSize': '$pageSize',
      'sortBy': sortBy ?? '',
      'sortOrder': sortOrder,
    };

class CompaniesRepository {
  CompaniesRepository(this._api);
  final ApiClient _api;

  Future<ListPage<Company>> list({
    String? search,
    int page = 1,
    int pageSize = 25,
    String? sortBy,
    String sortOrder = 'asc',
  }) async {
    final res = await _api.get('/companies', query: {
      'search': search ?? '',
      ..._pageQuery(page: page, pageSize: pageSize, sortBy: sortBy, sortOrder: sortOrder),
    });
    final map = res as Map<String, dynamic>;
    final items =
        (map['items'] as List).map((e) => Company.fromJson(e)).toList();
    return ListPage(items, map['total'] as int);
  }

  Future<Company> get(String id) async {
    final res = await _api.get('/companies/$id');
    return Company.fromJson(res as Map<String, dynamic>);
  }

  Future<Company> create(Map<String, dynamic> body) async {
    final res = await _api.post('/companies', body: body);
    return Company.fromJson(res as Map<String, dynamic>);
  }

  Future<Company> update(String id, Map<String, dynamic> body) async {
    final res = await _api.put('/companies/$id', body: body);
    return Company.fromJson(res as Map<String, dynamic>);
  }

  Future<void> delete(String id) => _api.delete('/companies/$id');
}

class ContactsRepository {
  ContactsRepository(this._api);
  final ApiClient _api;

  Future<ListPage<Contact>> list({
    String? search,
    String? companyId,
    int page = 1,
    int pageSize = 25,
    String? sortBy,
    String sortOrder = 'asc',
  }) async {
    final res = await _api.get('/contacts', query: {
      'search': search ?? '',
      'companyId': companyId ?? '',
      ..._pageQuery(page: page, pageSize: pageSize, sortBy: sortBy, sortOrder: sortOrder),
    });
    final map = res as Map<String, dynamic>;
    final items =
        (map['items'] as List).map((e) => Contact.fromJson(e)).toList();
    return ListPage(items, map['total'] as int);
  }

  Future<Map<String, dynamic>> get(String id) async {
    final res = await _api.get('/contacts/$id');
    return res as Map<String, dynamic>;
  }

  Future<Contact> create(Map<String, dynamic> body) async {
    final res = await _api.post('/contacts', body: body);
    return Contact.fromJson(res as Map<String, dynamic>);
  }

  Future<Contact> update(String id, Map<String, dynamic> body) async {
    final res = await _api.put('/contacts/$id', body: body);
    return Contact.fromJson(res as Map<String, dynamic>);
  }

  Future<void> delete(String id) => _api.delete('/contacts/$id');
}

class LeadsRepository {
  LeadsRepository(this._api);
  final ApiClient _api;

  Future<ListPage<Lead>> list({
    String? status,
    String? search,
    int page = 1,
    int pageSize = 25,
    String? sortBy,
    String sortOrder = 'asc',
  }) async {
    final res = await _api.get('/leads', query: {
      'status': status ?? '',
      'search': search ?? '',
      ..._pageQuery(page: page, pageSize: pageSize, sortBy: sortBy, sortOrder: sortOrder),
    });
    final map = res as Map<String, dynamic>;
    final items = (map['items'] as List).map((e) => Lead.fromJson(e)).toList();
    return ListPage(items, map['total'] as int);
  }

  Future<Map<String, dynamic>> get(String id) async {
    final res = await _api.get('/leads/$id');
    return res as Map<String, dynamic>;
  }

  Future<Lead> create(Map<String, dynamic> body) async {
    final res = await _api.post('/leads', body: body);
    return Lead.fromJson(res as Map<String, dynamic>);
  }

  Future<Lead> update(String id, Map<String, dynamic> body) async {
    final res = await _api.put('/leads/$id', body: body);
    return Lead.fromJson(res as Map<String, dynamic>);
  }

  Future<void> delete(String id) => _api.delete('/leads/$id');

  Future<Map<String, dynamic>> convert(String id) async {
    final res = await _api.post('/leads/$id/convert');
    return res as Map<String, dynamic>;
  }
}

class DealsRepository {
  DealsRepository(this._api);
  final ApiClient _api;

  Future<ListPage<Deal>> list({
    String? stageId,
    String? status,
    String? companyId,
    String? contactId,
    String? search,
    int page = 1,
    int pageSize = 200,
    String? sortBy,
    String sortOrder = 'asc',
  }) async {
    final res = await _api.get('/deals', query: {
      'stageId': stageId ?? '',
      'status': status ?? '',
      'companyId': companyId ?? '',
      'contactId': contactId ?? '',
      'search': search ?? '',
      ..._pageQuery(page: page, pageSize: pageSize, sortBy: sortBy, sortOrder: sortOrder),
    });
    final map = res as Map<String, dynamic>;
    final items = (map['items'] as List).map((e) => Deal.fromJson(e)).toList();
    return ListPage(items, map['total'] as int);
  }

  Future<Map<String, dynamic>> get(String id) async {
    final res = await _api.get('/deals/$id');
    return res as Map<String, dynamic>;
  }

  Future<Deal> create(Map<String, dynamic> body) async {
    final res = await _api.post('/deals', body: body);
    return Deal.fromJson(res as Map<String, dynamic>);
  }

  Future<Deal> update(String id, Map<String, dynamic> body) async {
    final res = await _api.put('/deals/$id', body: body);
    return Deal.fromJson(res as Map<String, dynamic>);
  }

  Future<Deal> updateStage(String id, String stageId) async {
    final res = await _api.patch('/deals/$id/stage', body: {'stageId': stageId});
    return Deal.fromJson(res as Map<String, dynamic>);
  }

  Future<void> delete(String id) => _api.delete('/deals/$id');
}

class TasksRepository {
  TasksRepository(this._api);
  final ApiClient _api;

  Future<ListPage<CrmTask>> list({
    String? status,
    String? relatedType,
    String? relatedId,
    String? search,
    int page = 1,
    int pageSize = 25,
    String? sortBy,
    String sortOrder = 'asc',
  }) async {
    final res = await _api.get('/tasks', query: {
      'status': status ?? '',
      'relatedType': relatedType ?? '',
      'relatedId': relatedId ?? '',
      'search': search ?? '',
      ..._pageQuery(page: page, pageSize: pageSize, sortBy: sortBy, sortOrder: sortOrder),
    });
    final map = res as Map<String, dynamic>;
    final items =
        (map['items'] as List).map((e) => CrmTask.fromJson(e)).toList();
    return ListPage(items, map['total'] as int);
  }

  Future<CrmTask> create(Map<String, dynamic> body) async {
    final res = await _api.post('/tasks', body: body);
    return CrmTask.fromJson(res as Map<String, dynamic>);
  }

  Future<CrmTask> update(String id, Map<String, dynamic> body) async {
    final res = await _api.put('/tasks/$id', body: body);
    return CrmTask.fromJson(res as Map<String, dynamic>);
  }

  Future<CrmTask> setComplete(String id, bool done) async {
    final res = await _api.patch('/tasks/$id/complete', body: {'done': done});
    return CrmTask.fromJson(res as Map<String, dynamic>);
  }

  Future<void> delete(String id) => _api.delete('/tasks/$id');
}

class ActivitiesRepository {
  ActivitiesRepository(this._api);
  final ApiClient _api;

  Future<List<Activity>> list({String? relatedType, String? relatedId}) async {
    final res = await _api.get('/activities', query: {
      'relatedType': relatedType ?? '',
      'relatedId': relatedId ?? '',
    });
    return (res as List).map((e) => Activity.fromJson(e)).toList();
  }

  Future<Activity> create(Map<String, dynamic> body) async {
    final res = await _api.post('/activities', body: body);
    return Activity.fromJson(res as Map<String, dynamic>);
  }
}

class PipelineStagesRepository {
  PipelineStagesRepository(this._api);
  final ApiClient _api;

  Future<List<PipelineStage>> list() async {
    final res = await _api.get('/pipeline-stages');
    return (res as List).map((e) => PipelineStage.fromJson(e)).toList();
  }
}

class DashboardRepository {
  DashboardRepository(this._api);
  final ApiClient _api;

  Future<DashboardStats> stats() async {
    final res = await _api.get('/dashboard/stats');
    return DashboardStats.fromJson(res as Map<String, dynamic>);
  }
}

class UsersRepository {
  UsersRepository(this._api);
  final ApiClient _api;

  Future<List<AppUser>> list() async {
    final res = await _api.get('/users');
    return (res as List).map((e) => AppUser.fromJson(e)).toList();
  }
}

class SearchRepository {
  SearchRepository(this._api);
  final ApiClient _api;

  Future<SearchResults> search(String q) async {
    final res = await _api.get('/search', query: {'q': q});
    return SearchResults.fromJson(res as Map<String, dynamic>);
  }
}

class AuthRepository {
  AuthRepository(this._api);
  final ApiClient _api;

  Future<void> changePassword(String currentPassword, String newPassword) {
    return _api.put('/auth/change-password', body: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }
}

final authRepositoryProvider =
    Provider((ref) => AuthRepository(ref.watch(apiClientProvider)));

final companiesRepositoryProvider = Provider(
    (ref) => CompaniesRepository(ref.watch(apiClientProvider)));
final contactsRepositoryProvider = Provider(
    (ref) => ContactsRepository(ref.watch(apiClientProvider)));
final leadsRepositoryProvider =
    Provider((ref) => LeadsRepository(ref.watch(apiClientProvider)));
final dealsRepositoryProvider =
    Provider((ref) => DealsRepository(ref.watch(apiClientProvider)));
final tasksRepositoryProvider =
    Provider((ref) => TasksRepository(ref.watch(apiClientProvider)));
final activitiesRepositoryProvider = Provider(
    (ref) => ActivitiesRepository(ref.watch(apiClientProvider)));
final pipelineStagesRepositoryProvider = Provider(
    (ref) => PipelineStagesRepository(ref.watch(apiClientProvider)));
final dashboardRepositoryProvider = Provider(
    (ref) => DashboardRepository(ref.watch(apiClientProvider)));
final searchRepositoryProvider =
    Provider((ref) => SearchRepository(ref.watch(apiClientProvider)));
final usersRepositoryProvider =
    Provider((ref) => UsersRepository(ref.watch(apiClientProvider)));
