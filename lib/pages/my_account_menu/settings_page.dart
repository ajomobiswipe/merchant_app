// import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:icons_plus/icons_plus.dart';
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:provider/provider.dart';
// import 'package:sifr_latest/config/global.dart';
// import 'package:sifr_latest/storage/secure_storage.dart';
// import 'package:sifr_latest/theme/theme_provider.dart';
// import 'package:sifr_latest/widgets/app/alert_service.dart';

// import '../../config/app_color.dart';
// import '../../theme/app_themes.dart';
// import '../../widgets/app_widget/app_bar_widget.dart';

// class SettingsPage extends StatefulWidget {
//   const SettingsPage({Key? key}) : super(key: key);
//   @override
//   State<SettingsPage> createState() => _SettingsPageState();
// }

// class _SettingsPageState extends State<SettingsPage> {
//   late PackageInfo _packageInfo = PackageInfo(
//     appName: 'Unknown',
//     packageName: 'Unknown',
//     version: 'Unknown',
//     buildNumber: 'Unknown',
//     buildSignature: 'Unknown',
//   );

//   bool isDarkMode = false;

//   bool enableBioMetric = false;

//   BoxStorage boxStorage = BoxStorage();

//   @override
//   void initState() {
//     _initPackageInfo();
//     super.initState();
//   }

