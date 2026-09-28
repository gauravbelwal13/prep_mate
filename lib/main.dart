import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'routing/app_router.dart';

void main() {
  runApp(
    const ProviderScope(
      child: PrepMateApp(),
    ),
  );
}

class PrepMateApp extends ConsumerWidget {
  const PrepMateApp({super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'PrepMate',
      theme: AppTheme.light(),
      routerConfig: appRouter,
    );
  }
}