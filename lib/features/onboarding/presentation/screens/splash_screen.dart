import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:prep_mate/features/onboarding/data/models/student_profile_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../routing/app_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/onboarding_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _initializeAuth(),
    );
  }

  Future<void> _initializeAuth() async {
    await ref.read(authProvider.notifier).initialize();

    if (!mounted) {
      return;
    }

    final authState = ref.read(authProvider);

    if (authState.status != AuthStatus.authenticated) {
      context.go(AppRoutes.welcome);
      return;
    }

    try {
      final profile = await ref.read(studentProfileProvider.future);

      if (!mounted) {
        return;
      }

      if (!profile.isBasicInfoComplete) {
        context.go(AppRoutes.basicInfo);
        return;
      }

      if (!profile.isEducationComplete) {
        context.go(AppRoutes.education);
        return;
      }

      if (!profile.isExamComplete) {
        context.go(AppRoutes.examSelection);
        return;
      }

      context.go(AppRoutes.dashboard);
    } catch (_) {
      if (!mounted) {
        return;
      }

      context.go(AppRoutes.basicInfo);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            children: [
              const SizedBox(
                height: AppSpacing.xxl,
              ),
              const Center(
                child: AppLogo(
                 
                ),
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(
                    AppRadius.xxl,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.menu_book_rounded,
                    size: 100,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(
                height: AppSpacing.xxxl,
              ),
              Text(
                'Learn. Practice. Grow.',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: AppSpacing.sm,
              ),
              Text(
                'Your smarter way to prepare for '
                'competitive exams.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              const SizedBox(
                height: AppSpacing.xxl,
              ),
              const CircularProgressIndicator(),
              const SizedBox(
                height: AppSpacing.lg,
              ),
              Text(
                'Preparing your workspace...',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(
                height: AppSpacing.xxl,
              ),
            ],
          ),
        ),
      ),
    );
  }
}