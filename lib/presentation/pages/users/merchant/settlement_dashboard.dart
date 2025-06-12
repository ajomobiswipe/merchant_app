import 'dart:async';

import 'package:anet_merchant_app/core/app_color.dart';
import 'package:anet_merchant_app/data/models/get_settlement_dashboard_data.dart';
import 'package:anet_merchant_app/main.dart';
import 'package:anet_merchant_app/presentation/pages/users/merchant/merchant_scaffold.dart';
import 'package:anet_merchant_app/presentation/providers/settlement_provider.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_container.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SettlementDashboard extends StatefulWidget {
  const SettlementDashboard({super.key});

  @override
  State<SettlementDashboard> createState() => _SettlementDashboardState();
}

class _SettlementDashboardState extends State<SettlementDashboard> {
  late SettlementProvider _settlementProvider;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _settlementProvider =
          Provider.of<SettlementProvider>(context, listen: false);
      _settlementProvider.allUtrWiseSettlementScrollCtrl.addListener(_onScroll);
      _settlementProvider.resetDashBoard();
      _settlementProvider.getSettlementDashboardReport();
    });
  }

  void _onScroll() {
    if (_debounce?.isActive ?? false) return;

    _debounce = Timer(const Duration(milliseconds: 300), () {
      final ctrl = _settlementProvider.allUtrWiseSettlementScrollCtrl;
      if (ctrl.position.pixels >= ctrl.position.maxScrollExtent &&
          !_settlementProvider.isAllUtrWiseSettlementLoading) {
        _settlementProvider.getSettlementDashboardReport();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _settlementProvider.allUtrWiseSettlementScrollCtrl
        .removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return MerchantScaffold(
      showStoreName: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer<SettlementProvider>(
            builder: (context, settlementProvider, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: screenHeight * 0.01,
                children: [
                  CustomTextWidget(text: "Total Settlements", size: 12),
                  CustomTextWidget(
                      text: settlementProvider.getFormattedDateRange(),
                      size: 12),
                  CustomContainer(
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
                  )
                ],
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: CustomTextWidget(text: "UTR Wise settlement", size: 12),
          ),
          Expanded(
            child: Consumer<SettlementProvider>(
              builder: (context, settlementProvider, child) {
                return (settlementProvider.isAllUtrWiseSettlementLoading &&
                        settlementProvider.utrWiseSettlements.isEmpty)
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : settlementProvider.utrWiseSettlements.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: CustomTextWidget(
                                text: "No settlements available",
                                size: 14,
                                color: AppColors.kPrimaryColor,
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: settlementProvider
                                .allUtrWiseSettlementScrollCtrl,
                            itemCount:
                                settlementProvider.utrWiseSettlements.length +
                                    1,
                            itemBuilder: (context, index) {
                              if (index <
                                  settlementProvider
                                      .utrWiseSettlements.length) {
                                final settlement = settlementProvider
                                    .utrWiseSettlements[index];

                                return settlementTile(
                                    settlementProvider,
                                    screenWidth,
                                    screenHeight,
                                    settlement,
                                    context);
                              } else if (settlementProvider
                                  .isAllUtrWiseSettlementLoading) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                );
                              } else {
                                return Center(
                                    child: Text(
                                        settlementProvider
                                                    .utrWiseSettlements.length >
                                                5
                                            ? "No more settlements !"
                                            : "",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                            fontStyle: FontStyle.italic)));
                              }
                            },
                          );
              },
            ),
          ),
        ],
      ),
      onTapHome: () {
        NavigationService.navigatorKey.currentState
            ?.pushNamedAndRemoveUntil('merchantHomeScreen', (route) => false);
      },
      onTapSupport: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, "merchantHelpScreen");
      },
    );
  }

  settlementTile(
      SettlementProvider settlementProvider,
      double screenWidth,
      double screenHeight,
      SettlementAggregatePageContent settlement,
      BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomContainer(
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
                    size: 10,
                    color: AppColors.black),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
