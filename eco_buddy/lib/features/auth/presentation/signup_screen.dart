import 'package:eco_buddy/core/constants/app_constants.dart';
import 'package:eco_buddy/core/widgets/custom_button.dart';
import 'package:eco_buddy/core/widgets/custom_text_field.dart';
import 'package:eco_buddy/shared/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _ageController = TextEditingController();

  // Focus nodes for better UX
  final _usernameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();
  final _ageFocus = FocusNode();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _ageController.dispose();
    _usernameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _ageFocus.dispose();
    super.dispose();
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.usernameRequired;
    }
    if (value.length < 3) {
      return AppLocalizations.of(context)!.usernameMinLength;
    }
    if (value.length > 50) {
      return AppLocalizations.of(context)!.usernameMaxLength;
    }
    // autorise uniquement lettres, chiffres et _
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return AppLocalizations.of(context)!.onlyLettersNumbersUnderscore;
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.emailRequired;
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return AppLocalizations.of(context)!.invalidEmailFormat;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.passwordRequired;
    }
    if (value.length < 6) {
      return AppLocalizations.of(context)!.passwordMinLength;
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.confirmationRequired;
    }
    if (value != _passwordController.text) {
      return AppLocalizations.of(context)!.passwordsDoNotMatch;
    }
    return null;
  }

  String? _validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.ageRequired;
    }
    final age = int.tryParse(value);
    if (age == null) {
      return AppLocalizations.of(context)!.invalidAge;
    }
    if (age < 13) {
      return AppLocalizations.of(context)!.minimumAge;
    }
    if (age > 120) {
      return AppLocalizations.of(context)!.invalidAgeRange;
    }
    return null;
  }

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      try {
        await ref
            .read(authProvider.notifier)
            .signup(
              _usernameController.text.trim(),
              _emailController.text.trim(),
              _passwordController.text,
              int.parse(_ageController.text),
            );

        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/dashboard');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.signupFailed(e.toString()),
              ),

              backgroundColor: const Color(AppConstants.errorColor),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Color(AppConstants.primaryColor),

      body: Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(60),
            color: Color(AppConstants.primaryColor),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: 40),
                  // Header
                  ClipOval(
                    child: Image.asset(
                      "assets/images/logo.png",
                      width: 100,
                      height: 100,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${AppLocalizations.of(context)!.join} ${AppConstants.appName}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.createAccountSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 12),

                  // Form Card
                  Card(
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.signupTitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Username field
                          CustomTextField(
                            label: AppLocalizations.of(context)!.username,
                            hintText: AppLocalizations.of(
                              context,
                            )!.enterUsername,
                            prefixIcon: Icons.person_outline,
                            controller: _usernameController,
                            focusNode: _usernameFocus,
                            validator: _validateUsername,
                            textCapitalization: TextCapitalization.none,
                            onChanged: (value) {
                              // Remove validation error on type
                              if (authState.error != null) {
                                ref.read(authProvider.notifier).clearError();
                              }
                            },
                          ),
                          const SizedBox(height: 10),

                          // Email field
                          CustomTextField(
                            label: AppLocalizations.of(context)!.email,
                            hintText: AppLocalizations.of(context)!.enterEmail,
                            prefixIcon: Icons.email_outlined,
                            controller: _emailController,
                            focusNode: _emailFocus,
                            validator: _validateEmail,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 10),

                          // Age field
                          CustomTextField(
                            label: AppLocalizations.of(context)!.age,
                            hintText: AppLocalizations.of(context)!.yourAge,
                            prefixIcon: Icons.cake_outlined,
                            controller: _ageController,
                            focusNode: _ageFocus,
                            validator: _validateAge,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Password field
                          CustomTextField(
                            label: AppLocalizations.of(context)!.password,
                            hintText: AppLocalizations.of(
                              context,
                            )!.minimum6Characters,
                            prefixIcon: Icons.lock_outline,
                            controller: _passwordController,
                            focusNode: _passwordFocus,
                            validator: _validatePassword,
                            obscureText: true,
                          ),
                          const SizedBox(height: 10),

                          // Confirm Password field
                          CustomTextField(
                            label: AppLocalizations.of(
                              context,
                            )!.confirmPassword,
                            hintText: AppLocalizations.of(
                              context,
                            )!.repeatPassword,
                            prefixIcon: Icons.lock_outline,
                            controller: _confirmPasswordController,
                            focusNode: _confirmPasswordFocus,
                            validator: _validateConfirmPassword,
                            obscureText: true,
                          ),
                          const SizedBox(height: 32),

                          // Signup button
                          CustomButton(
                            text: AppLocalizations.of(context)!.createMyAccount,
                            onPressed: _signup,
                            isLoading: authState.isLoading,
                          ),
                          const SizedBox(height: 16),

                          // Login link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppLocalizations.of(
                                  context,
                                )!.alreadyHaveAccount,
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(
                                    context,
                                  ).pushReplacementNamed('/login');
                                },
                                child: Text(
                                  "  ${AppLocalizations.of(context)!.login}",
                                  style: TextStyle(
                                    color: Color(AppConstants.primaryColor),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Terms text
                  Text(
                    AppLocalizations.of(context)!.termsConditionsPrivacy,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