//   Future<void> _initPackageInfo() async {
//     final info = await PackageInfo.fromPlatform();
//     List check = await Global.availableBiometrics();
//     setState(() {
//       _packageInfo = info;
//       if (check.isEmpty) {
//         enableBioMetric = false;
//       } else {
//         enableBioMetric = boxStorage.get('isEnableBioMetric') ?? false;
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: const AppBarWidget(
//           title: "Settings",
//         ),
//         body: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//               child: Row(
//                 children: [
//                   Text("App Settings",
//                       style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                           ))
//                 ],
//               ),
//             ),
//             Expanded(
//               child: Consumer<ThemeProvider>(
//                 builder: (c, themeProvider, _) {
//                   return settings(themeProvider: themeProvider);
//                 },
//               ),
//             ),
//           ],
//         ));
//   }

//   settings({required ThemeProvider themeProvider}) {
//     List<String> themeMode = [
//       AppLocalizations.of(context)!.light.toString(),
//       AppLocalizations.of(context)!.dark.toString(),
//       AppLocalizations.of(context)!.system.toString()
//     ];
//     int themeValue = AppThemes.appThemeOptions.indexWhere(
//       (theme) => theme.mode == themeProvider.selectedThemeMode,
//     );

//     List<String> language = [
//       AppLocalizations.of(context)!.english.toString(),
//       AppLocalizations.of(context)!.arabic.toString(),
//     ];
//     String languageValue = themeProvider.currentLanguage;

//     List<Color> colorList = AppColors.primaryColorOptions;
//     int colorValue = AppColors.primaryColorOptions.indexWhere(
//       (theme) => theme == themeProvider.selectedPrimaryColor,
//     );

//     return ListView(
//         physics: const RangeMaintainingScrollPhysics(),
//         children: ListTile.divideTiles(context: context, tiles: [
//           ListTile(
//             leading: CircleAvatar(
//               backgroundColor: Theme.of(context).primaryColor,
//               child: Icon(
//                 themeValue == 1 ? LineAwesome.moon : LineAwesome.sun,
//                 color: Theme.of(context).iconTheme.color,
//               ),
//             ),
//             title: Text('Change Theme Mode',
//                 style: Theme.of(context)
//                     .textTheme
//                     .bodyLarge
//                     ?.copyWith(fontSize: 16, fontWeight: FontWeight.normal)),
//             trailing: DropdownButton(
//               underline: Container(), //make underline empty
//               value: themeMode[themeValue],
//               onChanged: (value) {
//                 // int mode = themeMode.indexOf(value!);
//                 themeProvider.setSelectedThemeMode(
//                   AppThemes.appThemeOptions[themeMode.indexOf(value!)].mode,
//                 );
//               },
//               items: themeMode.map((mode) {
//                 return DropdownMenuItem(
//                     value: mode.toString(), child: Text(mode));
//               }).toList(),
//             ),
//           ),
//           ListTile(
//             leading: CircleAvatar(
//               backgroundColor: Theme.of(context).primaryColor,
//               child: Icon(
//                 Icons.color_lens,
//                 color: Theme.of(context).iconTheme.color,
//               ),
//             ),
//             title: Text('Change Theme Color',
//                 style: Theme.of(context)
//                     .textTheme
//                     .bodyLarge
//                     ?.copyWith(fontSize: 16, fontWeight: FontWeight.normal)),
//             trailing: DropdownButton(
//               underline: Container(), //make underline empty
//               value: colorList[colorValue],
//               onChanged: (value) {
//                 themeProvider.setSelectedPrimaryColor(
//                   value!,
//                 );
//               },
//               items: colorList.map((colorCode) {
//                 return DropdownMenuItem(
//                     value: colorCode,
//                     child: Icon(Icons.circle, size: 30, color: colorCode));
//               }).toList(),
//             ),
//           ),
//           // TODO: THIS IS CLIENT CHOICE - NO DELETE THIS LINES
//           // ListTile(
//           //   leading: CircleAvatar(
//           //     backgroundColor: Theme.of(context).primaryColor,
//           //     child: Icon(
//           //       LineAwesome.language_solid,
//           //       color: Theme.of(context).iconTheme.color,
//           //     ),
//           //   ),
//           //   title: Text('Change Language',
//           //       style: Theme.of(context)
//           //           .textTheme
//           //           .bodyLarge
//           //           ?.copyWith(fontSize: 16, fontWeight: FontWeight.normal)),
//           //   trailing: DropdownButton(
//           //     underline: Container(),
//           //     value: language[languageValue == 'en' ? 0 : 1],
//           //     onChanged: (value) {
//           //       themeProvider
//           //           .setCurrentLanguage(value == 'English' ? 'en' : 'ar');
//           //     },
//           //     items: language.map((list) {
//           //       return DropdownMenuItem(value: list, child: Text(list));
//           //     }).toList(),
//           //   ),
//           //   // trailing: const Icon(Icons.keyboard_arrow_right),
//           // ),
//           GestureDetector(
//             onTap: () {
//               Navigator.pushNamed(context, 'aboutUs');
//             },
//             child: ListTile(
//               leading: CircleAvatar(
//                 backgroundColor: Theme.of(context).primaryColor,
//                 child: Icon(
//                   Icons.supervised_user_circle,
//                   color: Theme.of(context).iconTheme.color,
//                 ),
//               ),
//               title: Text('About Us',
//                   style: Theme.of(context)
//                       .textTheme
//                       .bodyLarge
//                       ?.copyWith(fontSize: 16, fontWeight: FontWeight.normal)),
//               trailing: const Icon(Icons.keyboard_arrow_right),
//             ),
//           ),
//           GestureDetector(
//             onTap: () async {
//               Navigator.pushNamed(context, 'license');
//             },
//             child: ListTile(
//               leading: CircleAvatar(
//                 backgroundColor: Theme.of(context).primaryColor,
//                 child: Icon(
//                   LineAwesome.file,
//                   color: Theme.of(context).iconTheme.color,
//                 ),
//               ),
//               title: Text('Software Licenses',
//                   style: Theme.of(context)
//                       .textTheme
//                       .bodyLarge
//                       ?.copyWith(fontSize: 16, fontWeight: FontWeight.normal)),
//               trailing: const Icon(Icons.keyboard_arrow_right),
//             ),
//           ),
//           ListTile(
//             leading: CircleAvatar(
//               backgroundColor: Theme.of(context).primaryColor,
//               child: Icon(
//                 LineAwesome.app_store,
//                 color: Theme.of(context).iconTheme.color,
//               ),
//             ),
//             title: Text('App Version',
//                 style: Theme.of(context)
//                     .textTheme
//                     .bodyLarge
//                     ?.copyWith(fontSize: 16, fontWeight: FontWeight.normal)),
//             trailing: Text(
//               _packageInfo.version.toString(),
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//           ),
//           ListTile(
//             leading: CircleAvatar(
//               backgroundColor: Theme.of(context).primaryColor,
//               child: Icon(
//                 LineAwesome.fingerprint_solid,
//                 color: Theme.of(context).iconTheme.color,
//               ),
//             ),
//             title: Text('Manage SIFR Security',
//                 style: Theme.of(context)
//                     .textTheme
//                     .bodyLarge
//                     ?.copyWith(fontSize: 16, fontWeight: FontWeight.normal)),
//             subtitle: Text(
//               'Use your existing phone lock to add an additional layer of security to your account.',
//               style: Theme.of(context)
//                   .textTheme
//                   .displaySmall
//                   ?.copyWith(fontSize: 10),
//             ),
//             trailing: Switch(
//                 activeColor: Theme.of(context).primaryColor,
//                 activeTrackColor:
//                     Theme.of(context).primaryColor.withOpacity(0.8),
//                 inactiveThumbColor: Colors.blueGrey.shade600,
//                 inactiveTrackColor: Colors.grey.shade400,
//                 splashRadius: 50.0,
//                 value: enableBioMetric,
//                 onChanged: (value) async {
//                   //if(kDebugMode)print(value);s
//                   var check = await Global.availableBiometrics();
//                   //if(kDebugMode)print(check);
//                   if (check.isNotEmpty) {
//                     var authentication = await Global.authenticate();
//                     //if(kDebugMode)print(authentication);
//                     if (authentication) {
//                       setState(() {
//                         enableBioMetric = value;
//                         boxStorage.save('isEnableBioMetric', value);
//                       });
//                     }
//                   } else {
//                     if (!mounted) return;
//                     AlertService().warn(context, 'Biometric not enabled',
//                         'Please enable and switched ON here');
//                   }
//                 }),
//           ),
//         ]).toList());
//   }
// }
