import 'package:flutter/material.dart';
import 'package:anet_merchant_app/config/app_color.dart';
import 'package:anet_merchant_app/widgets/custom_text_widget.dart';

Future<void> alertPopup(
    {required BuildContext context,
    required String title,
    required List<KycResponseFelids> infos,
    required Function() onConfirm}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          var screenWidth = MediaQuery.of(context).size.width;
          return Dialog(
            insetPadding: EdgeInsets.zero,
            backgroundColor: Colors.white,
            shadowColor: Colors.white,
            surfaceTintColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * .9,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Stack(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextWidget(
                        text: title,
                        size: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.kPrimaryColor,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Column(
                          children: infos.map((item) {
                        return item.fieldsKey != null && item.fieldValue != null
                            ? item.fieldsKey != '' && item.fieldValue != ''
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: CustomTextWidget(
                                            text: item.fieldsKey!,
                                            size: 11,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        const CustomTextWidget(
                                          text: ":  ",
                                          size: 11,
                                          fontWeight: FontWeight.w900,
                                        ),
                                        Expanded(
                                          child: CustomTextWidget(
                                            text: "${item.fieldValue}",
                                            size: 11,
                                            fontWeight: FontWeight.w900,
                                            maxLines: 5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container()
                            : Container();
                      }).toList()),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          PopupButton(
                            onTap: () {
                              onConfirm();
                              Navigator.pop(context);
                            },
                            title: "Reverify ",
                            width: screenWidth * 0.35,
                            color: AppColors.kPrimaryColor,
                          ),
                          PopupButton(
                            title: "OK ",
                            width: screenWidth * 0.35,
                            color: AppColors.kLightGreen,
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: InkWell(
                      child: const Icon(
                        Icons.cancel_outlined,
                        color: Colors.red,
                        size: 30,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

class PopupButton extends StatelessWidget {
  final Function()? onTap;
  final String title;
  final Color? color;
  final double width;

  const PopupButton({
    super.key,
    this.onTap,
    required this.title,
    required this.width,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: EdgeInsets.all(12.0),
        child: Center(
          child: CustomTextWidget(
            text: title,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}

class KycResponseFelids {
  final String? fieldsKey;
  final String? fieldValue;

  KycResponseFelids({required this.fieldsKey, required this.fieldValue});
}
