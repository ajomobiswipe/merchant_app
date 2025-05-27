import 'package:anet_merchant_app/core/app_color.dart';
import 'package:anet_merchant_app/data/models/get_settlement_dashboard_data.dart';
import 'package:anet_merchant_app/presentation/pages/users/merchant/merchant_scaffold.dart';
import 'package:anet_merchant_app/presentation/providers/settlement_provider.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_container.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class SettlementDashboard extends StatefulWidget {
  const SettlementDashboard({super.key});

  @override
  State<SettlementDashboard> createState() => _SettlementDashboardState();
}

class _SettlementDashboardState extends State<SettlementDashboard> {
  late SettlementProvider _settlementProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _settlementProvider =
          Provider.of<SettlementProvider>(context, listen: false);
      _settlementProvider.getSettlementDashboardReport();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return MerchantScaffold(
      child: Consumer<SettlementProvider>(
        builder: (context, settlementProvider, child) {
          return ListView(
            children: [
              settlementProvider.isLoading
                  ? Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: CustomTextWidget(text: "Loading...", size: 18),
                    )
                  : CustomTextWidget(
                      text: settlementProvider.storeName ?? "N/A", size: 18),
              CustomTextWidget(text: "Total Settlements", size: 12),
              settlementProvider.isLoading
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
                          CustomTextWidget(
                              text: "Total Amount settled", size: 12),
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
                                          "${settlementProvider.totalSettlement} Settlements | ${settlementProvider.totalTransactions} Transactions",
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
              settlementProvider.isLoading
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
                      itemCount: settlementProvider.utrWiseSettlements.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        final settlement =
                            settlementProvider.utrWiseSettlements[index];

                        return settlementTile(settlementProvider, screenWidth,
                            screenHeight, settlement, context);
                      },
                    ),
            ],
          );
        },
      ),
      onTapHome: () {
        Navigator.pop(context);
      },
      onTapSupport: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, "merchantHelpScreen");
      },
    );
  }

  CustomContainer settlementTile(
      SettlementProvider settlementProvider,
      double screenWidth,
      double screenHeight,
      SettlementAggregate settlement,
      BuildContext context) {
    return CustomContainer(
      onTap: () {
        settlementProvider.setSelectedSettlementAggregate(settlement);
        Navigator.pushNamed(
          context,
          "viewSettlementInfo",
          arguments: settlement,
        );
      },
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05, vertical: screenHeight * 0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextWidget(
                  text: "₹ ${settlement.grossTransactionAmount ?? 0}",
                  size: 18),
              CustomTextWidget(
                  text: "${settlement.transactionCount ?? 0} Transactions ",
                  size: 12),
              CustomTextWidget(
                  text:
                      "UTR : ${settlement.utr ?? 'N/A'} | Settled on ${settlement.tranDate != null ? DateFormat('dd MMM yyyy').format(settlement.tranDate!) : 'N/A'}",
                  size: 12,
                  color: AppColors.black),
            ],
          ),
        ],
      ),
    );
  }
}
