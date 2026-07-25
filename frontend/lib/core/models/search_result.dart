class SearchResultItem {
  SearchResultItem({required this.id, required this.label, this.subtitle});

  final String id;
  final String label;
  final String? subtitle;

  factory SearchResultItem.fromJson(Map<String, dynamic> json) =>
      SearchResultItem(
        id: json['id'] as String,
        label: json['label'] as String? ?? '',
        subtitle: json['subtitle'] as String?,
      );
}

class SearchResults {
  SearchResults({
    required this.contacts,
    required this.companies,
    required this.leads,
    required this.deals,
    required this.tasks,
  });

  final List<SearchResultItem> contacts;
  final List<SearchResultItem> companies;
  final List<SearchResultItem> leads;
  final List<SearchResultItem> deals;
  final List<SearchResultItem> tasks;

  bool get isEmpty =>
      contacts.isEmpty &&
      companies.isEmpty &&
      leads.isEmpty &&
      deals.isEmpty &&
      tasks.isEmpty;

  factory SearchResults.empty() => SearchResults(
        contacts: [],
        companies: [],
        leads: [],
        deals: [],
        tasks: [],
      );

  factory SearchResults.fromJson(Map<String, dynamic> json) {
    List<SearchResultItem> parse(String key) => ((json[key] as List?) ?? [])
        .map((e) => SearchResultItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return SearchResults(
      contacts: parse('contacts'),
      companies: parse('companies'),
      leads: parse('leads'),
      deals: parse('deals'),
      tasks: parse('tasks'),
    );
  }
}
