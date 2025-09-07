import 'package:geolocator/geolocator.dart';
import 'package:wifi_info_flutter/wifi_info_flutter.dart';

class AccessControlService {
  static Future<bool> isWithinOfficeLocation(
      double officeLat, double officeLon, double radiusMeters) async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    final pos = await Geolocator.getCurrentPosition();
    final distance = Geolocator.distanceBetween(
      officeLat, officeLon,
      pos.latitude, pos.longitude,
    );
    return distance <= radiusMeters;
  }

  static Future<bool> isConnectedToAllowedWiFi(String allowedSSID) async {
    final info = WifiInfo();
    final ssid = await info.getWifiName();
    return ssid != null && ssid == allowedSSID;
  }

  static Future<bool> canAccessScanner({
    required double officeLat,
    required double officeLon,
    required double radiusMeters,
    required String allowedSSID,
  }) async {
    final atLocation = await isWithinOfficeLocation(officeLat, officeLon, radiusMeters);
    final onWiFi = await isConnectedToAllowedWiFi(allowedSSID);
    return atLocation && onWiFi;
  }
}
