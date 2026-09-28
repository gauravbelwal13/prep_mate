import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/dashboard_model.dart';
import '../../data/repositories/dashboard_repository.dart';


final dashboardRepositoryProvider =
    Provider<DashboardRepository>((ref) {
  return DashboardRepository(
    apiClient: ref.watch(apiClientProvider),
  );
});


final dashboardProvider =
    FutureProvider.autoDispose<DashboardSummary>((ref) {
  return ref
      .watch(dashboardRepositoryProvider)
      .getSummary();
});