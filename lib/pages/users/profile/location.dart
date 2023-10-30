import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../../../models/update_profile_models.dart';
import '../../../services/user_services.dart';
import '../../../widgets/app/alert_service.dart';
import '../../../widgets/app_widget/app_bar_widget.dart';
import '../../../widgets/loading.dart';

class LocationUpdate extends StatefulWidget {
  const LocationUpdate({super.key, this.params});
  final dynamic params;

  @override
  _LocationUpdateState createState() => _LocationUpdateState();
}

class _LocationUpdateState extends State<LocationUpdate> {
  late GoogleMapController mapController;
  static LatLng _center = const LatLng(0.0, 0.0);
  final Set<Marker> _markers = {};
  LatLng _currentMapPosition = _center;
  MerchantUpdate requestModel = MerchantUpdate();
  UserServices userServices = UserServices();
  AlertService alertWidget = AlertService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _onAddMarkerButtonPressed();
  }

  void _onAddMarkerButtonPressed() {
    var data = widget.params[0];
    setState(() {
      _center = LatLng(data['latitude'], data['longitude']);
      _currentMapPosition = _center;
      _markers.add(Marker(
        markerId: MarkerId(_currentMapPosition.toString()),
        position: _currentMapPosition,
        draggable: true,
        onDragEnd: ((newPosition) {
          requestModel.latitude = newPosition.latitude;
          requestModel.longitude = newPosition.longitude;
          updateMerchantInfoSubmit(data);
        }),
        icon: BitmapDescriptor.defaultMarker,
      ));
    });
  }

  void _onCameraMove(CameraPosition position) {
    _currentMapPosition = position.target;
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const LoadingWidget()
        : Scaffold(
            appBar: const AppBarWidget(
              title: "Update Location",
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Stack(
              children: <Widget>[
                GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _center,
                      zoom: 5.0,
                    ),
                    markers: _markers,
                    onCameraMove: _onCameraMove),
              ],
            ),
          );
  }

  updateMerchantInfoSubmit(data) {
    var dt = DateFormat('dd-mm-yyyy');
    var nationExpiryDate = dt.parse(data['nationalIdExpiry'].toString());
    var tradeExpiryDate = dt.parse(data['tradeLicenseExpiry'].toString());
    setLoading(true);
    requestModel.firstName = data['customer']['firstName'];
    requestModel.lastName = data['customer']['lastName'];
    requestModel.merchantZipCode = data['merchantZipCode'];
    requestModel.merchName = data['merchantName'].toString();
    requestModel.currencyId = data['currencyId'].toString();
    requestModel.mcc = data['mcc'].toString();
    requestModel.companyRegNumber = data['companyRegNumber'].toString();
    requestModel.businessType = data['businessType'].toString();
    requestModel.companyRegNumber = data['companyRegNumber'].toString();
    requestModel.tradeLicenseExpiry =
        DateFormat('dd-mm-yyyy').format(tradeExpiryDate);
    requestModel.tradeLicenseCode = data['tradeLicenseCode'].toString();
    requestModel.nationalId = data['nationalId'].toString();
    requestModel.nationalIdExpiry =
        DateFormat('dd-mm-yyyy').format(nationExpiryDate);
    userServices.updateUserDetails(requestModel).then((result) {
      print(result.body);
      var response = jsonDecode(result.body);
      setLoading(false);
      if (result.statusCode == 200 || result.statusCode == 201) {
        if (response['responseCode'] == '00') {
          Navigator.pushNamed(context, 'myAccount');
          alertWidget.success(context, 'Success', response['responseMessage']);
        } else {
          setLoading(false);
          alertWidget.failure(context, 'Failure', response['responseMessage']);
        }
      } else {
        setLoading(false);
        alertWidget.failure(context, 'Failure', response['message']);
      }
    });
  }

  setLoading(bool tf) {
    setState(() {
      _isLoading = tf;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }
}
