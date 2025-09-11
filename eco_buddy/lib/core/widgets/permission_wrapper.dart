import 'package:flutter/material.dart';
import '../../shared/services/permission_service.dart';

/// Widget qui wrap les écrans nécessitant des permissions
class PermissionWrapper extends StatefulWidget {
  final Widget child;
  final String permissionName;
  final String? errorMessage;

  const PermissionWrapper({
    super.key,
    required this.child,
    required this.permissionName,
    this.errorMessage,
  });

  @override
  State<PermissionWrapper> createState() => _PermissionWrapperState();
}

class _PermissionWrapperState extends State<PermissionWrapper> {
  bool _hasPermission = false;
  bool _isLoading = true;
  bool _isPermanentlyDenied = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    setState(() => _isLoading = true);
    
    final hasPermission = await PermissionService.requestCameraPermission();
    
    if (mounted) {
      setState(() {
        _hasPermission = hasPermission;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Chargement...')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Vérification des permissions...'),
            ],
          ),
        ),
      );
    }

    if (!_hasPermission) {
      return Scaffold(
        appBar: AppBar(title: Text('Permission requise')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 24),
                Text(
                  'Permission ${widget.permissionName} requise',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.errorMessage ?? 
                  'Cette fonctionnalité nécessite l\'accès à votre ${widget.permissionName.toLowerCase()}.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Retour'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _checkPermission,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réessayer'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () => PermissionService.openPermissionSettings(),
                  icon: const Icon(Icons.settings),
                  label: const Text('Ouvrir paramètres'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
}