import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../routing/app_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxHeight;
            final width = constraints.maxWidth;

            /*
             * The screen is intentionally NOT scrollable.
             *
             * Everything is sized from the available height so the
             * complete Welcome screen remains visible on smaller phones.
             */
            final bool veryCompact = height < 620;
            final bool compact = height < 700;
            final bool medium = height < 800;

            final horizontalPadding = width < 380
                ? AppSpacing.lg
                : width < 430
                    ? AppSpacing.xl
                    : AppSpacing.xxl;

            final topSpacing = veryCompact
                ? 8.0
                : compact
                    ? 12.0
                    : 18.0;

            final logoHeight = veryCompact
                ? 48.0
                : compact
                    ? 58.0
                    : 68.0;


            final badgeWidth = veryCompact
                ? 82.0
                : compact
                    ? 94.0
                    : 108.0;

            final badgeHeight = veryCompact
                ? 48.0
                : compact
                    ? 56.0
                    : 66.0;

            final titleSize = veryCompact
                ? 30.0
                : compact
                    ? 34.0
                    : medium
                        ? 38.0
                        : 42.0;

            final descriptionSize = veryCompact
                ? 14.0
                : compact
                    ? 15.0
                    : 17.0;

            final sectionGap = veryCompact
                ? 8.0
                : compact
                    ? 12.0
                    : 16.0;

            final buttonHeight = veryCompact
                ? 50.0
                : compact
                    ? 54.0
                    : 60.0;

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =========================================================
                  // TOP HEADER
                  // =========================================================

                  SizedBox(height: topSpacing),

                  SizedBox(
                    height: logoHeight,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /*
                         * Complete UpForm logo.
                         *
                         * logo.png already contains:
                         * UpForm
                         * LEARN PRACTICE GROW
                         *
                         * So we deliberately do NOT render those strings
                         * separately here.
                         */
                        Expanded(
                          child: AppLogo(
                          
                          ),
                        ),

                        if (!veryCompact)
                          SizedBox(
                            width: badgeWidth,
                            height: badgeHeight,
                            child: Image.asset(
                              'assets/images/learning_partner_badge.png',
                              fit: BoxFit.contain,
                              alignment: Alignment.centerRight,
                            ),
                          ),
                      ],
                    ),
                  ),

                  SizedBox(height: sectionGap),

                  // =========================================================
                  // HERO TITLE
                  // =========================================================

                  Text(
                    'A Brighter\nFuture Starts\nHere',
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontSize: titleSize,
                      height: 1.02,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.8,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  SizedBox(
                    height: veryCompact ? 6.0 : 10.0,
                  ),

                  // =========================================================
                  // DESCRIPTION
                  // =========================================================

                  Text(
                    'Practice smarter with AI-powered tests, '
                    'real exam questions and personalized insights.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: descriptionSize,
                      height: 1.32,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  SizedBox(height: sectionGap),

                  // =========================================================
                  // HERO IMAGE
                  // =========================================================
                  //
                  // Expanded is important here.
                  //
                  // Instead of assigning a fixed height, the illustration
                  // consumes whatever vertical space is actually available.
                  // This is what keeps the screen non-scrollable.
                  //
                  // =========================================================

                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppRadius.xxl,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Image.asset(
                          'assets/images/hero_illustration_panel.png',
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: sectionGap),

                  // =========================================================
                  // LET'S BEGIN
                  // =========================================================

                  SizedBox(
                    width: double.infinity,
                    height: buttonHeight,
                    child: AppButton(
                      text: "Let's Begin",
                      onPressed: () {
                        context.go(AppRoutes.register);
                      },
                    ),
                  ),

                  // =========================================================
                  // LOGIN
                  // =========================================================

                  SizedBox(
                    height: veryCompact
                        ? 36.0
                        : compact
                            ? 40.0
                            : 46.0,
                    child: Center(
                      child: TextButton(
                        onPressed: () {
                          context.go(AppRoutes.login);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: veryCompact ? 12.0 : 13.0,
                              height: 1.2,
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
                  ),

                  SizedBox(
                    height: veryCompact ? 2.0 : 4.0,
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