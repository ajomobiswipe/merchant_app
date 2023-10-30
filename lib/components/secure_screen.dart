import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:secure_application/secure_application.dart';
import 'package:sifr_latest/pages/pages.dart';

class SecureScreen extends StatefulWidget {
  const SecureScreen({Key? key}) : super(key: key);

  @override
  State<SecureScreen> createState() => _SecureScreenState();
}

class _SecureScreenState extends State<SecureScreen> {
  LocalAuthentication auth = LocalAuthentication();

  void localAuthentication(SecureApplicationController? secureNotifier,
      BuildContext? context) async {
    bool canCheckBiometrics = false;
    List<BiometricType>? availableBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } catch (e) {
      debugPrint('Error caught with biometrics: $e');
    }
    debugPrint('Biometric is available: $canCheckBiometrics');

    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Error caught while enumerating biometrics: $e');
    }
    debugPrint('The following biometrics are available');
    if (availableBiometrics!.isNotEmpty) {
      for (var ab in availableBiometrics) {
        debugPrint('\ttech: $ab');
      }
    } else {
      debugPrint('No biometrics are available');
      Navigator.pushAndRemoveUntil(context!,
          MaterialPageRoute(builder: (BuildContext context) {
        return const SplashScreen();
      }), (route) => false);
      // Navigator.pushAndRemoveUntil (context, MaterialPageRoute(builder: (BuildContext context) { return HomeScreen () ;
      //   ]), (route) => false,);
    }

    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Touch your finger on the sensor to login',
        options:
            const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );
    } catch (e) {
      debugPrint('Error caught while using biometric auth: $e');
    }

    if (secureNotifier != null) {
      authenticated
          ? secureNotifier.authSuccess(unlock: true)
          : debugPrint('fail');
    } else if (context != null) {
      authenticated
          ? SecureApplicationProvider.of(context)?.secure()
          : debugPrint('fail');
    }
  }

  Widget lockedScreen(Function()? function) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 40),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Unlock Secure App',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const Text(
                'Unlock your screen by pressing the fingerprint icon on the bottom of the screen and then using your fingerprint sensor.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              IconButton(
                onPressed: function,
                icon: const Icon(Icons.fingerprint),
                iconSize: 50,
                color: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SecureApplication(
      nativeRemoveDelay: 100,
      autoUnlockNative: true,
      child: SecureGate(
        lockedBuilder: (context, secureNotifier) => Center(
          child: lockedScreen(() => localAuthentication(secureNotifier, null)),
        ),
        child: Builder(
          builder: (context) {
            return ValueListenableBuilder<SecureApplicationState>(
                valueListenable: SecureApplicationProvider.of(context)
                    as ValueListenable<SecureApplicationState>,
                builder: (context, state, _) => state.secured
                    ? const SplashScreen()
                    : lockedScreen(() => localAuthentication(null, context)));
          },
        ),
      ),
    );
  }
}
