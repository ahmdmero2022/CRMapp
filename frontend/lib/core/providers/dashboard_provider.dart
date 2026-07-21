import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/dashboard_stats.dart';
import 'repositories.dart';

final dashboardStatsProvider = FutureProvider.autoDispose<DashboardStats>(
    (ref) => ref.read(dashboardRepositoryProvider).stats());
