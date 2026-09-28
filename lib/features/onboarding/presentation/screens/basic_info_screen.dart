import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../routing/app_router.dart';
import '../providers/onboarding_provider.dart';

class BasicInfoScreen extends ConsumerStatefulWidget {
  const BasicInfoScreen({super.key});

  @override
  ConsumerState<BasicInfoScreen> createState() => _BasicInfoScreenState();
}

class _BasicInfoScreenState extends ConsumerState<BasicInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();

  String? _selectedGender;

  bool _isLoading = false;
  bool _isProfileLoading = true;

  final List<String> _genders = [
    'Male',
    'Female',
    'Prefer not to say',
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _dateOfBirthController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOAD EXISTING PROFILE
  // ============================================================

  Future<void> _loadExistingProfile() async {
    try {
      final profile = await ref.read(
        studentProfileProvider.future,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        // These values come from the database.
        _fullNameController.text = profile.fullName;

        if (profile.phone != null && profile.phone!.isNotEmpty) {
          _phoneController.text = profile.phone!;
        }

        if (profile.dateOfBirth != null &&
            profile.dateOfBirth!.isNotEmpty) {
          _dateOfBirthController.text =
              _formatDisplayDate(profile.dateOfBirth!);
        }

        if (profile.gender != null &&
            profile.gender!.isNotEmpty) {
          _selectedGender = profile.gender;
        }

        if (profile.city != null && profile.city!.isNotEmpty) {
          _cityController.text = profile.city!;
        }

        if (profile.pincode != null &&
            profile.pincode!.isNotEmpty) {
          _pincodeController.text = profile.pincode!;
        }

        _isProfileLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isProfileLoading = false;
      });

      _showMessage(
        'Unable to load your profile. Please try again.',
      );
    }
  }

  // ============================================================
  // DATE HELPERS
  // ============================================================

  String _formatDisplayDate(String value) {
    final parts = value.split('-');

    if (parts.length == 3) {
      final year = parts[0];
      final month = parts[1];
      final day = parts[2];

      return '$day/$month/$year';
    }

    return value;
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();

    DateTime initialDate = DateTime(
      now.year - 17,
      now.month,
      now.day,
    );

    final firstDate = DateTime(
      now.year - 100,
      now.month,
      now.day,
    );

    final lastDate = DateTime(
      now.year - 10,
      now.month,
      now.day,
    );

    if (initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    }

    if (initialDate.isAfter(lastDate)) {
      initialDate = lastDate;
    }

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Select your date of birth',
    );

    if (selectedDate == null) {
      return;
    }

    final day = selectedDate.day.toString().padLeft(2, '0');
    final month = selectedDate.month.toString().padLeft(2, '0');
    final year = selectedDate.year.toString();

    setState(() {
      _dateOfBirthController.text = '$day/$month/$year';
    });
  }

  String _getApiDateOfBirth() {
    final value = _dateOfBirthController.text.trim();
    final parts = value.split('/');

    if (parts.length != 3) {
      throw const FormatException(
        'Invalid date of birth format.',
      );
    }

    final day = parts[0];
    final month = parts[1];
    final year = parts[2];

    return '$year-$month-$day';
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _continue() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedGender == null) {
      _showMessage('Please select your gender.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final apiDateOfBirth = _getApiDateOfBirth();

      await ref.read(onboardingRepositoryProvider).updateBasicInfo(
            fullName: _fullNameController.text.trim(),
            phone: _phoneController.text.trim(),
            dateOfBirth: apiDateOfBirth,
            gender: _selectedGender!,
            city: _cityController.text.trim(),
            pincode: _pincodeController.text.trim(),
          );

      ref.invalidate(studentProfileProvider);

      if (!mounted) {
        return;
      }

      context.go(AppRoutes.education);
    } catch (error) {
      if (!mounted) {
        return;
      }

      if (error is FormatException) {
        _showMessage(
          'Please select a valid date of birth.',
        );
      } else {
        _showMessage(
          ref
              .read(onboardingRepositoryProvider)
              .extractErrorMessage(error),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  // ============================================================
  // UI
  // ============================================================

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
              // ==========================================================
              // TOP PROGRESS HEADER
              // ==========================================================

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.xxl,
                  0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              context.pop();
                            },
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '1 of 3',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // ==========================================================
              // PROGRESS
              // ==========================================================

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: const LinearProgressIndicator(
                    value: 1 / 3,
                    minHeight: 5,
                    backgroundColor: AppColors.surfaceSecondary,
                    color: AppColors.primary,
                  ),
                ),
              ),

              // ==========================================================
              // CONTENT
              // ==========================================================

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xxl,
                    AppSpacing.xxxl,
                    AppSpacing.xxl,
                    AppSpacing.xxl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ====================================================
                      // TITLE
                      // ====================================================

                      Text(
                        'Tell us about\nyourself',
                        style: theme.textTheme.headlineLarge,
                      ),

                      const SizedBox(
                        height: AppSpacing.md,
                      ),

                      Text(
                        'A few basic details will help us personalize '
                        'your PrepMate experience.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(
                        height: AppSpacing.xxxl,
                      ),

                      // ====================================================
                      // PROFILE LOADING
                      // ====================================================

                      if (_isProfileLoading)
                        const Padding(
                          padding: EdgeInsets.only(
                            bottom: AppSpacing.xl,
                          ),
                          child: LinearProgressIndicator(
                            minHeight: 2,
                          ),
                        ),

                      // ====================================================
                      // FULL NAME
                      // ====================================================

                      Text(
                        'Full name',
                        style: theme.textTheme.titleMedium,
                      ),

                      const SizedBox(
                        height: AppSpacing.sm,
                      ),

                      AppTextField(
                          controller: _fullNameController,
                          hintText: 'Enter your full name',
                          keyboardType: TextInputType.name,
                          readOnly: true,
                          prefixIcon: const Icon(
                            Icons.person_outline_rounded,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Full name is required';
                            }
                        
                            return null;
                          },
                        ),

                      const SizedBox(
                        height: AppSpacing.xl,
                      ),

                      // ====================================================
                      // PHONE
                      // ====================================================

                      Text(
                        'Phone number',
                        style: theme.textTheme.titleMedium,
                      ),

                      const SizedBox(
                        height: AppSpacing.sm,
                      ),

                      AppTextField(
                        controller: _phoneController,
                        hintText: 'Enter your phone number',
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(
                          Icons.phone_outlined,
                        ),
                        suffixIcon: _phoneController.text.isNotEmpty
                            ? IconButton(
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                        setState(() {
                                          _phoneController.clear();
                                        });
                                      },
                                icon: const Icon(
                                  Icons.close_rounded,
                                ),
                              )
                            : null,
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Please enter your phone number';
                          }

                          final phone = value.trim();

                          if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
                            return 'Enter a valid 10-digit phone number';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(
                        height: AppSpacing.xl,
                      ),

                      // ====================================================
                      // DATE OF BIRTH
                      // ====================================================

                      Text(
                        'Date of birth',
                        style: theme.textTheme.titleMedium,
                      ),

                      const SizedBox(
                        height: AppSpacing.sm,
                      ),

                      AppTextField(
                        controller: _dateOfBirthController,
                        hintText: 'DD/MM/YYYY',
                        readOnly: true,
                        prefixIcon: const Icon(
                          Icons.calendar_today_outlined,
                        ),
                        suffixIcon: IconButton(
                          onPressed:
                              _isLoading ? null : _selectDateOfBirth,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                          ),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Please select your date of birth';
                          }

                          return null;
                        },
                        onTap:
                            _isLoading ? null : _selectDateOfBirth,
                      ),

                      const SizedBox(
                        height: AppSpacing.xl,
                      ),

                      // ====================================================
                      // GENDER
                      // ====================================================

                      Text(
                        'Gender',
                        style: theme.textTheme.titleMedium,
                      ),

                      const SizedBox(
                        height: AppSpacing.sm,
                      ),

                      DropdownButtonFormField<String>(
                        initialValue: _selectedGender,
                        decoration: const InputDecoration(
                          hintText: 'Select gender',
                          prefixIcon: Icon(
                            Icons.wc_outlined,
                          ),
                        ),
                        items: _genders
                            .map(
                              (gender) => DropdownMenuItem<String>(
                                value: gender,
                                child: Text(gender),
                              ),
                            )
                            .toList(),
                        onChanged: _isLoading
                            ? null
                            : (value) {
                                setState(() {
                                  _selectedGender = value;
                                });
                              },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select your gender';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(
                        height: AppSpacing.xl,
                      ),

                      // ====================================================
                      // CITY
                      // ====================================================

                      Text(
                        'City',
                        style: theme.textTheme.titleMedium,
                      ),

                      const SizedBox(
                        height: AppSpacing.sm,
                      ),

                      AppTextField(
                        controller: _cityController,
                        hintText: 'Enter your city',
                        prefixIcon: const Icon(
                          Icons.location_city_outlined,
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Please enter your city';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(
                        height: AppSpacing.xl,
                      ),

                      // ====================================================
                      // PINCODE
                      // ====================================================

                      Text(
                        'Pincode',
                        style: theme.textTheme.titleMedium,
                      ),

                      const SizedBox(
                        height: AppSpacing.sm,
                      ),

                      AppTextField(
                        controller: _pincodeController,
                        hintText: 'Enter your pincode',
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(
                          Icons.pin_drop_outlined,
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Please enter your pincode';
                          }

                          if (!RegExp(r'^\d{6}$')
                              .hasMatch(value.trim())) {
                            return 'Enter a valid 6-digit pincode';
                          }

                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // ==========================================================
              // CONTINUE
              // ==========================================================

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl,
                  AppSpacing.md,
                  AppSpacing.xxl,
                  AppSpacing.xxl,
                ),
                child: AppButton(
                  text: _isLoading
                      ? 'Saving...'
                      : 'Continue',
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