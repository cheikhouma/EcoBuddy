import 'package:eco_buddy/shared/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/settings_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/card_widget.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final settingsState = ref.watch(settingsProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Paramètres',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User profile section
            if (user != null) _buildUserProfileSection(context, user),
            const SizedBox(height: 24),

            // App settings
            _buildSectionTitle('Paramètres de l\'application'),
            const SizedBox(height: 12),
            settingsState.when(
              data: (settings) => _buildAppSettingsSection(context, ref, settings),
              loading: () => _buildLoadingSection(),
              error: (error, _) => _buildErrorSection(error.toString()),
            ),
            const SizedBox(height: 24),

            // Notifications
            _buildSectionTitle('Notifications'),
            const SizedBox(height: 12),
            settingsState.when(
              data: (settings) => _buildNotificationsSection(context, ref, settings),
              loading: () => _buildLoadingSection(),
              error: (error, _) => _buildErrorSection(error.toString()),
            ),
            const SizedBox(height: 24),

            // Privacy & Security
            _buildSectionTitle('Confidentialité & Sécurité'),
            const SizedBox(height: 12),
            _buildPrivacySection(context),
            const SizedBox(height: 24),

            // About & Support
            _buildSectionTitle('À propos & Support'),
            const SizedBox(height: 12),
            _buildAboutSection(context, ref),
            const SizedBox(height: 24),

            // Logout button
            _buildLogoutSection(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileSection(BuildContext context, User user) {
    return CustomCard(
      child: Row(
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
            child: Center(
              child: Text(
                user.username.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(
                      AppConstants.accentColor,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${user.points} points',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(AppConstants.accentColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showEditProfileDialog(context, user),
            icon: const Icon(
              Icons.edit,
              color: Color(AppConstants.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildAppSettingsSection(BuildContext context, WidgetRef ref, SettingsState settings) {
    return Column(
      children: [
        _buildSettingItem(
          icon: Icons.dark_mode,
          title: 'Mode sombre',
          subtitle: 'Activer le thème sombre',
          trailing: Switch(
            value: settings.isDarkMode,
            onChanged: (value) =>
                ref.read(settingsProvider.notifier).setDarkMode(value),
            activeColor: const Color(AppConstants.primaryColor),
          ),
        ),
        _buildSettingItem(
          icon: Icons.language,
          title: 'Langue',
          subtitle: 'Français',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showLanguageDialog(context),
        ),
        _buildSettingItem(
          icon: Icons.vibration,
          title: 'Vibrations',
          subtitle: 'Retour haptique',
          trailing: Switch(
            value: settings.isVibrationEnabled,
            onChanged: (value) =>
                ref.read(settingsProvider.notifier).setVibration(value),
            activeColor: const Color(AppConstants.primaryColor),
          ),
        ),
        _buildSettingItem(
          icon: Icons.volume_up,
          title: 'Sons',
          subtitle: 'Effets sonores',
          trailing: Switch(
            value: settings.isSoundEnabled,
            onChanged: (value) =>
                ref.read(settingsProvider.notifier).setSound(value),
            activeColor: const Color(AppConstants.primaryColor),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsSection(BuildContext context, WidgetRef ref, SettingsState settings) {
    return Column(
      children: [
        _buildSettingItem(
          icon: Icons.notifications,
          title: 'Notifications push',
          subtitle: 'Recevoir les notifications',
          trailing: Switch(
            value: settings.isNotificationsEnabled,
            onChanged: (value) =>
                ref.read(settingsProvider.notifier).setNotifications(value),
            activeColor: const Color(AppConstants.primaryColor),
          ),
        ),
        _buildSettingItem(
          icon: Icons.emoji_events,
          title: 'Défis quotidiens',
          subtitle: 'Rappels des nouveaux défis',
          trailing: Switch(
            value: settings.isDailyChallengesEnabled,
            onChanged: (value) =>
                ref.read(settingsProvider.notifier).setDailyChallenges(value),
            activeColor: const Color(AppConstants.primaryColor),
          ),
        ),
        _buildSettingItem(
          icon: Icons.leaderboard,
          title: 'Classement',
          subtitle: 'Notifications de classement',
          trailing: Switch(
            value: settings.isLeaderboardEnabled,
            onChanged: (value) =>
                ref.read(settingsProvider.notifier).setLeaderboard(value),
            activeColor: const Color(AppConstants.primaryColor),
          ),
        ),
        _buildSettingItem(
          icon: Icons.schedule,
          title: 'Rappels d\'activité',
          subtitle: 'Quand arrêter, être actif',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showReminderDialog(context),
        ),
      ],
    );
  }

  Widget _buildPrivacySection(BuildContext context) {
    return Column(
      children: [
        _buildSettingItem(
          icon: Icons.location_on,
          title: 'Localisation',
          subtitle: 'Partager votre localisation',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showLocationDialog(context),
        ),
        _buildSettingItem(
          icon: Icons.analytics,
          title: 'Données d\'usage',
          subtitle: 'Partager les données anonymes',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showDataUsageDialog(context),
        ),
        _buildSettingItem(
          icon: Icons.security,
          title: 'Sécurité',
          subtitle: 'Authentification et sécurité',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showSecurityDialog(context),
        ),
        _buildSettingItem(
          icon: Icons.delete_forever,
          title: 'Supprimer mon compte',
          subtitle: 'Supprimer définitivement',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showDeleteAccountDialog(context),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _buildSettingItem(
          icon: Icons.help,
          title: 'Aide & FAQ',
          subtitle: 'Questions fréquentes',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showHelpDialog(context),
        ),
        _buildSettingItem(
          icon: Icons.contact_support,
          title: 'Nous contacter',
          subtitle: 'Support technique',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showContactDialog(context),
        ),
        _buildSettingItem(
          icon: Icons.rate_review,
          title: 'Évaluer l\'app',
          subtitle: 'Donner votre avis',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showRateDialog(context),
        ),
        _buildSettingItem(
          icon: Icons.info,
          title: 'À propos',
          subtitle: 'Version 1.0.0',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showAboutDialog(context),
        ),
      ],
    );
  }

  Widget _buildLogoutSection(BuildContext context, WidgetRef ref) {
    return CustomCard(
      backgroundColor: const Color(
        AppConstants.errorColor,
      ).withValues(alpha: 0.05),
      child: ListTile(
        leading: const Icon(
          Icons.logout,
          color: Color(AppConstants.errorColor),
        ),
        title: const Text(
          'Se déconnecter',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(AppConstants.errorColor),
          ),
        ),
        subtitle: const Text('Déconnexion de votre compte'),
        onTap: () => _showLogoutDialog(context, ref),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return CustomCard(
      onTap: onTap,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(
              AppConstants.primaryColor,
            ).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(AppConstants.primaryColor),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        trailing: trailing,
      ),
    );
  }

  Widget _buildLoadingSection() {
    return Column(
      children: List.generate(
        4,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 72,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorSection(String error) {
    return CustomCard(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Color(AppConstants.errorColor),
              ),
              const SizedBox(height: 16),
              Text(
                'Erreur de chargement',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                error,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, User user) {
    final TextEditingController usernameController = TextEditingController(text: user.username);
    final TextEditingController emailController = TextEditingController(text: user.email);
    
    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final authState = ref.watch(authProvider);
          
          return AlertDialog(
            title: const Text('Modifier le profil'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom d\'utilisateur',
                      border: OutlineInputBorder(),
                    ),
                    enabled: !authState.isLoading,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    enabled: !authState.isLoading,
                  ),
                  if (authState.isLoading) ...[
                    const SizedBox(height: 16),
                    const CircularProgressIndicator(
                      color: Color(AppConstants.primaryColor),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: authState.isLoading ? null : () => Navigator.of(context).pop(),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: authState.isLoading ? null : () async {
                  final newUsername = usernameController.text.trim();
                  final newEmail = emailController.text.trim();
                  
                  if (newUsername.isEmpty || newEmail.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Veuillez remplir tous les champs'),
                        backgroundColor: Color(AppConstants.errorColor),
                      ),
                    );
                    return;
                  }
                  
                  if (!_isValidEmail(newEmail)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Format d\'email invalide'),
                        backgroundColor: Color(AppConstants.errorColor),
                      ),
                    );
                    return;
                  }
                  
                  try {
                    await ref.read(authProvider.notifier).updateProfile(newUsername, newEmail);
                    
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profil mis à jour avec succès'),
                          backgroundColor: Color(AppConstants.primaryColor),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erreur: ${e.toString()}'),
                          backgroundColor: const Color(AppConstants.errorColor),
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(AppConstants.primaryColor),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Sauvegarder'),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  void _showLanguageDialog(BuildContext context) {
    final languages = {
      'fr': 'Français',
      'en': 'English',
      'es': 'Español',
      'ar': 'العربية',
    };
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir la langue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.entries.map((entry) => ListTile(
            title: Text(entry.value),
            leading: Radio<String>(
              value: entry.key,
              groupValue: 'fr', // Current language
              onChanged: (value) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Langue changée en ${entry.value}'),
                    backgroundColor: const Color(AppConstants.primaryColor),
                  ),
                );
              },
            ),
            onTap: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Langue changée en ${entry.value}'),
                  backgroundColor: const Color(AppConstants.primaryColor),
                ),
              );
            },
          )).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showReminderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rappels d\'activité'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fréquence des rappels:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            RadioListTile<String>(
              title: const Text('Toutes les heures'),
              value: 'hourly',
              groupValue: 'daily',
              onChanged: (value) {},
            ),
            RadioListTile<String>(
              title: const Text('Tous les jours'),
              value: 'daily',
              groupValue: 'daily',
              onChanged: (value) {},
            ),
            RadioListTile<String>(
              title: const Text('Toutes les semaines'),
              value: 'weekly',
              groupValue: 'daily',
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            const Text(
              'Heure préférée: 18:00',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Rappels configurés'),
                  backgroundColor: Color(AppConstants.primaryColor),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppConstants.primaryColor),
              foregroundColor: Colors.white,
            ),
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }

  void _showLocationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Paramètres de localisation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Autoriser EcoBuddy à accéder à votre localisation pour:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            const Text('• Trouver des défis locaux'),
            const Text('• Localiser les centres de recyclage'),
            const Text('• Voir l\'impact environnemental de votre région'),
            const Text('• Participer aux classements locaux'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Text(
                '🔒 Vos données de localisation sont chiffrées et ne sont jamais partagées avec des tiers.',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Refuser'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Localisation activée'),
                  backgroundColor: Color(AppConstants.primaryColor),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppConstants.primaryColor),
              foregroundColor: Colors.white,
            ),
            child: const Text('Autoriser'),
          ),
        ],
      ),
    );
  }

  void _showDataUsageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Données d\'usage'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aider à améliorer EcoBuddy en partageant:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            const Text('• Statistiques d\'utilisation anonymes'),
            const Text('• Rapport de bugs et plantages'),
            const Text('• Préférences d\'utilisation'),
            const Text('• Données de performance'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: const Text(
                '✓ Aucune donnée personnelle n\'est collectée\n✓ Toutes les données sont anonymisées\n✓ Vous pouvez désactiver à tout moment',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Ne pas partager'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Partage de données activé'),
                  backgroundColor: Color(AppConstants.primaryColor),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppConstants.primaryColor),
              foregroundColor: Colors.white,
            ),
            child: const Text('Accepter'),
          ),
        ],
      ),
    );
  }

  void _showSecurityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sécurité'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.lock_outline, color: Color(AppConstants.primaryColor)),
              title: const Text('Changer le mot de passe'),
              subtitle: const Text('Modifier votre mot de passe'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.of(context).pop();
                _showChangePasswordDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.fingerprint, color: Color(AppConstants.primaryColor)),
              title: const Text('Authentification biométrique'),
              subtitle: const Text('Empreinte digitale / Face ID'),
              trailing: Switch(
                value: false,
                onChanged: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Authentification biométrique activée'),
                      backgroundColor: Color(AppConstants.primaryColor),
                    ),
                  );
                },
                activeColor: const Color(AppConstants.primaryColor),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.security, color: Color(AppConstants.primaryColor)),
              title: const Text('Sessions actives'),
              subtitle: const Text('Gérer vos sessions connectées'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.of(context).pop();
                _showActiveSessionsDialog(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Supprimer le compte',
          style: TextStyle(color: Color(AppConstants.errorColor)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚠️ Cette action est irréversible !',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(AppConstants.errorColor),
              ),
            ),
            const SizedBox(height: 16),
            const Text('La suppression de votre compte entraînera:'),
            const SizedBox(height: 8),
            const Text('• Perte de tous vos points et progrès'),
            const Text('• Suppression de votre historique'),
            const Text('• Perte de vos données de scan'),
            const Text('• Suppression de votre classement'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: const Text(
                'Voulez-vous vraiment supprimer définitivement votre compte ?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showFinalDeleteConfirmation(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppConstants.errorColor),
              foregroundColor: Colors.white,
            ),
            child: const Text('Continuer'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aide & FAQ'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Questions fréquentes:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('• Comment scanner un objet ?'),
            Text('• Comment gagner des points ?'),
            Text('• Comment participer aux défis ?'),
            Text('• Comment voir mon classement ?'),
            SizedBox(height: 16),
            Text('Pour plus d\'aide, contactez le support technique.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nous contacter'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.email, color: Color(AppConstants.primaryColor)),
              title: const Text('Email'),
              subtitle: const Text('support@ecobuddy.app'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Email copié dans le presse-papiers'),
                    backgroundColor: Color(AppConstants.primaryColor),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone, color: Color(AppConstants.primaryColor)),
              title: const Text('Téléphone'),
              subtitle: const Text('+33 1 23 45 67 89'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Numéro copié dans le presse-papiers'),
                    backgroundColor: Color(AppConstants.primaryColor),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Color(AppConstants.primaryColor)),
              title: const Text('Chat en direct'),
              subtitle: const Text('Disponible 9h-18h'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chat en direct bientôt disponible'),
                    backgroundColor: Color(AppConstants.primaryColor),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showRateDialog(BuildContext context) {
    int rating = 0;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Évaluer EcoBuddy'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Que pensez-vous de notre application ?',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () {
                      setState(() {
                        rating = index + 1;
                      });
                    },
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              if (rating > 0)
                Text(
                  rating >= 4
                      ? 'Merci ! Votre avis nous aide à grandir 🌱'
                      : 'Merci pour votre retour, nous allons nous améliorer !',
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Plus tard'),
            ),
            if (rating > 0)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Merci pour votre note de $rating étoile${rating > 1 ? 's' : ''} !'),
                      backgroundColor: const Color(AppConstants.primaryColor),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(AppConstants.primaryColor),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Envoyer'),
              ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 EcoBuddy Team',
      children: [
        const SizedBox(height: 16),
        const Text(
          'EcoBuddy est une application dédiée à la sensibilisation environnementale. '
          'Scannez des objets, relevez des défis écologiques et participez à la protection '
          'de notre planète !',
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(
                    color: Color(AppConstants.primaryColor),
                  ),
                ),
              );
              
              try {
                // Perform logout
                await ref.read(authProvider.notifier).logout();
                
                // Close loading dialog
                if (context.mounted) Navigator.of(context).pop();
                
                // Navigate to login screen
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                  );
                }
              } catch (e) {
                // Close loading dialog
                if (context.mounted) Navigator.of(context).pop();
                
                // Show error
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur lors de la déconnexion: $e'),
                      backgroundColor: const Color(AppConstants.errorColor),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppConstants.errorColor),
              foregroundColor: Colors.white,
            ),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final TextEditingController currentPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Changer le mot de passe'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe actuel',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Nouveau mot de passe',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirmer le mot de passe',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (newPasswordController.text == confirmPasswordController.text) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mot de passe modifié avec succès'),
                    backgroundColor: Color(AppConstants.primaryColor),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Les mots de passe ne correspondent pas'),
                    backgroundColor: Color(AppConstants.errorColor),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppConstants.primaryColor),
              foregroundColor: Colors.white,
            ),
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
  }

  void _showActiveSessionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sessions actives'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone_android, color: Color(AppConstants.primaryColor)),
              title: const Text('Android - Appareil actuel'),
              subtitle: const Text('Dernière activité: maintenant'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Actuel',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.computer, color: Colors.grey),
              title: const Text('Chrome - Windows'),
              subtitle: const Text('Dernière activité: il y a 2 jours'),
              trailing: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Session révoquée'),
                      backgroundColor: Color(AppConstants.primaryColor),
                    ),
                  );
                },
                child: const Text('Révoquer'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Toutes les autres sessions ont été révoquées'),
                  backgroundColor: Color(AppConstants.primaryColor),
                ),
              );
            },
            child: const Text('Révoquer toutes'),
          ),
        ],
      ),
    );
  }

  void _showFinalDeleteConfirmation(BuildContext context) {
    final TextEditingController confirmController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Confirmation finale',
          style: TextStyle(color: Color(AppConstants.errorColor)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pour confirmer la suppression, tapez "SUPPRIMER" ci-dessous:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmController,
              decoration: const InputDecoration(
                hintText: 'SUPPRIMER',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (confirmController.text == 'SUPPRIMER') {
                Navigator.of(context).pop();
                // Show loading and perform deletion
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(
                      color: Color(AppConstants.errorColor),
                    ),
                  ),
                );
                
                // Simulate deletion process
                Future.delayed(const Duration(seconds: 2), () {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Compte supprimé avec succès'),
                        backgroundColor: Color(AppConstants.errorColor),
                      ),
                    );
                    // Navigate to welcome screen
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/welcome',
                      (route) => false,
                    );
                  }
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez taper "SUPPRIMER" pour confirmer'),
                    backgroundColor: Color(AppConstants.errorColor),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppConstants.errorColor),
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer définitivement'),
          ),
        ],
      ),
    );
  }
}
