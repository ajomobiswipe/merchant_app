import 'dart:convert';

import 'package:anet_merchant_app/core/app_color.dart';
import 'package:anet_merchant_app/core/utils/helpers/default_height.dart';
import 'package:anet_merchant_app/data/services/connectivity_service.dart';
import 'package:anet_merchant_app/presentation/pages/merchant_scaffold.dart';
import 'package:anet_merchant_app/presentation/providers/authProvider.dart';
import 'package:anet_merchant_app/presentation/providers/home_screen_provider.dart';
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
  late HomeScreenProvider _transactionProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _transactionProvider =
          Provider.of<HomeScreenProvider>(context, listen: false);
      _transactionProvider.recentTransactionsPagination.reset();
      ConnectivityService().checkConnectivity();
      _transactionProvider.getRecentTransactions();
      _transactionProvider.fetchDailySettlementTxnSummary();
      //  _transactionProvider.fetchDailyMerchantTxnSummary();
      _transactionProvider.recentTransScrollCtrl.addListener(_onScroll);
      _setStoreName();
    });
  }

//
  Future<void> _setStoreName() async {
    final pref = await SharedPreferences.getInstance();
    var merchantIds = pref.getString("merchantIds");

    var decodedMerchantIds = json.decode(merchantIds ?? "{}");

    var dbaName = pref.getString("shopName") ?? "N/A";
    // var acquirerMerchantId = pref.getString("acqMerchantId");

    if ((decodedMerchantIds is Map && decodedMerchantIds.isNotEmpty) ||
        (decodedMerchantIds is List && decodedMerchantIds.isNotEmpty)) {

      // var object = {
      //   "merchantId": acquirerMerchantId,
      //   "shopName": dbaName,
      // };

      final List<dynamic> merchantIdMapEntries = decodedMerchantIds.entries
          .where((entry) => entry.value != null)
          .map((e) => {
                "merchantId": e.key,
                "shopName": e.value,
              })
          .toList();

      // merchantIdMapEntries.insert(0, object);

      print('merchantIdMapEntries is $merchantIdMapEntries');

      Provider.of<AuthProvider>(context, listen: false)
          .setMerchantIds(merchantIdMapEntries);

      // dbaName = merchantIdMapEntries[0]['shopName'];

      // pref.setString('shopName', merchantIdMapEntries[0]['shopName'].toString());
      // pref.setString('acqMerchantId', merchantIdMapEntries[0]['merchantId'].toString());

      // setShopNameAndAcquirerMerchantID(
      //     merchantIdMapEntries[0]['shopName'].toString(),
      //     merchantIdMapEntries[0]['merchantId'].toString());
    }

    Provider.of<AuthProvider>(context, listen: false)
        .setMerchantDbaName(dbaName);
  }

  void setShopNameAndAcquirerMerchantID(
      String shopName, String acqMerchantId) async {
    final pref = await SharedPreferences.getInstance();
    pref.setString('shopName', shopName);
    pref.setString('acqMerchantId', acqMerchantId);
    _transactionProvider.getRecentTransactions();
    _transactionProvider.fetchDailySettlementTxnSummary();
  }

  void _onScroll() {
    if (_transactionProvider.recentTransScrollCtrl.position.pixels >=
            _transactionProvider
                    .recentTransScrollCtrl.position.maxScrollExtent -
                200 &&
        !_transactionProvider.recentTransactionsPagination.isLoading) {
      _transactionProvider.getRecentTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return MerchantScaffold(
      showStoreName: true,
      isDropDownRequired: true,
      setShopNameAndAcquirerMerchantIDFunction:
          setShopNameAndAcquirerMerchantID,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          defaultHeight(screenHeight * .01),
          const CustomTextWidget(
              text: "Total Success transactions today", size: 12),
          defaultHeight(screenHeight * .01),
          const _TransactionSummaryDetailsHeader(),
          defaultHeight(screenHeight * .01),
          _TabItems(screenHeight: screenHeight, screenWidth: screenWidth),
          defaultHeight(screenHeight * .02),
          // Dynamic Content Based on Selected Tab
          const Expanded(child: _TabContent()),
          const _BottomButton(),
        ],
      ),
      onTapSupport: () {
        Navigator.pushNamed(context, "merchantHelpScreen");
      },
    );
  }
}

