import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:anet_merchant_app/config/config.dart';
import 'package:anet_merchant_app/pages/users/merchant/merchant_scaffold.dart';
import 'package:anet_merchant_app/pages/users/merchant/providers/settlement_provider.dart';
import 'package:anet_merchant_app/pages/users/merchant/widgets/custom_container.dart';
import 'package:anet_merchant_app/widgets/custom_text_widget.dart';

class SettlementDashboard extends StatelessWidget {
  const SettlementDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final settlementProvider = context.watch<SettlementProvider>();

    bool isLoading = settlementProvider == null ||
        settlementProvider.totalSettlementAmount == null ||
        settlementProvider.utrWiseSettlements == null;

    return MerchantScaffold(
      child: ListView(
        children: [
          isLoading
              ? Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: CustomTextWidget(text: "Loading...", size: 18),
                )
              : CustomTextWidget(
                  text: settlementProvider.storeName ?? "N/A", size: 18),
          CustomTextWidget(text: "Total Settlements", size: 12),
          isLoading
              ? Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: CustomContainer(
                    height: screenHeight * 0.14,
                    color: AppColors.kLightGreen,
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                        vertical: screenHeight * 0.02),
                    child: Container(),
                  ),
                )
              : CustomContainer(
                  height: screenHeight * 0.14,
                  color: AppColors.kLightGreen,
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenHeight * 0.02),
                  child: Column(
                    children: [
                      CustomTextWidget(text: "Total Amount settled", size: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextWidget(
                                  text:
                                      "₹ ${settlementProvider.totalSettlementAmount ?? 0}",
                                  size: 18),
                              CustomTextWidget(
                                  text: "Total Settlements",
                                  size: 12,
                                  color: AppColors.black),
                              CustomTextWidget(
                                  text:
                                      "${settlementProvider.totalSettlementAmount ?? 0} Settlements | ${settlementProvider.totalTransactions ?? 0} Transactions",
                                  size: 12),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.black,
                            ),
                            padding: const EdgeInsets.all(12.0),
                            child: Center(
                              child: CustomTextWidget(
                                  text: "₹",
                                  color: AppColors.grayDark,
                                  size: 30),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
          CustomTextWidget(text: "UTR Wise settlement", size: 12),
          isLoading
              ? Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: ListView.separated(
                    separatorBuilder: (context, index) => SizedBox(
                      height: screenHeight * 0.02,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 3, // Placeholder count
                    itemBuilder: (context, index) {
                      return CustomContainer(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.05,
                            vertical: screenHeight * 0.02),
                        child: Container(),
                      );
                    },
                  ),
                )
              : ListView.separated(
                  separatorBuilder: (context, index) => SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: settlementProvider.utrWiseSettlements?.length ?? 0,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                    final settlement =
                        settlementProvider.utrWiseSettlements[index];
                    return settlementTile(
                        screenWidth, screenHeight, settlement);
                  },
                ),
        ],
      ),
    );
  }

  CustomContainer settlementTile(double screenWidth, double screenHeight,
      Map<String, dynamic> settlement) {
    return CustomContainer(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05, vertical: screenHeight * 0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextWidget(
                  text: "₹ ${settlement['amount'] ?? 0}", size: 18),
              CustomTextWidget(
                  text:
                      "${settlement['settlements'] ?? 0} Settlements | ${settlement['transactions'] ?? 0} Transactions",
                  size: 12),
              CustomTextWidget(
                  text:
                      "UTR : ${settlement['utr'] ?? 'N/A'} | Settled on ${settlement['settledOn'] ?? 'N/A'}",
                  size: 12,
                  color: AppColors.black),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.black,
            ),
            padding: const EdgeInsets.all(12.0),
            child: Center(
              child: CustomTextWidget(
                  text: "₹", color: AppColors.grayDark, size: 30),
            ),
          ),
        ],
      ),
    );
  }
}
