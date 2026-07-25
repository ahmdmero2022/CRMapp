import 'package:shelf/shelf.dart';

/// Parsed `page`/`pageSize` query params, clamped to sane bounds.
class Pagination {
  const Pagination(this.limit, this.offset);
  final int limit;
  final int offset;
}

Pagination parsePagination(Request request,
    {int defaultLimit = 25, int maxLimit = 100}) {
  final rawPage = int.tryParse(request.url.queryParameters['page'] ?? '') ?? 1;
  final rawSize =
      int.tryParse(request.url.queryParameters['pageSize'] ?? '') ??
          defaultLimit;
  final page = rawPage < 1 ? 1 : rawPage;
  final limit = rawSize < 1
      ? defaultLimit
      : (rawSize > maxLimit ? maxLimit : rawSize);
  return Pagination(limit, (page - 1) * limit);
}

/// Builds a safe `ORDER BY` clause from the request's `sortBy`/`sortOrder`
/// query params. `sortBy` is mapped through [allowedColumns] (client-facing
/// key -> real SQL column expression) so arbitrary client input can never
/// reach raw SQL; falls back to [defaultOrderBy] (a full `ORDER BY` clause
/// body, e.g. `'name COLLATE NOCASE ASC'`) when `sortBy` is absent/unknown.
String buildOrderBy(
  Request request,
  Map<String, String> allowedColumns,
  String defaultOrderBy,
) {
  final sortBy = request.url.queryParameters['sortBy'];
  final column = sortBy == null ? null : allowedColumns[sortBy];
  if (column == null) return defaultOrderBy;
  final order =
      request.url.queryParameters['sortOrder']?.toUpperCase() == 'DESC'
          ? 'DESC'
          : 'ASC';
  return '$column $order';
}
