import 'package:flutter/material.dart';
import 'package:anet_merchants/core/common/app_colors.dart';
import 'package:anet_merchants/core/common/app_text_style.dart';
import 'package:anet_merchants/core/localization/app_language.dart';
import 'package:anet_merchants/core/services/connectivity_controller.dart';

class ConnectivityBlocker extends StatelessWidget {
  final Widget child;

  const ConnectivityBlocker({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: connectivityController,
      builder: (context, _) {
        return Stack(
          children: [
            child,
            if (!connectivityController.hasInternet) ...[
              const ModalBarrier(
                dismissible: false,
                color: Colors.black54,
              ),
              Positioned.fill(
                child: SafeArea(
                  child: Center(
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primaryPurple),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.wifi_off_rounded,
                            color: AppColors.primaryPurple,
                            size: 48,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            context.tr('no_internet_title'),
                            textAlign: TextAlign.center,
                            style: AppTextStyle.h3.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.tr('no_internet_message'),
                            textAlign: TextAlign.center,
                            style: AppTextStyle.h5.copyWith(
                              color: Theme.of(context).hintColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
