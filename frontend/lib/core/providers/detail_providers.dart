import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/company.dart';
import '../models/contact.dart';
import '../models/deal.dart';
import 'repositories.dart';

/// One-off "get by id" detail fetches for records that include nested data
/// (activities, tasks, deals) not covered by the list controllers.
final contactDetailProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
        (ref, id) => ref.read(contactsRepositoryProvider).get(id));

final leadDetailProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
        (ref, id) => ref.read(leadsRepositoryProvider).get(id));

final dealDetailProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>, String>(
        (ref, id) => ref.read(dealsRepositoryProvider).get(id));

class CompanyDetail {
  CompanyDetail({required this.company, required this.contacts, required this.deals});
  final Company company;
  final List<Contact> contacts;
  final List<Deal> deals;
}

final companyDetailProvider =
    FutureProvider.autoDispose.family<CompanyDetail, String>((ref, id) async {
  final companiesRepo = ref.read(companiesRepositoryProvider);
  final contactsRepo = ref.read(contactsRepositoryProvider);
  final dealsRepo = ref.read(dealsRepositoryProvider);
  final results = await Future.wait([
    companiesRepo.get(id),
    contactsRepo.list(companyId: id),
    dealsRepo.list(companyId: id),
  ]);
  return CompanyDetail(
    company: results[0] as Company,
    contacts: results[1] as List<Contact>,
    deals: results[2] as List<Deal>,
  );
});
