import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/card_widget.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/services/api_service.dart';

class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _regionController = TextEditingController();

  bool _isLoading = false;
  double? _latitude;
  double? _longitude;

  @override
  void dispose() {
    _cityController.dispose();
    _countryController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implémenter la géolocalisation réelle avec geolocator
      // Pour l'instant, on utilise des coordonnées factices pour Paris
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _latitude = 48.8566;
        _longitude = 2.3522;
        _cityController.text = 'Paris';
        _countryController.text = 'France';
        _regionController.text = 'Île-de-France';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📍 Localisation récupérée avec succès'),
            backgroundColor: Color(AppConstants.primaryColor),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur de géolocalisation: $e'),
            backgroundColor: const Color(AppConstants.errorColor),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _completeProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ApiService.updateLocation(
        city: _cityController.text.trim(),
        country: _countryController.text.trim(),
        region: _regionController.text.trim().isEmpty
            ? null
            : _regionController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
      );

      // Refresh auth state
      await ref.read(authProvider.notifier).checkAuthStatus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Profil complété avec succès !'),
            backgroundColor: Color(AppConstants.primaryColor),
          ),
        );

        // Retourner à l'écran précédent
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: ${e.toString()}'),
            backgroundColor: const Color(AppConstants.errorColor),
          ),
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Compléter votre profil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              CustomCard(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(AppConstants.primaryColor),
                            Color(AppConstants.secondaryColor),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Salut ${user?.username ?? 'EcoBuddy'} ! 👋',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Dites-nous où vous êtes pour découvrir des défis et centres de recyclage près de chez vous !',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Localisation automatique
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📍 Localisation automatique',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Utilisez votre position GPS pour remplir automatiquement vos informations.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _getCurrentLocation,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.my_location),
                        label: Text(
                          _isLoading
                              ? 'Localisation...'
                              : 'Utiliser ma position',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            AppConstants.secondaryColor,
                          ),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Ou saisie manuelle
              const Text(
                '✏️ Ou saisissez manuellement',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Champs de saisie
              CustomCard(
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _cityController,
                      label: 'Ville *',
                      prefixIcon: Icons.location_city,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez saisir votre ville';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _countryController,
                      label: 'Pays *',
                      prefixIcon: Icons.flag,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez saisir votre pays';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _regionController,
                      label: 'Région (optionnel)',
                      prefixIcon: Icons.map,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Informations de confidentialité
              CustomCard(
                backgroundColor: Colors.blue.shade50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.privacy_tip, color: Colors.blue.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'Confidentialité',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Vos données sont chiffrées et sécurisées\n'
                      '• Elles ne sont jamais partagées avec des tiers\n'
                      '• Vous pouvez les modifier à tout moment\n'
                      '• Utilisées uniquement pour améliorer votre expérience',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.of(
                              context,
                            ).pushReplacementNamed('/dashboard'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: const Text('Ignorer pour l\'instant'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: CustomButton(
                      text: 'Compléter mon profil',
                      onPressed: _isLoading ? null : _completeProfile,
                      isLoading: _isLoading,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