class _TabItems extends StatelessWidget {
  final double screenHeight;
  final double screenWidth;
  const _TabItems({required this.screenHeight, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeScreenProvider>(
      builder: (context, provider, child) {
        return Row(
          children: [
            _HomeScreenTab(
              screenHeight: screenHeight,
              width: screenWidth * 0.425,
              homeScreenTabItem: HomeScreenTabItem.TransactionHistory,
              selectedTabItem: provider.selectedTab,
              onTap: () => provider
                  .updateSelectedTab(HomeScreenTabItem.TransactionHistory),
              title: "Transaction History",
            ),
            defaultWidth(screenWidth * .05),
            _HomeScreenTab(
              screenHeight: screenHeight,
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
}

class _TransactionSummaryDetailsHeader extends StatelessWidget {
  const _TransactionSummaryDetailsHeader();
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Selector<HomeScreenProvider, HomeScreenTabItem>(
      selector: (context, provider) => provider.selectedTab,
      builder: (context, selectedTab, child) {
        switch (selectedTab) {
          case HomeScreenTabItem.TransactionHistory:
            return CustomContainer(
              height: screenHeight * 0.06,
              padding: EdgeInsets.symmetric(horizontal: screenWidth * .025),
              child: Consumer<HomeScreenProvider>(
                builder: (context, provider, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomTextWidget(
                        color: Colors.white,
                        text: provider.recentTransactionsPagination.totalItems
                            .toString(),
                        size: 18,
                      ),
                      CustomTextWidget(
                        text:
                            "₹ ${provider.totalTransactionAmount.toStringAsFixed(2)}",
                        size: 18,
                        color: Colors.white,
                      ),
                    ],
                  );
                },
              ),
            );
          case HomeScreenTabItem.Settlements:
            return CustomContainer(
              height: screenHeight * 0.06,
              padding: EdgeInsets.symmetric(horizontal: screenWidth * .025),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Consumer<HomeScreenProvider>(
                    builder: (context, provider, child) => CustomTextWidget(
                      text: "₹ ${provider.totalSettlementAmount}",
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            );
        }
      },
    );
  }
}

class _BottomButton extends StatelessWidget {
  const _BottomButton();
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Selector<HomeScreenProvider, HomeScreenTabItem>(
      selector: (context, provider) => provider.selectedTab,
      builder: (context, selectedTab, child) {
        switch (selectedTab) {
          case HomeScreenTabItem.TransactionHistory:
            return CustomContainer(
              onTap: () {
                Navigator.pushNamed(context, "merchantTransactionFilterScreen");
              },
              height: screenHeight * 0.06,
              child: const CustomTextWidget(
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
              child: const CustomTextWidget(
                text: "View All Settlements",
                color: AppColors.gray,
              ),
            );
        }
      },
    );
  }
}

class _TabContent extends StatelessWidget {
  const _TabContent();
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Consumer<HomeScreenProvider>(
      builder: (context, provider, child) {
        switch (provider.selectedTab) {
          case HomeScreenTabItem.TransactionHistory:
            return _TransactionHistoryList(
              transactionProvider: provider,
              screenWidth: screenWidth,
              screenHeight: screenHeight,
            );
          case HomeScreenTabItem.Settlements:
            return _SettlementsList(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
            );
        }
      },
    );
  }
}

class _TransactionHistoryList extends StatelessWidget {
  final HomeScreenProvider transactionProvider;
  final double screenWidth;
  final double screenHeight;
  const _TransactionHistoryList({
    required this.transactionProvider,
    required this.screenWidth,
    required this.screenHeight,
  });
  @override
  Widget build(BuildContext context) {
    final transactionElement =
        transactionProvider.recentTransactionsPagination.items;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              CustomTextWidget(text: "Recent transactions", size: 14),
              Icon(Icons.sync, color: AppColors.kPrimaryColor, size: 20),
            ],
          ),
          onTap: () {
            transactionProvider.refreshRecentTransactions();
          },
        ),
        Expanded(
          child: (transactionProvider.recentTransactionsPagination.isLoading &&
                  transactionProvider
                      .recentTransactionsPagination.items.isEmpty)
              ? const Center(child: CircularProgressIndicator())
              : transactionElement.isNotEmpty
                  ? ListView.builder(
                      controller: transactionProvider.recentTransScrollCtrl,
                      itemCount: transactionElement.length + 1,
                      itemBuilder: (context, index) {
                        if (index < transactionElement.length) {
                          return Column(
                            children: [
                              SizedBox(height: screenHeight * .01),
                              TransactionTile(
                                transaction: transactionElement[index],
                                width: screenWidth,
                              ),
                            ],
                          );
                        } else if (transactionProvider
                            .recentTransactionsPagination.hasMore) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        } else {
                          return Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                transactionElement.length > 10
                                    ? "No more transactions to display"
                                    : '',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    )
                  : const Center(
                      child: Text(
                        "No transactions available",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
        ),
      ],
    );
  }
}

class _SettlementsList extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  const _SettlementsList(
      {required this.screenWidth, required this.screenHeight});
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeScreenProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            InkWell(
              onTap: () {
                provider.fetchDailySettlementTxnSummary();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
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
                const CustomTextWidget(
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
                const CustomTextWidget(
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
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const CustomTextWidget(
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
      },
    );
  }
}

class _HomeScreenTab extends StatelessWidget {
  final double screenHeight;
  final double width;
  final HomeScreenTabItem homeScreenTabItem;
  final HomeScreenTabItem selectedTabItem;
  final Function()? onTap;
  final String title;
  const _HomeScreenTab({
    required this.screenHeight,
    required this.width,
    required this.homeScreenTabItem,
    required this.selectedTabItem,
    this.onTap,
    required this.title,
  });
  @override
  Widget build(BuildContext context) {
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
