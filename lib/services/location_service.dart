import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();

  factory LocationService() {
    return _instance;
  }

  LocationService._internal();

  Future<bool> requestLocationPermission() async {
    final status = await Geolocator.requestPermission();
    return status == LocationPermission.always ||
        status == LocationPermission.whileInUse;
  }

  Future<Position?> getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final result = await requestLocationPermission();
        if (!result) return null;
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 10,
        ),
      );

      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        return "${place.street}, ${place.subAdministrativeArea}, ${place.administrativeArea}, ${place.country}";
      }
      return "Lokasi tidak tersedia";
    } catch (e) {
      print('Error getting address: $e');
      return "Lokasi tidak tersedia";
    }
  }

  Future<Position?> getLocationFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations[0];
        return Position(
          latitude: location.latitude,
          longitude: location.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      }
    } catch (e) {
      print('Error getting location from address: $e');
    }
    return null;
  }
}
