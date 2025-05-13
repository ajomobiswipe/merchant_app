import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anet_merchant_app/config/config.dart';
import 'package:anet_merchant_app/helpers/default_height.dart';
import 'package:anet_merchant_app/pages/users/merchant/merchant_scaffold.dart';
import 'package:anet_merchant_app/pages/users/merchant/providers/merchant_home_screen_provider.dart';
import 'package:anet_merchant_app/pages/users/merchant/models/transaction_model.dart';
import 'package:anet_merchant_app/pages/users/merchant/widgets/custom_container.dart';
import 'package:anet_merchant_app/pages/users/merchant/widgets/transaction_tile.dart';
import 'package:anet_merchant_app/widgets/custom_text_widget.dart';

class MerchantHomeScreen extends StatelessWidget {
  const MerchantHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        double screenHeight = MediaQuery.of(context).size.height;
        double screenWidth = MediaQuery.of(context).size.width;
        return MerchantScaffold(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextWidget(
                  text: context.read<MerchantProvider>().storeName, size: 18),
              defaultHeight(screenHeight*.015),
              CustomTextWidget(text: "Total transactions today", size: 12),
               defaultHeight(screenHeight*.015),
              Selector<MerchantProvider, HomeScreenTabItem>(
                selector: (context, provider) =>
                    provider.selectedTab, // Listen only to selectedTab
                builder: (context, selectedTab, child) {
                  switch (selectedTab) {
                    case HomeScreenTabItem.TransactionHistory:
                      return CustomContainer(
                        height: screenHeight * 0.06,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomTextWidget(
                                color: Colors.white,
                                text: context
                                    .read<MerchantProvider>()
                                    .totalTransactions
                                    .toString(),
                                size: 18),
                            CustomTextWidget(
                                text: "₹ 2578744",
                                size: 18,
                                color: Colors.white),
                          ],
                        ),
                      );
                    case HomeScreenTabItem.Settlements:
                      return CustomContainer(
                        height: screenHeight * 0.06,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CustomTextWidget(
                                text:
                                    "₹ ${context.read<MerchantProvider>().totalSettlementAmount}",
                                size: 18,
                                color: Colors.white), //totalSettlementAmount
                          ],
                        ),
                      );
                    case HomeScreenTabItem.Mpr:
                      return Container();
                  }
                },
              ),
               defaultHeight(screenHeight*.015),
              Consumer<MerchantProvider>(
                builder: (context, provider, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      homeScreenTab(
                        screenHeight,
                        width: screenWidth * 0.25,
                        homeScreenTabItem: HomeScreenTabItem.TransactionHistory,
                        selectedTabItem: provider.selectedTab,
                        onTap: () => provider.updateSelectedTab(
                            HomeScreenTabItem.TransactionHistory),
                        title: "Transaction\nHistory",
                      ),
                      homeScreenTab(
                        screenHeight,
                        width: screenWidth * 0.25,
                        homeScreenTabItem: HomeScreenTabItem.Settlements,
                        selectedTabItem: provider.selectedTab,
                        onTap: () => provider
                            .updateSelectedTab(HomeScreenTabItem.Settlements),
                        title: "Settlements",
                      ),
                      homeScreenTab(
                        screenHeight,
                        width: screenWidth * 0.25,
                        homeScreenTabItem: HomeScreenTabItem.Mpr,
                        selectedTabItem: provider.selectedTab,
                        onTap: () =>
                            provider.updateSelectedTab(HomeScreenTabItem.Mpr),
                        title: "MPR",
                      ),
                    ],
                  );
                },
              ),

              defaultHeight(screenHeight*.015),

              // **Dynamic Content Based on Selected Tab**
              Expanded(
                child: Consumer<MerchantProvider>(
                  builder: (context, provider, child) {
                    return getTabContent(
                        merchantProvider: provider,
                        screenWidth: screenWidth,
                        screenHeight: screenHeight);
                  },
                ),
              ),
              Selector<MerchantProvider, HomeScreenTabItem>(
                  selector: (context, provider) =>
                      provider.selectedTab, // Listen only to selectedTab
                  builder: (context, selectedTab, child) {
                    return getBottomButton(
                        selectedTab: selectedTab,
                        screenHeight: screenHeight,
                        context: context);
                  })
            ],
          ),
          onTapSupport: () {
            Navigator.pushNamed(context, "merchantHelpScreen");
          },
        );
      },
    );
  }

  getBottomButton(
      {required HomeScreenTabItem selectedTab,
      required double screenHeight,
      required BuildContext context}) {
    switch (selectedTab) {
      case HomeScreenTabItem.TransactionHistory:
        return CustomContainer(
          onTap: () {
            Navigator.pushNamed(context, "merchantTransactionFilterScreen");
          },
          height: screenHeight * 0.06,
          child: CustomTextWidget(
            text: "View All transactions",
            color: AppColors.gray,
          ),
        );
      case HomeScreenTabItem.Settlements:
        return CustomContainer(
          onTap: () {
            Navigator.pushNamed(context, "merchantStatementFilterScreen");
          },
          height: screenHeight * 0.06,
          child: CustomTextWidget(
            text: "View All Settlements",
            color: AppColors.gray,
          ),
        );
      case HomeScreenTabItem.Mpr:
        return Container();
    }
  }

  /// **Function to Return Content Based on Selected Tab**
  Widget getTabContent(
      {required MerchantProvider merchantProvider,
      required double screenWidth,
      required double screenHeight}) {
    switch (merchantProvider.selectedTab) {
      case HomeScreenTabItem.TransactionHistory:
        return transactionHistoryList(
            transactionElement: merchantProvider.transactions ?? [],
            screenWidth: screenWidth);
      case HomeScreenTabItem.Settlements:
        return settlementsList(
            screenWidth: screenWidth, screenHeight: screenHeight);
      case HomeScreenTabItem.Mpr:
        return mprList();
    }
  }

  /// **Transaction History List**
  Widget transactionHistoryList(
      {required List<TransactionElement> transactionElement,
      required double screenWidth}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        children: [
          CustomTextWidget(text: "Recent transactions", size: 14),
          Icon(Icons.sync, color: AppColors.kPrimaryColor, size: 20),
        ],
      ),
      defaultHeight(10),
      Expanded(
        child: ListView.builder(
          itemCount: transactionElement.length,
          itemBuilder: (context, index) => TransactionTile(
            transaction: transactionElement[index],
            width: screenWidth,
          ),
        ),
      ),
    ]);
  }

  /// **Settlements List**
  Widget settlementsList(
      {required double screenWidth, required double screenHeight}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
      child: Column(
        children: [
          defaultHeight(screenWidth * 0.05),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextWidget(
                text: "Today Settlements",
                isBold: false,
                size: 16,
              ),
              Icon(Icons.sync)
            ],
          ),
          defaultHeight(screenWidth * 0.05),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextWidget(
                text: "Settled Amount",
                isBold: false,
                size: 16,
              ),
              CustomTextWidget(
                text: "₹ 30,000",
                isBold: false,
                size: 16,
              ),
            ],
          ),
          defaultHeight(screenWidth * 0.2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextWidget(
                text: "Deductions",
                isBold: false,
                size: 16,
              ),
              CustomTextWidget(
                text: "₹ 100",
                isBold: false,
                size: 16,
              ),
            ],
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextWidget(
                text: "Pending Settlements",
                isBold: false,
                size: 16,
              ),
              CustomTextWidget(
                text: "₹ 300",
                isBold: false,
                size: 16,
              ),
            ],
          ),
          defaultHeight(screenWidth * 0.1),
        ],
      ),
    );
  }

  /// **MPR List**
  Widget mprList() {
    return ListView(
      children: [
        Row(
          children: [
            CustomTextWidget(text: "MPR"),
          ],
        )
      ],
    );
  }

  /// **Tab Widget**
  CustomContainer homeScreenTab(double screenHeight,
      {required double width,
      required HomeScreenTabItem homeScreenTabItem,
      required HomeScreenTabItem selectedTabItem,
      Function()? onTap,
      required String title}) {
    return CustomContainer(
      onTap: onTap,
      width: width,
      height: screenHeight * 0.07,
      color: homeScreenTabItem == selectedTabItem
          ? Colors.grey
          : AppColors.kPrimaryColor,
      child: CustomTextWidget(
        text: title,
        size: 14,
        color: Colors.white,
      ),
    );
  }
}
