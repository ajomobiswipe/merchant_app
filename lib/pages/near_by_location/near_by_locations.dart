import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sifr_latest/widgets/app_widget/app_bar_widget.dart';

import '../../models/models.dart';
import '../../services/services.dart';

class NearByLocations extends StatefulWidget {
  const NearByLocations({Key? key}) : super(key: key);

  @override
  State<NearByLocations> createState() => _NearByLocationsState();
}

class _NearByLocationsState extends State<NearByLocations> {
  NearByLocationRequest request = NearByLocationRequest();
  NearByLocationServices services = NearByLocationServices();
  bool _isLoading = false;
  final Completer<GoogleMapController> _controller = Completer();
  final List<Marker> _markers = <Marker>[];
  Geolocator geolocator = Geolocator();
  late Position userLocation;
  static const CameraPosition _kGooglePlex =
      CameraPosition(target: LatLng(10.3724267, 77.9592583), zoom: 14);

  @override
  void initState() {
    getLocation();
    super.initState();
  }

  getLocation() async {
    _getLocation().then((position) {
      userLocation = position!;
      setState(() {
        _isLoading = true;
        request.deviceType = "POS";
        request.latitude = userLocation.latitude;
        request.longitude = userLocation.longitude;
      });
      getNearestStore();
    });
  }

  Future<Position?> _getLocation() async {
    Position? currentLocation;
    try {
      currentLocation = await Geolocator.getCurrentPosition();
    } catch (e) {
      currentLocation = null;
    }
    return currentLocation;
  }

  getNearestStore() {
    setState(() {
      _isLoading = true;
    });
    services.nearestGeoLocation(request).then(
      (response) async {
        if (response.statusCode == 200 || response.statusCode == 201) {
          var decodeData = jsonDecode(response.body);
          if (decodeData['responseCode'].toString() == '00') {
            List loc = decodeData['locationCoOrdinates'];
            // setState(() {
            _markers.addAll(
              loc.map(
                (e) => Marker(
                  markerId: MarkerId("${e['latitude']} ${e['longitude']}"),
                  position: LatLng(e['latitude'], e['longitude']),
                  infoWindow: const InfoWindow(title: 'SIFR Store'),
                ),
              ),
            );
            // });
          }
          setState(() {
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.isCompleted;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(
        title: 'Nearby Location',
      ),
      body: GoogleMap(
        initialCameraPosition: _kGooglePlex,
        mapType: MapType.normal,
        myLocationEnabled: true,
        markers: Set<Marker>.of(_markers),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}
