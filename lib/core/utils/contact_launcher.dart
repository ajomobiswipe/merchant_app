import 'package:url_launcher/url_launcher.dart';

class ContactLauncher {
  const ContactLauncher._();

  static Future<bool> callPhone(String phoneNumber) {
    return _launch(Uri(scheme: 'tel', path: phoneNumber));
  }

  static Future<bool> sendEmail(String email) {
    return _launch(Uri(scheme: 'mailto', path: email));
  }

  static Future<bool> _launch(Uri uri) async {
    if (!await canLaunchUrl(uri)) {
      return false;
    }

    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
