import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationData {
  final double latitude;
  final double longitude;
  final String city;
  final String country;
  final String? region;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.country,
    this.region,
  });
}

class LocationService {
  static Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Vérifier si le service de localisation est activé
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Les services de localisation sont désactivés.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Les permissions de localisation sont refusées');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Les permissions de localisation sont définitivement refusées, nous ne pouvons pas demander les permissions.',
      );
    }
    return true;
  }

  static Future<LocationData> getCurrentLocation() async {
    // Vérifier les permissions
    await _handleLocationPermission();

    // Obtenir la position actuelle
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      ),
    );

    // Faire le geocoding inverse pour obtenir l'adresse
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isEmpty) {
      throw Exception(
        'Impossible de déterminer l\'adresse pour cette localisation',
      );
    }

    Placemark place = placemarks[0];

    return LocationData(
      latitude: position.latitude,
      longitude: position.longitude,
      city: place.locality ?? place.subAdministrativeArea ?? 'Ville inconnue',
      country: place.country ?? 'Pays inconnu',
      region: place.administrativeArea,
    );
  }

  static Future<LocationData?> getLocationFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);

      if (locations.isEmpty) {
        return null;
      }

      Location location = locations[0];

      // Faire le geocoding inverse pour obtenir les détails de l'adresse
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isEmpty) {
        return null;
      }

      Placemark place = placemarks[0];

      return LocationData(
        latitude: location.latitude,
        longitude: location.longitude,
        city: place.locality ?? place.subAdministrativeArea ?? 'Unknown City',
        country: place.country ?? 'Unknown country',
        region: place.administrativeArea,
      );
    } catch (e) {
      return null;
    }
  }
}
