import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/app_widget/app_bar_widget.dart';

class LicenseList extends StatefulWidget {
  const LicenseList({Key? key}) : super(key: key);

  @override
  State<LicenseList> createState() => _LicenseListState();
}

class _LicenseListState extends State<LicenseList> {
  List licenseArray = [
    {
      'name': "local_auth",
      'git_url':
          "https://github.com/flutter/plugins/tree/main/packages/local_auth/local_auth"
    },
    {
      'name': "secure_application",
      'git_url': "https://github.com/neckaros/secure_application"
    },
    {
      'name': "flutter_secure_storage",
      'git_url':
          "https://github.com/mogol/flutter_secure_storage/tree/develop/flutter_secure_storage"
    },
    {
      'name': "connectivity_plus",
      'git_url':
          "https://github.com/fluttercommunity/plus_plugins/tree/main/packages/"
    },
    {
      'name': "shared_preferences",
      'git_url':
          "https://github.com/flutter/plugins/tree/main/packages/shared_preferences/shared_preferences"
    },
    {'name': "provider", 'git_url': "https://github.com/rrousselGit/provider"},
    {
      'name': "flutter_localization",
      'git_url': "https://github.com/channdara/flutter_localization"
    },
    {'name': "intl", 'git_url': "https://github.com/dart-lang/intl"},
    {
      'name': "hive_flutter",
      'git_url': "https://github.com/hivedb/hive/tree/master/hive_flutter"
    },
    {'name': "get_it", 'git_url': "https://github.com/fluttercommunity/get_it"},
    {
      'name': "google_fonts",
      'git_url':
          "https://github.com/material-foundation/flutter-packages/tree/main/packages/google_fonts"
    },
    {
      'name': "awesome_snackbar_content",
      'git_url': "https://github.com/mhmzdev/awesome_snackbar_content"
    },
    {'name': "accordion", 'git_url': "https://github.com/GotJimmy/accordion"},
    {
      'name': "line_awesome_flutter",
      'git_url': "https://github.com/clean/line_awesome_flutter"
    },
    {
      'name': "flutter_custom_carousel_slider",
      'git_url': "https://github.com/coskuncay/flutter_custom_carousel_slider"
    },
    {
      'name': "flutter_swipe_button",
      'git_url': "https://github.com/savadmv/swipe_button_flutter"
    },
    {
      'name': "page_transition",
      'git_url': "https://github.com/kalismeras61/flutter_page_transition"
    },
    {
      'name': "open_mail_app",
      'git_url': "https://github.com/HomeX-It/open-mail-app-flutter"
    },
    {'name': "lottie", 'git_url': "https://github.com/xvrh/lottie-flutter"},
    {
      'name': "otp_text_field",
      'git_url': "https://github.com/iamvivekkaushik/OTPTextField"
    },
    {
      'name': "dropdown_search",
      'git_url': "https://github.com/salim-lachdhaf/searchable_dropdown"
    },
    {
      'name': "intl_phone_field",
      'git_url': "https://github.com/vanshg395/intl_phone_field"
    },
    {
      'name': "location",
      'git_url': "https://github.com/Lyokone/flutterlocation"
    },
    {
      'name': "google_maps_flutter",
      'git_url':
          "https://github.com/flutter/plugins/tree/main/packages/google_maps_flutter/google_maps_flutter"
    },
    {
      'name': "geocoding",
      'git_url':
          "https://github.com/baseflow/flutter-geocoding/tree/master/geocoding"
    },
    {
      'name': "permission_handler",
      'git_url': "https://github.com/baseflow/flutter-permission-handler"
    },
    {
      'name': "flutter_otp_text_field",
      'git_url': "https://github.com/david-legend/otp_textfield"
    },
    {
      'name': "loading_animation_widget",
      'git_url': "https://github.com/watery-desert/loading_animation_widget"
    },
    {'name': "qr_flutter", 'git_url': "https://github.com/theyakka/qr.flutter"},
    {
      'name': "icons_plus",
      'git_url': "https://github.com/chouhan-rahul/icons_plus"
    },
    {
      'name': "adaptive_dialog",
      'git_url': "https://github.com/mono0926/adaptive_dialog"
    },
    {
      'name': "custom_timer",
      'git_url': "https://github.com/federicodesia/custom_timer"
    },
    {
      'name': "awesome_card",
      'git_url': "https://github.com/iamvivekkaushik/AwesomeCard"
    },
    {
      'name': "credit_card_validator",
      'git_url': "https://github.com/cholojuanito/credit_card_validator"
    },
    {
      'name': "credit_card_scanner",
      'git_url': "https://github.com/nateshmbhat/card-scanner-flutter"
    },
    {
      'name': "dotted_border",
      'git_url': "https://github.com/ajilo297/Flutter-Dotted-Border"
    },
    {
      'name': "file_picker",
      'git_url': "https://github.com/miguelpruivo/flutter_file_picker"
    },
    {
      'name': "image_cropper",
      'git_url': "https://github.com/hnvn/flutter_image_cropper"
    },
    {
      'name': "image_picker",
      'git_url':
          "https://github.com/flutter/plugins/tree/main/packages/image_picker/image_picker"
    },
    {
      'name': "http",
      'git_url': "https://github.com/dart-lang/http/tree/master/pkgs/http"
    },
    {
      'name': "fdottedline_nullsafety",
      'git_url': "https://github.com/mdddj/fdottedline"
    },
    {
      'name': "flutter_html_to_pdf",
      'git_url': "https://github.com/Afur/flutter_html_to_pdf"
    },
    {
      'name': "open_file_plus",
      'git_url': "https://github.com/joutvhu/open_file_plus"
    },
    {'name': "path", 'git_url': "https://github.com/dart-lang/path"},
    {
      'name': "path_provider",
      'git_url':
          "https://github.com/flutter/plugins/tree/main/packages/path_provider/path_provider"
    },
    {
      'name': "grouped_list",
      'git_url': "https://github.com/Dimibe/grouped_list"
    },
    {'name': "badges", 'git_url': "https://github.com/yako-dev/flutter_badges"},
    {
      'name': "modal_bottom_sheet",
      'git_url': "https://github.com/jamesblasco/modal_bottom_sheet"
    },
    {
      'name': "tbib_splash_screen",
      'git_url': "https://github.com/the-best-is-best/tbib_splash_screen"
    },
    {
      'name': "package_info_plus",
      'git_url':
          "https://github.com/fluttercommunity/plus_plugins/tree/main/packages/"
    },
    {
      'name': "flutter_colorpicker",
      'git_url': "https://github.com/mchome/flutter_colorpicker"
    },
    {'name': "pinput", 'git_url': "https://github.com/Tkko/Flutter_PinPut"},
    {
      'name': "flutter_pin_code_widget",
      'git_url':
          "https://github.com/AgoraDesk-LocalMonero/flutter-pin-code-widget"
    },
    {
      'name': "geolocator",
      'git_url':
          "https://github.com/baseflow/flutter-geolocator/tree/main/geolocator"
    },
    {
      'name': "flutter_toggle_tab",
      'git_url': "https://github.com/Lzyct/flutter_toggle_tab"
    },
    {
      'name': "popup_banner",
      'git_url': "https://github.com/yusriltakeuchi/popup_banner"
    },
    {
      'name': "cached_network_image",
      'git_url': "https://github.com/Baseflow/flutter_cached_network_image"
    },
    {
      'name': "flutter_image_compress",
      'git_url': "https://github.com/fluttercandies/flutter_image_compress"
    },
    {
      'name': "custom_info_window",
      'git_url': "https://github.com/abhishekduhoon/custom_info_window"
    },
    {
      'name': "chips_choice_null_safety",
      'git_url': "https://github.com/JoseBarreto1/chips_choice_null_safety"
    },
    {
      'name': "url_launcher",
      'git_url':
          "https://github.com/flutter/plugins/tree/main/packages/url_launcher/url_launcher"
    },
    {'name': "majascan", 'git_url': "https://pub.dev/packages/majascan"},
    {
      'name': "cupertino_icons",
      'git_url':
          "https://github.com/flutter/packages/tree/main/third_party/packages/cupertino_icons"
    },
    {
      'name': "flutter_lints",
      'git_url':
          "https://github.com/flutter/packages/tree/main/packages/flutter_lints"
    },
    {
      'name': "flutter_launcher_icons",
      'git_url': "https://github.com/fluttercommunity/flutter_launcher_icons/"
    },
    {
      'name': "timelines",
      'git_url': "https://github.com/chulwoo-park/timelines/"
    }
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(
        title: "Software License",
      ),
      body: ListView.builder(
        itemCount: licenseArray.length,
        itemBuilder: (context, index) {
          return Column(
            children: <Widget>[
              GestureDetector(
                onTap: () async {
                  await launchUrl(Uri.parse(licenseArray[index]['git_url']),
                      mode: LaunchMode.externalApplication);
                },
                child: ListTile(
                  leading: const Icon(Icons.settings),
                  title: Text(licenseArray[index]['name']),
                ),
              ),
              const Divider(), //                           <-- Divider
            ],
          );
        },
      ),
    );
  }
}
