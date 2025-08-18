import 'package:anet_merchant_app/main.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_text_widget.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  bool _isDialogShown = false;
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  void initialize() {
    Connectivity().onConnectivityChanged.listen((result) {
      if (result.contains(ConnectivityResult.none)) {
        _isOnline = false;
        if (!_isDialogShown) {
          _isDialogShown = true;
          _showNoInternetBottomSheet();
        }
      } else {
        _isOnline = true;
        if (_isDialogShown &&
            NavigationService.navigatorKey.currentState?.canPop() == true) {
          Navigator.of(NavigationService.navigatorKey.currentContext!).pop();
          _isDialogShown = false;
        }
      }
    });
  }

  checkConnectivity() async {
    // check connectivity status in every landing page
    final result = await Connectivity().checkConnectivity();
    if (result[0] == ConnectivityResult.none) {
      _isOnline = false;

      _showNoInternetBottomSheet();
    } else {
      _isOnline = true;
      if (_isDialogShown &&
          NavigationService.navigatorKey.currentState?.canPop() == true) {
        Navigator.of(NavigationService.navigatorKey.currentContext!).pop();
        _isDialogShown = false;
      }
    }
  }

  void _showNoInternetDialog() {
    final context = NavigationService.navigatorKey.currentContext;
    if (context == null) return;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 10,
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.grey.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.red.shade300,
                      highlightColor: Colors.red.shade100,
                      child: Icon(Icons.wifi_off_rounded,
                          size: 60, color: Colors.redAccent),
                    ),
                    const SizedBox(height: 20),
                    const CustomTextWidget(
                      text: 'No Internet Connection',
                      fontWeight: FontWeight.w600,
                      size: 20,
                      color: Colors.black87,
                    ),
                    const SizedBox(height: 12),
                    CustomTextWidget(
                      text: 'Please check your network settings and try again.',
                      textAlign: TextAlign.center,
                      size: 16,
                      color: Colors.grey.shade700,
                    ),
                    const SizedBox(height: 24),
                    // ElevatedButton.icon(
                    //   onPressed: () {
                    //     Navigator.of(context).pop();
                    //   },
                    //   icon: const Icon(Icons.refresh),
                    //   label: const Text('Retry'),
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Colors.redAccent,
                    //     foregroundColor: Colors.white,
                    //     padding: const EdgeInsets.symmetric(
                    //         horizontal: 24, vertical: 12),
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(12),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ));
  }

  void _showNoInternetBottomSheet() {
    final context = NavigationService.navigatorKey.currentContext;
    if (context == null) return;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Shimmer.fromColors(
              baseColor: Colors.red.shade300,
              highlightColor: Colors.red.shade100,
              child: Icon(Icons.wifi_off_rounded,
                  size: 60, color: Colors.redAccent),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Internet Connection',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please check your network settings and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 24),
            // ElevatedButton.icon(
            //   onPressed: () {
            //     Navigator.of(context).pop();
            //   },
            //   icon: const Icon(Icons.refresh),
            //   label: const Text('Retry'),
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.redAccent,
            //     foregroundColor: Colors.white,
            //     padding: const EdgeInsets.symmetric(
            //         horizontal: 24, vertical: 12),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
