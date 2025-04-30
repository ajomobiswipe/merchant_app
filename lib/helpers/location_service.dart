// import 'package:flutter/foundation.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:anet_merchant_app/widgets/app/alert_service.dart';

// class LocationService {
//   AlertService alertService = AlertService();
//   Future<Position?> getCurrentPosition() async {
//     final hasPermission = await _handleLocationPermission();

//     if (!hasPermission) return null;
//     try {
//       final Position position = await Geolocator.getCurrentPosition(
//         locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
//       );
//       if (!position.isMocked) {
//         return position;
//       } else {
//         alertService.error("Please turn off Mock location");
//         return null;
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print(e);
//       }
//       return null;
//     }
//   }

//   Future<bool> _handleLocationPermission() async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       Geolocator.openLocationSettings();
//       return false;
//     }
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         openAppSettings();
//         return false;
//       }
//     }
//     if (permission == LocationPermission.deniedForever) {
//       openAppSettings();
//       return false;
//     }
//     return true;
//   }
// }
