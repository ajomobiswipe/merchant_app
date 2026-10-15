import 'package:url_launcher/url_launcher.dart';

class ContactLauncher {
  const ContactLauncher._();

  static const privacyPolicyUrl =
      'https://alliancenetworkglobal.com/privacy-policy-mba/';

  static Future<bool> callPhone(String phoneNumber) {
    return _launch(Uri(scheme: 'tel', path: phoneNumber));
  }

  static Future<bool> sendEmail(String email) {
    return _launch(Uri(scheme: 'mailto', path: email));
  }

  static Future<bool> openPrivacyPolicy() {
    return openWebUrl(privacyPolicyUrl);
  }

  static Future<bool> openWebUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      return false;
    }

    return _launch(uri, skipCanLaunchCheck: true);
  }

  static Future<bool> _launch(
    Uri uri, {
    bool skipCanLaunchCheck = false,
  }) async {
    try {
      if (!skipCanLaunchCheck && !await canLaunchUrl(uri)) {
        return false;
      }

      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
