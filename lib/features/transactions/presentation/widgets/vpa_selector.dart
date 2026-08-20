import 'package:flutter/material.dart';
import 'package:anet_merchants/core/common/app_colors.dart';
import 'package:anet_merchants/core/common/app_text_style.dart';

class VpaSelector extends StatelessWidget {
  final List<String> vpas;
  final String? selectedVpa;
  final bool isLoading;
  final Color? iconColor;
  final ValueChanged<String?>? onChanged;

  const VpaSelector({
    super.key,
    this.vpas = const [],
    this.selectedVpa,
    this.isLoading = false,
    this.iconColor,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      decoration: BoxDecoration(
        color: context.appSurfaceAlt,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Icon(
            Icons.qr_code_2_rounded,
            color: iconColor ?? AppColors.primaryPurple,
            size: 34,
          ),
          const SizedBox(width: 18),
          Expanded(
            child: isLoading
                ? Text(
                    'Loading VPA devices...',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.h4.copyWith(
                      color: context.appTextPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedVpa,
                      isExpanded: true,
                      icon: const SizedBox.shrink(),
                      hint: Text(
                        'No VPA devices available',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.h4.copyWith(
                          color: context.appTextPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      items: vpas
                          .map(
                            (vpa) => DropdownMenuItem<String>(
                              value: vpa,
                              child: Text(
                                vpa,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyle.h4.copyWith(
                                  color: context.appTextPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: vpas.isEmpty ? null : onChanged,
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: iconColor ?? AppColors.primaryPurple,
            size: 34,
          ),
        ],
      ),
    );
  }
}
