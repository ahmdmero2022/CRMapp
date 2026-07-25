import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/contact.dart';
import 'list_notifier.dart';
import 'repositories.dart';

class ContactsController extends ListNotifier<Contact> {
  ContactsController(this._ref);
  final Ref _ref;

  String search = '';
  String? companyId;

  @override
  Future<ListPage<Contact>> fetch() => _ref.read(contactsRepositoryProvider).list(
        search: search,
        companyId: companyId,
        page: page,
        pageSize: pageSize,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

  Future<void> setSearch(String value) async {
    search = value;
    await refresh();
  }

  Future<void> setCompanyFilter(String? id) async {
    companyId = id;
    await refresh();
  }

  Future<void> create(Map<String, dynamic> body) async {
    await _ref.read(contactsRepositoryProvider).create(body);
    await refresh();
  }

  Future<void> update(String id, Map<String, dynamic> body) async {
    await _ref.read(contactsRepositoryProvider).update(id, body);
    await refresh();
  }

  Future<void> delete(String id) async {
    await _ref.read(contactsRepositoryProvider).delete(id);
    await refresh();
  }
}

final contactsControllerProvider =
    StateNotifierProvider.autoDispose<ContactsController, AsyncValue<List<Contact>>>(
        (ref) => ContactsController(ref));
