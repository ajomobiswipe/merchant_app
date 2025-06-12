import 'package:anet_merchant_app/core/app_color.dart';
import 'package:anet_merchant_app/core/constants/constants.dart';
import 'package:anet_merchant_app/core/utils/helpers/default_height.dart';
import 'package:anet_merchant_app/data/models/transaction_model.dart';
import 'package:anet_merchant_app/presentation/pages/users/merchant/merchant_scaffold.dart';
import 'package:anet_merchant_app/presentation/providers/authProvider.dart';
import 'package:anet_merchant_app/presentation/providers/transactions_provider.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_container.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_text_widget.dart';
import 'package:anet_merchant_app/presentation/widgets/transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MerchantHomeScreen extends StatefulWidget {
  const MerchantHomeScreen({super.key});

  @override
  State<MerchantHomeScreen> createState() => _MerchantHomeScreenState();
}

class _MerchantHomeScreenState extends State<MerchantHomeScreen> {
  late TransactionProvider transactionProvider;
  String? storeName;
  @override
  void initState() {
    super.initState();
    setStoreName();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      transactionProvider =
          Provider.of<TransactionProvider>(context, listen: false);
      transactionProvider.clearTransactions();
      transactionProvider.getRecentTransactions();
      transactionProvider.fetchDailySettlementTxnSummary();
      transactionProvider.fetchDailyMerchantTxnSummary();
      transactionProvider.recentTransScrollCtrl.addListener(_onScroll);
    });
  }

  setStoreName() async {
    final pref = await SharedPreferences.getInstance();
    var dbaName = pref.getString("shopName") ?? "N/A";
    Provider.of<AuthProvider>(context, listen: false)
        .setMerchantDbaName(dbaName);
  }

  void _onScroll() {
    if (transactionProvider.recentTransScrollCtrl.position.pixels >=
            transactionProvider.recentTransScrollCtrl.position.maxScrollExtent -
                200 &&
        !transactionProvider.isDailyTransactionsLoading) {
      transactionProvider.getRecentTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return MerchantScaffold(
      showStoreName: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          defaultHeight(screenHeight * .01),
          CustomTextWidget(text: "Total Success transactions today", size: 12),
          defaultHeight(screenHeight * .01),
          _transactionSummaryDetailsHeader(screenHeight, screenWidth),
          defaultHeight(screenHeight * .01),
          _tabItems(screenHeight, screenWidth),

          defaultHeight(screenHeight * .02),

          // **Dynamic Content Based on Selected Tab**r
          Expanded(
            child: Consumer<TransactionProvider>(
              builder: (context, provider, child) {
                return getTabContent(
                    TransactionProvider: provider,
                    screenWidth: screenWidth,
                    screenHeight: screenHeight);
              },
            ),
          ),
          Selector<TransactionProvider, HomeScreenTabItem>(
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
  }

  Consumer<TransactionProvider> _tabItems(
      double screenHeight, double screenWidth) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return Row(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            homeScreenTab(
              screenHeight,
              width: screenWidth * 0.425,
              homeScreenTabItem: HomeScreenTabItem.TransactionHistory,
              selectedTabItem: provider.selectedTab,
              onTap: () => provider
                  .updateSelectedTab(HomeScreenTabItem.TransactionHistory),
              title: "Transaction History",
            ),
            defaultWidth(screenWidth * .05),
            homeScreenTab(
              screenHeight,
              width: screenWidth * 0.425,
              homeScreenTabItem: HomeScreenTabItem.Settlements,
              selectedTabItem: provider.selectedTab,
              onTap: () =>
                  provider.updateSelectedTab(HomeScreenTabItem.Settlements),
              title: "Settlements",
            ),
          ],
        );
      },
    );
  }

  Selector<TransactionProvider, HomeScreenTabItem>
      _transactionSummaryDetailsHeader(
          double screenHeight, double screenWidth) {
    return Selector<TransactionProvider, HomeScreenTabItem>(
      selector: (context, provider) => provider.selectedTab,
      builder: (context, selectedTab, child) {
        switch (selectedTab) {
          case HomeScreenTabItem.TransactionHistory:
            return CustomContainer(
              height: screenHeight * 0.06,
              padding: EdgeInsets.symmetric(horizontal: screenWidth * .025),
              child: Consumer<TransactionProvider>(
                  builder: (context, provider, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomTextWidget(
                        color: Colors.white,
                        text: provider.todaysTnxCount.toString(),
                        size: 18),
                    CustomTextWidget(
                        text:
                            "₹ ${provider.getTotalTransactionAmount.toStringAsFixed(2)}",
                        size: 18,
                        color: Colors.white),
                  ],
                );
              }),
            );
          case HomeScreenTabItem.Settlements:
            return CustomContainer(
              height: screenHeight * 0.06,
              padding: EdgeInsets.symmetric(horizontal: screenWidth * .025),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomTextWidget(
                      text:
                          "₹ ${context.read<TransactionProvider>().totalSettlementAmount}",
                      size: 18,
                      color: Colors.white), //totalSettlementAmount
                ],
              ),
            );
        }
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
            // MerchantTransactionFilterBottomSheet.show(context);
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
    }
  }

  /// **Function to Return Content Based on Selected Tab**
  Widget getTabContent(
      {required TransactionProvider TransactionProvider,
      required double screenWidth,
      required double screenHeight}) {
    switch (TransactionProvider.selectedTab) {
      case HomeScreenTabItem.TransactionHistory:
        return transactionHistoryList(
            transactionElement: TransactionProvider.transactions ?? [],
            screenWidth: screenWidth,
            transactionProvider: TransactionProvider,
            screenHeight: screenHeight);
      case HomeScreenTabItem.Settlements:
        return settlementsList(
            screenWidth: screenWidth, screenHeight: screenHeight);
    }
  }

  /// **Transaction History List**
  Widget transactionHistoryList(
      {required List<TransactionElement> transactionElement,
      required TransactionProvider transactionProvider,
      required double screenWidth,
      required double screenHeight}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextWidget(text: "Recent transactions", size: 14),
              Icon(Icons.sync, color: AppColors.kPrimaryColor, size: 20),
            ],
          ),
          onTap: () {
            transactionProvider.refreshRecentTransactions();
          },
        ),
        Expanded(
          child: (transactionProvider.isDailyTransactionsLoading &&
                  transactionProvider.recentTransactions.isEmpty)
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : transactionElement.isNotEmpty
                  ? ListView.builder(
                      controller: transactionProvider.recentTransScrollCtrl,
                      itemCount: transactionElement.length + 1,
                      itemBuilder: (context, index) {
                        if (index < transactionElement.length) {
                          return Column(
                            children: [
                              SizedBox(
                                height: screenHeight * .01,
                              ),
                              TransactionTile(
                                transaction: transactionElement[index],
                                width: screenWidth,
                              ),
                            ],
                          );
                        } else if (transactionProvider.hasMoreTransactions) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text("No more transactions to display",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic)),
                            ),
                          );
                        }
                      },
                    )
                  : Center(
                      child: Text(
                        "No transactions available",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic),
                      ),
                    ),
        ),
      ],
    );
  }

  /// **Settlements List**
  Widget settlementsList(
      {required double screenWidth, required double screenHeight}) {
    return Consumer<TransactionProvider>(builder: (context, provider, child) {
      return Column(
        children: [
          InkWell(
            onTap: () {
              provider.fetchDailySettlementTxnSummary();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextWidget(
                  text: "Today Settlements",
                  isBold: true,
                  size: 14,
                ),
                Icon(Icons.sync, color: AppColors.kPrimaryColor, size: 20),
              ],
            ),
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
                text: "₹ ${provider.totalSettlementAmount}",
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
                text: "₹ ${provider.deductionsAmount}",
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
                text: "₹ ${provider.pendingSettlementAmount}",
                isBold: false,
                size: 16,
              ),
            ],
          ),
          defaultHeight(screenWidth * 0.1),
        ],
      );
    });
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
      height: screenHeight * 0.05,
      color: homeScreenTabItem == selectedTabItem
          ? Colors.grey
          : AppColors.kPrimaryColor,
      child: CustomTextWidget(
        text: title,
        size: 12,
        color: Colors.white,
      ),
    );
  }
}
