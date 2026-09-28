import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:prep_mate/features/onboarding/data/models/student_profile_model.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/social_login_button.dart';
import '../../../../routing/app_router.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please enter your email and password.');
      return;
    }

    final success = await ref.read(authProvider.notifier).login(
          email: email,
          password: password,
        );

    if (!mounted) {
      return;
    }

    if (!success) {
      final message = ref.read(authProvider).message ??
          'Unable to login. Please try again.';

      _showMessage(message);
      return;
    }

    try {
      final profile = await ref.read(
        studentProfileProvider.future,
      );

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

      _showMessage(
        'Unable to load your profile. Please try again.',
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxHeight;
            final width = constraints.maxWidth;

            final bool compact = height < 760;
            final bool small = height < 680;

            final horizontalPadding = width < 380
                ? AppSpacing.lg
                : AppSpacing.xxl;

            

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: small ? 12 : 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =========================================================
                  // BRAND HEADER
                  // =========================================================

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: AppLogo(
                       
                        ),
                      ),
                      if (!small)
                        SizedBox(
                          width: compact ? 88 : 104,
                          height: compact ? 68 : 78,
                          child: Image.asset(
                            'assets/images/login_welcome_back_badge.png',
                            fit: BoxFit.contain,
                            alignment: Alignment.centerRight,
                          ),
                        ),
                    ],
                  ),

                  SizedBox(
                    height: small ? 22 : 30,
                  ),

                  // =========================================================
                  // TITLE
                  // =========================================================

                  Text(
                    'Login to UpForm',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontSize: small
                          ? 28
                          : compact
                              ? 30
                              : 34,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.6,
                      height: 1.1,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(
                    height: AppSpacing.sm,
                  ),

                  Text(
                    'Continue your preparation journey and '
                    'stay one step ahead.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: small ? 14 : 16,
                      height: 1.45,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  SizedBox(
                    height: small ? 18 : 24,
                  ),

                  // =========================================================
                  // EMAIL
                  // =========================================================

                  Text(
                    'Email Address',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  AppTextField(
                    controller: _emailController,
                    hintText: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(
                      Icons.mail_outline_rounded,
                    ),
                  ),

                  SizedBox(
                    height: small ? 12 : 16,
                  ),

                  // =========================================================
                  // PASSWORD
                  // =========================================================

                  Text(
                    'Password',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  AppTextField(
                    controller: _passwordController,
                    hintText: 'Enter your password',
                    obscureText: _obscurePassword,
                    prefixIcon: const Icon(
                      Icons.lock_outline_rounded,
                    ),
                    suffixIcon: IconButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  // =========================================================
                  // REMEMBER / FORGOT
                  // =========================================================

                  Row(
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: Checkbox(
                          value: _rememberMe,
                          onChanged: isLoading
                              ? null
                              : (value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Remember me',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                _showMessage(
                                  'Password recovery will be available soon.',
                                );
                              },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                          ),
                        ),
                        child: Text(
                          'Forgot Password?',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: small ? 8 : 12,
                  ),

                  // =========================================================
                  // LOGIN BUTTON
                  // =========================================================

                  SizedBox(
                    width: double.infinity,
                    height: small ? 54 : 60,
                    child: AppButton(
                      text: isLoading ? 'Signing in...' : 'Login',
                      onPressed: isLoading ? null : _login,
                    ),
                  ),

                  SizedBox(
                    height: small ? 18 : 24,
                  ),

                  // =========================================================
                  // DIVIDER
                  // =========================================================

                  Row(
                    children: [
                      const Expanded(
                        child: Divider(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        child: Text(
                          'or continue with',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: small ? 12 : 16,
                  ),

                  // =========================================================
                  // SOCIAL LOGIN
                  // =========================================================

                  Row(
                    children: [
                      Expanded(
                        child: SocialLoginButton(
                          label: 'Google',
                          icon: const Text(
                            'G',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                            ),
                          ),
                          onPressed: isLoading ? null : () {},
                        ),
                      ),
                      const SizedBox(
                        width: AppSpacing.md,
                      ),
                      Expanded(
                        child: SocialLoginButton(
                          label: 'Apple',
                          icon: const Icon(
                            Icons.apple,
                            size: 20,
                          ),
                          onPressed: isLoading ? null : () {},
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: small ? 18 : 24,
                  ),

                  // =========================================================
                  // SIGN UP
                  // =========================================================

                  Center(
                    child: TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              context.go(AppRoutes.register);
                            },
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: small ? 12 : 13,
                          ),
                          children: const [
                            TextSpan(
                              text: "Don't have an account? ",
                            ),
                            TextSpan(
                              text: 'Sign Up',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // =========================================================
                  // LOGIN ILLUSTRATION
                  // =========================================================

                  SizedBox(
                    height: small
                        ? 130
                        : compact
                            ? 160
                            : 200,
                    width: double.infinity,
                    child: Image.asset(
                      'assets/images/login_student_illustration.png',
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomCenter,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}