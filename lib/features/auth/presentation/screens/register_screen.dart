import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/social_login_button.dart';
import '../../../../routing/app_router.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _createAccount() async {
    FocusScope.of(context).unfocus();

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty) {
      _showMessage('Please enter your full name.');
      return;
    }

    if (email.isEmpty) {
      _showMessage('Please enter your email address.');
      return;
    }

    if (password.length < 8) {
      _showMessage(
        'Password must contain at least 8 characters.',
      );
      return;
    }

    if (!_acceptedTerms) {
      _showMessage(
        'Please accept the Terms of Service and Privacy Policy.',
      );
      return;
    }

    final controller = ref.read(authProvider.notifier);

    final registered = await controller.register(
      email: email,
      password: password,
      fullName: name,
    );

    if (!mounted) {
      return;
    }

    if (!registered) {
      final message = ref.read(authProvider).message ??
          'Unable to create your account.';

      _showMessage(message);
      return;
    }

    // Registration does not return a JWT.
    // Login immediately to establish the session.
    final loggedIn = await controller.login(
      email: email,
      password: password,
    );

    if (!mounted) {
      return;
    }

    if (!loggedIn) {
      final message = ref.read(authProvider).message ??
          'Account created. Please login to continue.';

      _showMessage(message);

      if (context.mounted) {
        context.go(AppRoutes.login);
      }

      return;
    }

    context.go(AppRoutes.basicInfo);
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
                  // BRAND
                  // =========================================================

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: AppLogo(
                         
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: small ? 20 : 28,
                  ),

                  // =========================================================
                  // TITLE
                  // =========================================================

                  Text(
                    'Create Your Account',
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
                    'Start your preparation journey with '
                    'personalized practice and insights.',
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
                  // FULL NAME
                  // =========================================================

                  Text(
                    'Full Name',
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
                    controller: _nameController,
                    hintText: 'Enter your full name',
                    keyboardType: TextInputType.name,
                    prefixIcon: const Icon(
                      Icons.person_outline_rounded,
                    ),
                  ),

                  SizedBox(
                    height: small ? 12 : 16,
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
                  // PHONE
                  // =========================================================

                  Text(
                    'Phone Number',
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
                    controller: _phoneController,
                    hintText: 'Enter your phone number',
                    keyboardType: TextInputType.phone,
                    prefixIcon: const Icon(
                      Icons.phone_outlined,
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
                    hintText: 'Create a password',
                    obscureText: _obscurePassword,
                    prefixIcon: const Icon(
                      Icons.lock_outline_rounded,
                    ),
                    suffixIcon: IconButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              setState(() {
                                _obscurePassword =
                                    !_obscurePassword;
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
                  // TERMS
                  // =========================================================

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: Checkbox(
                          value: _acceptedTerms,
                          onChanged: isLoading
                              ? null
                              : (value) {
                                  setState(() {
                                    _acceptedTerms =
                                        value ?? false;
                                  });
                                },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 10,
                          ),
                          child: RichText(
                            text: TextSpan(
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: small ? 11 : 12,
                                color: AppColors.textSecondary,
                                height: 1.35,
                              ),
                              children: const [
                                TextSpan(
                                  text: 'I agree to the ',
                                ),
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextSpan(
                                  text: ' and ',
                                ),
                                TextSpan(
                                  text: 'Privacy Policy.',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: small ? 8 : 12,
                  ),

                  // =========================================================
                  // CREATE ACCOUNT
                  // =========================================================

                  SizedBox(
                    width: double.infinity,
                    height: small ? 54 : 60,
                    child: AppButton(
                      text: isLoading
                          ? 'Creating Account...'
                          : 'Create Account',
                      onPressed:
                          isLoading ? null : _createAccount,
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
                  // SOCIAL
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
                    height: small ? 14 : 20,
                  ),

                  // =========================================================
                  // LOGIN LINK
                  // =========================================================

                  Center(
                    child: TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              context.go(AppRoutes.login);
                            },
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: small ? 12 : 13,
                          ),
                          children: const [
                            TextSpan(
                              text: 'Already have an account? ',
                            ),
                            TextSpan(
                              text: 'Login',
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
                  // DECORATIVE FOOTER
                  // =========================================================

                  SizedBox(
                    height: small
                        ? 100
                        : compact
                            ? 125
                            : 155,
                    width: double.infinity,
                    child: Image.asset(
                      'assets/images/signup_bottom_decoration.png',
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