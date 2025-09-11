import 'package:eco_buddy/core/constants/app_constants.dart';
import 'package:eco_buddy/core/widgets/custom_button.dart';
import 'package:eco_buddy/core/widgets/custom_text_field.dart';
import 'package:eco_buddy/shared/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      return 'Nom d\'utilisateur requis';
    }
    if (value.length < 3) {
      return 'Minimum 3 caractères';
    }
    if (value.length > 50) {
      return 'Maximum 50 caractères';
    }
    // autorise uniquement lettres, chiffres et _
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Seuls les lettres, chiffres et _ sont autorisés';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email requis';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Format d\'email invalide';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mot de passe requis';
    }
    if (value.length < 6) {
      return 'Minimum 6 caractères';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirmation requise';
    }
    if (value != _passwordController.text) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }

  String? _validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Âge requis';
    }
    final age = int.tryParse(value);
    if (age == null) {
      return 'Âge invalide';
    }
    if (age < 13) {
      return 'Âge minimum 13 ans';
    }
    if (age > 120) {
      return 'Âge maximum 120 ans';
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
              content: Text('Inscription échouée: ${e.toString()}'),

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
      backgroundColor: Colors.grey[50],

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                const Icon(
                  Icons.eco,
                  size: 60,
                  color: Color(AppConstants.primaryColor),
                ),
                const SizedBox(height: 16),
                Text(
                  'Rejoignez ${AppConstants.appName}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Créez votre compte pour commencer votre parcours écologique',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),

                // Form Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Username field
                        CustomTextField(
                          label: 'Nom d\'utilisateur',
                          hintText: 'Choisissez un nom d\'utilisateur',
                          prefixIcon: Icons.person_outline,
                          controller: _usernameController,
                          focusNode: _usernameFocus,
                          validator: _validateUsername,
                          textCapitalization: TextCapitalization.none,
                          onChanged: (value) {
                            // Remove validation error on type
                            if (authState.error != null) {
                              ref.read(authProvider.notifier).state = authState
                                  .copyWith(error: null);
                            }
                          },
                        ),
                        const SizedBox(height: 20),

                        // Email field
                        CustomTextField(
                          label: 'Adresse email',
                          hintText: 'votre@email.com',
                          prefixIcon: Icons.email_outlined,
                          controller: _emailController,
                          focusNode: _emailFocus,
                          validator: _validateEmail,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),

                        // Age field
                        CustomTextField(
                          label: 'Âge',
                          hintText: 'Votre âge',
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
                        const SizedBox(height: 20),

                        // Password field
                        CustomTextField(
                          label: 'Mot de passe',
                          hintText: 'Minimum 6 caractères',
                          prefixIcon: Icons.lock_outline,
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          validator: _validatePassword,
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),

                        // Confirm Password field
                        CustomTextField(
                          label: 'Confirmer le mot de passe',
                          hintText: 'Répétez votre mot de passe',
                          prefixIcon: Icons.lock_outline,
                          controller: _confirmPasswordController,
                          focusNode: _confirmPasswordFocus,
                          validator: _validateConfirmPassword,
                          obscureText: true,
                        ),
                        const SizedBox(height: 32),

                        // Signup button
                        CustomButton(
                          text: 'Créer mon compte',
                          onPressed: _signup,
                          isLoading: authState.isLoading,
                          icon: Icons.person_add,
                        ),
                        const SizedBox(height: 16),

                        // Login link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Déjà un compte ? ',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(
                                  context,
                                ).pushReplacementNamed('/login');
                              },
                              child: const Text(
                                'Se connecter',
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
                  'En créant un compte, vous acceptez nos conditions d\'utilisation et notre politique de confidentialité.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
