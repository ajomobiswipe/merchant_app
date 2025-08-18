import 'package:anet_merchant_app/main.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ConnectivityProvider with ChangeNotifier {
  bool _isOnline = false;
  bool get isOnline => _isOnline;

  ConnectivityProvider() {
    Connectivity connectivity = Connectivity();
    connectivity.onConnectivityChanged.listen((result) async {
      // if (result == ConnectivityResult.none) {
      if (result[0] == ConnectivityResult.none) {
        _isOnline = false;
        _showNoInternetDialog();
        // StateKey.snackBarKey.currentState?.showSnackBar(
        //   SnackBar(
        //     content: Text('No Internet Connection'),
        //     backgroundColor: Colors.red,
        //     duration: Duration(days: 1),
        //   ),
        // );
        notifyListeners();
      } else {
        if (NavigationService.navigatorKey.currentState?.canPop() == true) {
          Navigator.of(NavigationService.navigatorKey.currentContext!).pop();
        }
        // _isOnline = true;
        // if (!_internetConnected) {
        //   _internetConnected = true;
        //   StateKey.snackBarKey.currentState?.hideCurrentSnackBar();
        //   StateKey.snackBarKey.currentState?.showSnackBar(
        //     SnackBar(
        //       content: Text('Connected'),
        //       backgroundColor: Colors.green,
        //       duration: Duration(seconds: 5),
        //     ),
        //   );
        // }
        // notifyListeners();
      }
    });
    // connectivity.checkConnectivity().then((result) {
    //   if (result[0] == ConnectivityResult.none) {
    //     _isOnline = false;
    //     _internetConnected = false;
    //     _showNoInternetDialog();
    //   } else {
    //     _isOnline = true;
    //     _internetConnected = true;
    //   }
    //   notifyListeners();
    // });
  }

  checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    if (result[0] == ConnectivityResult.none) {
      _isOnline = false;
      _showNoInternetDialog();
    } else {
      _isOnline = true;
    }
    notifyListeners();
  }

  /// Shows a dialog with a message and a retry button when there is no internet connection.
  ///
  /// The dialog is not dismissible and will remain on the screen until the user closes it.
  /// The retry button will close the dialog and allow the user to try again.
  ///
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
            ));
  }
}

// import 'package:anet_merchant_app/core/state_key.dart';
// import 'package:anet_merchant_app/main.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:shimmer/shimmer.dart';

// class ConnectivityProvider with ChangeNotifier {
//   bool _isOnline = false;
//   bool get isOnline => _isOnline;
//   bool _isDialogShown = false;

//   ConnectivityProvider() {
//     Connectivity connectivity = Connectivity();
//     connectivity.onConnectivityChanged.listen((result) async {
//       // if (result == ConnectivityResult.none) {
//       if (result.contains(ConnectivityResult.none)) {
//         _isOnline = false;
//         if (!_isDialogShown) {
//           _isDialogShown = true;
//           _showNoInternetDialog();
//         }
//       } else {
//         _isOnline = true;
//         if (_isDialogShown &&
//             NavigationService.navigatorKey.currentState?.canPop() == true) {
//           Navigator.of(NavigationService.navigatorKey.currentContext!).pop();
//           _isDialogShown = false;
//         }
//       }
//     });

//   }

//   void _showNoInternetDialog() {
//     final context = NavigationService.navigatorKey.currentContext;
//     if (context == null) return;

//     showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (_) => Dialog(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               elevation: 10,
//               insetPadding:
//                   const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
//               child: Container(
//                 padding: const EdgeInsets.all(24),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(20),
//                   gradient: LinearGradient(
//                     colors: [Colors.white, Colors.grey.shade100],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Shimmer.fromColors(
//                       baseColor: Colors.red.shade300,
//                       highlightColor: Colors.red.shade100,
//                       child: Icon(Icons.wifi_off_rounded,
//                           size: 60, color: Colors.redAccent),
//                     ),
//                     const SizedBox(height: 20),
//                     const Text(
//                       'No Internet Connection',
//                       style: TextStyle(
//                         fontWeight: FontWeight.w600,
//                         fontSize: 20,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Text(
//                       'Please check your network settings and try again.',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.grey.shade700,
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     // ElevatedButton.icon(
//                     //   onPressed: () {
//                     //     Navigator.of(context).pop();
//                     //   },
//                     //   icon: const Icon(Icons.refresh),
//                     //   label: const Text('Retry'),
//                     //   style: ElevatedButton.styleFrom(
//                     //     backgroundColor: Colors.redAccent,
//                     //     foregroundColor: Colors.white,
//                     //     padding: const EdgeInsets.symmetric(
//                     //         horizontal: 24, vertical: 12),
//                     //     shape: RoundedRectangleBorder(
//                     //       borderRadius: BorderRadius.circular(12),
//                     //     ),
//                     //   ),
//                     // ),
//                   ],
//                 ),
//               ),
//             ));
//   }
// }
