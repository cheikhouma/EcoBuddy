import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Vérifie et demande les permissions caméra
  static Future<bool> requestCameraPermission() async {
    try {
      // Vérifier le statut actuel
      final status = await Permission.camera.status;
      
      if (status.isGranted) {
        print('✅ Permission caméra déjà accordée');
        return true;
      }
      
      if (status.isDenied || status.isRestricted) {
        print('⚠️ Demande permission caméra...');
        // Demander la permission
        final result = await Permission.camera.request();
        
        if (result.isGranted) {
          print('✅ Permission caméra accordée');
          return true;
        } else {
          print('❌ Permission caméra refusée');
          return false;
        }
      }
      
      if (status.isPermanentlyDenied) {
        print('❌ Permission caméra définitivement refusée');
        // Optionnel : ouvrir les paramètres
        await openAppSettings();
        return false;
      }
      
      return false;
    } catch (e) {
      print('❌ Erreur permission caméra: $e');
      return false;
    }
  }

  /// Vérifie si la permission caméra est accordée
  static Future<bool> isCameraPermissionGranted() async {
    try {
      final status = await Permission.camera.status;
      return status.isGranted;
    } catch (e) {
      print('❌ Erreur vérification permission: $e');
      return false;
    }
  }

  /// Ouvre les paramètres si permission définitivement refusée
  static Future<void> openPermissionSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      print('❌ Impossible d\'ouvrir les paramètres: $e');
    }
  }

  /// Vérifie et demande multiple permissions (pour AR complet)
  static Future<Map<Permission, PermissionStatus>> requestARPermissions() async {
    try {
      return await [
        Permission.camera,
        Permission.storage, // Pour sauvegarder les scans
        Permission.location, // Pour la géolocalisation éco
      ].request();
    } catch (e) {
      print('❌ Erreur permissions AR: $e');
      return {};
    }
  }
}