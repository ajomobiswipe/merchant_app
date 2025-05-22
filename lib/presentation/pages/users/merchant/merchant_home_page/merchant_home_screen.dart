import 'package:anet_merchant_app/core/app_color.dart';
import 'package:anet_merchant_app/core/constants/constants.dart';
import 'package:anet_merchant_app/core/utils/helpers/default_height.dart';
import 'package:anet_merchant_app/data/models/transaction_model.dart';
import 'package:anet_merchant_app/presentation/pages/users/merchant/all_transactions_filter.dart';
import 'package:anet_merchant_app/presentation/pages/users/merchant/merchant_scaffold.dart';
import 'package:anet_merchant_app/presentation/providers/transactions_provider.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_container.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_text_widget.dart';
import 'package:anet_merchant_app/presentation/widgets/transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MerchantHomeScreen extends StatefulWidget {
  const MerchantHomeScreen({super.key});

  @override
  State<MerchantHomeScreen> createState() => _MerchantHomeScreenState();
}

class _MerchantHomeScreenState extends State<MerchantHomeScreen> {
  late TransactionProvider transactionProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      transactionProvider =
          Provider.of<TransactionProvider>(context, listen: false);
      //transactionProvider.refreshRecentTransactions();
      transactionProvider.getRecentTransactions();
      transactionProvider.fetchDailySettlementTxnSummary();
      transactionProvider.recentTransScrollCtrl.addListener(_onScroll);
    });
  }

  @override
  void dispose() {
    transactionProvider.recentTransScrollCtrl.removeListener(_onScroll);
    transactionProvider.recentTransScrollCtrl.dispose();
    super.dispose();
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
    return LayoutBuilder(
      builder: (_, constraints) {
        double screenHeight = MediaQuery.of(context).size.height;
        double screenWidth = MediaQuery.of(context).size.width;
        return MerchantScaffold(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextWidget(text: Constants.storeName, size: 18),
              defaultHeight(screenHeight * .015),
              CustomTextWidget(text: "Total transactions today", size: 12),
              defaultHeight(screenHeight * .015),
              Selector<TransactionProvider, HomeScreenTabItem>(
                selector: (context, provider) => provider.selectedTab,
                builder: (context, selectedTab, child) {
                  switch (selectedTab) {
                    case HomeScreenTabItem.TransactionHistory:
                      return CustomContainer(
                        height: screenHeight * 0.06,
                        padding: EdgeInsets.symmetric(horizontal: 20),
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
                                      provider.totalSettlementAmount.toString(),
                                  size: 18,
                                  color: Colors.white),
                            ],
                          );
                        }),
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
                                    "₹ ${context.read<TransactionProvider>().totalSettlementAmount}",
                                size: 18,
                                color: Colors.white), //totalSettlementAmount
                          ],
                        ),
                      );
                  }
                },
              ),
              defaultHeight(screenHeight * .015),
              Consumer<TransactionProvider>(
                builder: (context, provider, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      homeScreenTab(
                        screenHeight,
                        width: screenWidth * 0.4,
                        homeScreenTabItem: HomeScreenTabItem.TransactionHistory,
                        selectedTabItem: provider.selectedTab,
                        onTap: () => provider.updateSelectedTab(
                            HomeScreenTabItem.TransactionHistory),
                        title: "Transaction History",
                      ),
                      homeScreenTab(
                        screenHeight,
                        width: screenWidth * 0.4,
                        homeScreenTabItem: HomeScreenTabItem.Settlements,
                        selectedTabItem: provider.selectedTab,
                        onTap: () => provider
                            .updateSelectedTab(HomeScreenTabItem.Settlements),
                        title: "Settlements",
                      ),
                    ],
                  );
                },
              ),

              defaultHeight(screenHeight * .015),

              // **Dynamic Content Based on Selected Tab**
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
            MerchantTransactionFilterBottomSheet.show(context);
            // Navigator.pushNamed(context, "merchantTransactionFilterScreen");
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
            size: 12.0,
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
            transactionProvider: TransactionProvider);
      case HomeScreenTabItem.Settlements:
        return settlementsList(
            screenWidth: screenWidth, screenHeight: screenHeight);
    }
  }

  /// **Transaction History List**
  Widget transactionHistoryList(
      {required List<TransactionElement> transactionElement,
      required TransactionProvider transactionProvider,
      required double screenWidth}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          child: Row(
            children: [
              CustomTextWidget(text: "Recent transactions", size: 14),
              Icon(Icons.sync, color: AppColors.kPrimaryColor, size: 20),
            ],
          ),
          onTap: () {
            transactionProvider.refreshRecentTransactions();
          },
        ),
        defaultHeight(10),
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
                          return TransactionTile(
                            transaction: transactionElement[index],
                            width: screenWidth,
                          );
                        } else if (transactionProvider.hasMoreTransactions) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        } else {
                          return Center(
                              child: Text("-----   END OF LIST  ------"));
                        }
                      },
                    )
                  : Center(
                      child: Text(
                        "No transactions available",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
        ),
      ],
    );
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
