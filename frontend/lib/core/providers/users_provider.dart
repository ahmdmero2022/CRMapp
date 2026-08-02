import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import 'repositories.dart';

/// Full team member list — used to populate "assigned to" pickers across
/// features. Small, unpaginated, same shape as [pipelineStagesProvider].
final usersProvider = FutureProvider.autoDispose<List<AppUser>>(
    (ref) => ref.read(usersRepositoryProvider).list());
