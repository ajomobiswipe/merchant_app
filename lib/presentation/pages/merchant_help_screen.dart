import 'package:anet_merchant_app/core/Constants/constants.dart';
import 'package:anet_merchant_app/core/app_color.dart';
import 'package:anet_merchant_app/core/utils/helpers/default_height.dart';
import 'package:anet_merchant_app/main.dart';
import 'package:anet_merchant_app/presentation/pages/merchant_scaffold.dart';
import 'package:anet_merchant_app/presentation/providers/authProvider.dart';
import 'package:anet_merchant_app/presentation/providers/support_action_provider.dart';
import 'package:anet_merchant_app/presentation/widgets/app/alert_service.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_container.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_text_widget.dart';
import 'package:anet_merchant_app/presentation/widgets/form_field/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class MerchantHelpScreen extends StatefulWidget {
  const MerchantHelpScreen({super.key});

  @override
  State<MerchantHelpScreen> createState() => _MerchantHelpScreenState();
}

class _MerchantHelpScreenState extends State<MerchantHelpScreen> {
  late SupportActionProvider supportActionProvider;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      supportActionProvider =
          Provider.of<SupportActionProvider>(context, listen: false);
      supportActionProvider.getSupportActionData();
    });
  }

  Future<void> _copyToClipboard(String mailId) async {
    Clipboard.setData(ClipboardData(text: mailId));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$mailId Copied to clipboard'),
        duration: Duration(seconds: 5)));
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return MerchantScaffold(
      child: Column(
        children: [
          Center(
            child: Image.asset(
              "assets/screen/anet.png",
              height: screenHeight * 0.1,
              width: screenWidth * 0.4,
            ),
          ),
          Row(
            children: [
              SizedBox(
                width: screenWidth * 0.6,
                child: CustomTextWidget(
                  size: 14,
                  text: Provider.of<AuthProvider>(context).merchantDbaName,
                  maxLines: 3,
                ),
              ),
            ],
          ),
          defaultHeight(screenHeight * 0.05),
          Consumer<SupportActionProvider>(
            builder: (context, provider, child) {
              if (provider.supportActionList.isEmpty) {
                return const CircularProgressIndicator();
              }
              return DropdownButtonFormField<dynamic>(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                isDense: true,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.kPrimaryColor,
                ),
                decoration: commonInputDecoration(
                  hintText: "select one",
                  Icons.maps_home_work_outlined,
                ),
                value: provider.selectedQuickAction,
                items: provider.supportActionList.map((action) {
                  return DropdownMenuItem<String>(
                    value: action['quickActionMessage'],
                    child: CustomTextWidget(text: action['quickActionMessage']),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    provider.selectedQuickAction = newValue;
                    supportActionProvider.selectedSupportAction =
                        newValue; // Update the provider with the selected value
                  });
                },
              );
            },
          ),
          Spacer(),
          Row(
            children: [
              Image.asset(
                "assets/screen/help_desk.png",
                height: 60,
              ),
              defaultWidth(screenWidth * 0.05),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextWidget(
                    text: "We are here to help!",
                    size: 18,
                  ),
                  CustomTextWidget(
                      text: "Raise Your Concern and get your \nissue resolved"),
                ],
              )
            ],
          ),
          Spacer(),
          Consumer<SupportActionProvider>(
            builder: (context, provider, child) {
              if (provider.isSupportActionsTaped) {
                return Shimmer.fromColors(
                  baseColor: Colors.blue[300]!,
                  highlightColor: Colors.blue[100]!,
                  child: CustomContainer(
                    color: Color.fromARGB(255, 165, 162, 138),
                    height: screenHeight * 0.07,
                    child: CustomTextWidget(
                      text: "Loading...",
                      color: Colors.white,
                    ),
                  ),
                );
              } else {
                return CustomContainer(
                  color: Color.fromARGB(255, 165, 162, 138),
                  height: screenHeight * 0.07,
                  child: CustomTextWidget(
                    text: "Raise a request",
                    color: Colors.white,
                  ),
                  onTap: () {
                    if (supportActionProvider.selectedQuickAction == null ||
                        supportActionProvider.selectedQuickAction!.isEmpty) {
                      AlertService().error(
                        "Please select a support action first!",
                      );
                      return;
                    }
                    supportActionProvider.raiseSupportRequest();
                  },
                );
              }
            },
          ),
          Spacer(),
          CustomContainer(
            padding: EdgeInsets.symmetric(horizontal: 10),
            color: Color.fromARGB(255, 165, 162, 138),
            child: Column(
              children: [
                defaultHeight(10),
                CustomTextWidget(text: "Contact us:"),
                InkWell(
                  onTap: () async {
                    final Uri phoneUri =
                        Uri(scheme: 'tel', path: '+911203129301');
                    if (await canLaunchUrl(phoneUri)) {
                      await launchUrl(phoneUri);
                    } else {
                      // Handle error
                    }
                  },
                  child: Row(
                    children: [
                      connectWithOptions(
                        icon: const Icon(
                          Icons.phone,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                      defaultWidth(5),
                      CustomTextWidget(
                          text: "+911203129301",
                          size: 14,
                          color: AppColors.black50,
                          fontWeight: FontWeight.w400),
                      const Spacer(
                        flex: 4,
                      ),
                    ],
                  ),
                ),
                defaultHeight(10),
                InkWell(
                  onTap: () async {
                    final mail = Constants.supportEmail;

                    final Uri emailUri = Uri(
                      scheme: 'mailto',
                      path: mail,
                      query: 'subject=Support Request', // optional
                    );

                    if (await canLaunchUrl(emailUri)) {
                      try {
                        await launchUrl(emailUri);
                      } catch (error) {
                        _copyToClipboard(mail);
                      }
                    } else {
                      // Handle error
                      _copyToClipboard(mail);
                    }
                  },
                  child: Row(
                    children: [
                      connectWithOptions(
                        icon: const Icon(
                          size: 20,
                          Icons.email_outlined,
                          color: Colors.white,
                        ),
                      ),
                      defaultWidth(5),
                      CustomTextWidget(
                          text: Constants.supportEmail,
                          size: 13,
                          color: AppColors.black50,
                          fontWeight: FontWeight.w400),
                      const Spacer(
                        flex: 4,
                      ),
                    ],
                  ),
                ),
                defaultHeight(10),
              ],
            ),
          )
        ],
      ),
      onTapHome: () {
        NavigationService.navigatorKey.currentState
            ?.pushNamedAndRemoveUntil('merchantHomeScreen', (route) => false);
      },
    );
  }

  Column connectWithOptions({required Widget icon, Function()? onTap}) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: icon,
        ),
      ],
    );
  }
}
