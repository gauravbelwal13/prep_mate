import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../routing/app_router.dart';
import '../providers/onboarding_provider.dart';

class EducationScreen extends ConsumerStatefulWidget {
  const EducationScreen({super.key});

  @override
  ConsumerState<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends ConsumerState<EducationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _schoolOrCollegeController = TextEditingController();

  String? _selectedEducationLevel;
  String? _selectedClassOrYear;
  String? _selectedStudyStatus;

  bool _isLoading = false;

  final List<String> _educationLevels = [
    'Class 11',
    'Class 12',
    'Undergraduate',
    'Postgraduate',
    'Other',
  ];

  final List<String> _universityYears = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
    '5th Year',
    'Other',
  ];

  final List<String> _studyStatuses = [
    'Currently studying',
    'Preparing full-time',
    'Preparing alongside college',
    'Working and preparing',
    'Other',
  ];

  bool get _isSchoolLevel {
    return _selectedEducationLevel == 'Class 11' ||
        _selectedEducationLevel == 'Class 12';
  }

  bool get _isHigherEducation {
    return _selectedEducationLevel == 'Undergraduate' ||
        _selectedEducationLevel == 'Postgraduate';
  }

  bool get _showClassOrYear {
    return _isHigherEducation;
  }

  List<String> get _availableClassOrYears {
    if (_isHigherEducation) {
      return _universityYears;
    }

    return _universityYears;
  }

  @override
  void dispose() {
    _schoolOrCollegeController.dispose();
    super.dispose();
  }

  void _handleEducationLevelChanged(String? value) {
    if (value == null) {
      return;
    }

    setState(() {
      _selectedEducationLevel = value;

      if (value == 'Class 11') {
        // The education level itself tells us the current class.
        _selectedClassOrYear = 'Class 11';
      } else if (value == 'Class 12') {
        // The education level itself tells us the current class.
        _selectedClassOrYear = 'Class 12';
      } else {
        // UG/PG use the separate year selector.
        _selectedClassOrYear = null;
      }
    });
  }

  Future<void> _continue() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    String? classOrYear;

    if (_selectedEducationLevel == 'Class 11') {
      classOrYear = 'Class 11';
    } else if (_selectedEducationLevel == 'Class 12') {
      classOrYear = 'Class 12';
    } else {
      classOrYear = _selectedClassOrYear;
    }

    if (classOrYear == null || classOrYear.isEmpty) {
      _showMessage('Please select your class or year.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(onboardingRepositoryProvider).updateEducation(
            schoolOrCollege: _schoolOrCollegeController.text.trim(),
            educationLevel: _selectedEducationLevel!,
            classOrYear: classOrYear,
            studyStatus: _selectedStudyStatus!,
          );

      ref.invalidate(studentProfileProvider);

      if (!mounted) {
        return;
      }

      context.go(AppRoutes.examSelection);
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        ref
            .read(onboardingRepositoryProvider)
            .extractErrorMessage(error),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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

  InputDecoration _dropdownDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(icon),
      suffixIcon: const Icon(
        Icons.keyboard_arrow_down_rounded,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ----------------------------------------------------------
              // HEADER
              // ----------------------------------------------------------
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl,
                  AppSpacing.md,
                  AppSpacing.xxl,
                  AppSpacing.md,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: AppLogo(
                              
                            ),
                          ),
                        ),
                        Text(
                          '2 of 3',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: AppSpacing.md,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: const LinearProgressIndicator(
                        value: 2 / 3,
                        minHeight: 6,
                        backgroundColor: AppColors.surfaceSecondary,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // ----------------------------------------------------------
              // CONTENT
              // ----------------------------------------------------------
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xxl,
                    AppSpacing.lg,
                    AppSpacing.xxl,
                    AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ----------------------------------------------------
                      // TITLE + BADGE
                      // ----------------------------------------------------
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tell us about\nyour education',
                                  style: theme.textTheme.headlineLarge
                                      ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    height: 1.08,
                                  ),
                                ),
                                const SizedBox(
                                  height: AppSpacing.md,
                                ),
                                Text(
                                  'This helps us personalize your '
                                  'preparation and recommend the right '
                                  'content.',
                                  style:
                                      theme.textTheme.bodyLarge?.copyWith(
                                    color: AppColors.textSecondary,
                                    height: 1.45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: AppSpacing.sm,
                          ),
                          SizedBox(
                            width: 135,
                            height: 165,
                            child: Image.asset(
                              'assets/images/education_knowledge_badge.png',
                              fit: BoxFit.contain,
                              errorBuilder: (
                                context,
                                error,
                                stackTrace,
                              ) {
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: AppSpacing.lg,
                      ),

                      // ----------------------------------------------------
                      // SCHOOL / COLLEGE
                      // ----------------------------------------------------
                      Text(
                        'School or college',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(
                        height: AppSpacing.sm,
                      ),
                      AppTextField(
                        controller: _schoolOrCollegeController,
                        hintText: 'Enter school or college name',
                        keyboardType: TextInputType.text,
                        prefixIcon: const Icon(
                          Icons.school_outlined,
                        ),
                        enabled: !_isLoading,
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Please enter your school or college';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(
                        height: AppSpacing.lg,
                      ),

                      // ----------------------------------------------------
                      // EDUCATION LEVEL
                      // ----------------------------------------------------
                      Text(
                        'Education level',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(
                        height: AppSpacing.sm,
                      ),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedEducationLevel,
                        decoration: _dropdownDecoration(
                          hintText: 'Select education level',
                          icon: Icons.school_outlined,
                        ),
                        icon: const SizedBox.shrink(),
                        isExpanded: true,
                        items: _educationLevels.map(
                          (level) {
                            return DropdownMenuItem<String>(
                              value: level,
                              child: Text(level),
                            );
                          },
                        ).toList(),
                        onChanged: _isLoading
                            ? null
                            : _handleEducationLevelChanged,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select your education level';
                          }

                          return null;
                        },
                      ),

                      // ----------------------------------------------------
                      // SCHOOL LEVEL INFORMATION
                      // ----------------------------------------------------
                      if (_isSchoolLevel) ...[
                        const SizedBox(
                          height: AppSpacing.md,
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.md,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(
                              AppRadius.lg,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius:
                                      BorderRadius.circular(999),
                                ),
                                child: const Icon(
                                  Icons.info_outline_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(
                                width: AppSpacing.md,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedEducationLevel ==
                                              'Class 11'
                                          ? 'You selected Class 11.'
                                          : 'You selected Class 12.',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Text(
                                      'Your education level already '
                                      'identifies your current class, '
                                      'so no separate class/year field '
                                      'is needed.',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                        color:
                                            AppColors.textSecondary,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // ----------------------------------------------------
                      // CLASS / YEAR
                      // ----------------------------------------------------
                      if (_showClassOrYear) ...[
                        const SizedBox(
                          height: AppSpacing.lg,
                        ),
                        Text(
                          'Class / year',
                          style:
                              theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(
                          height: AppSpacing.sm,
                        ),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedClassOrYear,
                          decoration: _dropdownDecoration(
                            hintText: 'Select your year',
                            icon: Icons.calendar_month_outlined,
                          ),
                          icon: const SizedBox.shrink(),
                          isExpanded: true,
                          items: _availableClassOrYears.map(
                            (value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            },
                          ).toList(),
                          onChanged: _isLoading
                              ? null
                              : (value) {
                                  setState(() {
                                    _selectedClassOrYear = value;
                                  });
                                },
                          validator: (value) {
                            if (_showClassOrYear &&
                                (value == null || value.isEmpty)) {
                              return 'Please select your year';
                            }

                            return null;
                          },
                        ),
                      ],

                      const SizedBox(
                        height: AppSpacing.lg,
                      ),

                      // ----------------------------------------------------
                      // STUDY STATUS
                      // ----------------------------------------------------
                      Text(
                        'Study status',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(
                        height: AppSpacing.sm,
                      ),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedStudyStatus,
                        decoration: _dropdownDecoration(
                          hintText: 'Select your study status',
                          icon: Icons.auto_stories_outlined,
                        ),
                        icon: const SizedBox.shrink(),
                        isExpanded: true,
                        items: _studyStatuses.map(
                          (status) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Text(status),
                            );
                          },
                        ).toList(),
                        onChanged: _isLoading
                            ? null
                            : (value) {
                                setState(() {
                                  _selectedStudyStatus = value;
                                });
                              },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select your study status';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(
                        height: AppSpacing.lg,
                      ),

                      // ----------------------------------------------------
                      // PERSONALIZATION INFORMATION
                      // ----------------------------------------------------
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(
                            AppRadius.lg,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(
                                  alpha: 0.65,
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.20,
                                  ),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.track_changes_rounded,
                                color: AppColors.primary,
                                size: 30,
                              ),
                            ),
                            const SizedBox(
                              width: AppSpacing.md,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'This information helps us',
                                    style: theme.textTheme.bodyLarge
                                        ?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 3,
                                  ),
                                  Text(
                                    'personalize your study plan, '
                                    'practice tests and content '
                                    'recommendations.',
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(
                                      color: AppColors.textSecondary,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ----------------------------------------------------------
              // CONTINUE BUTTON
              // ----------------------------------------------------------
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl,
                  AppSpacing.sm,
                  AppSpacing.xxl,
                  AppSpacing.xxl,
                ),
                child: AppButton(
                  text: _isLoading ? 'Saving...' : 'Continue',
                  onPressed: _isLoading ? null : _continue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}