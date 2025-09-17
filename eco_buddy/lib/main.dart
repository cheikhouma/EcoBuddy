import 'package:eco_buddy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'shared/services/tflite_service.dart';
import 'shared/services/scan_cache_service.dart';
import 'features/splash/presentation/splash_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/signup_screen.dart';
import 'features/main/presentation/main_screen.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'features/scanner/presentation/unified_scanner_screen.dart';
import 'features/profile/presentation/complete_profile_screen.dart';
import 'core/widgets/permission_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser TensorFlow Lite au démarrage
  await TFLiteService.initialize();

  // 🚀 Pré-charger le cache des objets courants en arrière-plan
  ScanCacheService.preloadCommonObjects();

  runApp(const ProviderScope(child: EcoBuddyApp()));
}

class EcoBuddyApp extends ConsumerWidget {
  const EcoBuddyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('fr')],
      home: const SplashScreen(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/main': (context) => const MainScreen(),
        '/dashboard': (context) =>
            const MainScreen(), // Redirect dashboard to main
        '/settings': (context) => const SettingsScreen(),
        '/complete-profile': (context) => const CompleteProfileScreen(),
        '/scanner': (context) => const PermissionWrapper(
          permissionName: 'Caméra',
          errorMessage:
              'Le scanner nécessite l\'accès à la caméra pour détecter les objets.',
          child: UnifiedScannerScreen(initialMode: ScanMode.ar),
        ),
        '/ar_scanner': (context) => const PermissionWrapper(
          permissionName: 'Caméra',
          errorMessage:
              'Le scanner AR nécessite l\'accès à la caméra pour détecter les objets en temps réel.',
          child: UnifiedScannerScreen(initialMode: ScanMode.ar),
        ),
        '/quick_scanner': (context) => const PermissionWrapper(
          permissionName: 'Caméra',
          errorMessage:
              'Le scanner rapide nécessite l\'accès à la caméra.',
          child: UnifiedScannerScreen(initialMode: ScanMode.quick),
        ),
        '/detailed_scanner': (context) => const PermissionWrapper(
          permissionName: 'Caméra',
          errorMessage:
              'Le scanner détaillé nécessite l\'accès à la caméra.',
          child: UnifiedScannerScreen(initialMode: ScanMode.detailed),
        ),
      },
    );
  }
}
