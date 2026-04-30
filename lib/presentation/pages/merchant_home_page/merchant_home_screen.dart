import 'dart:convert';
import 'package:anet_merchant_app/core/app_color.dart';
import 'package:anet_merchant_app/core/utils/helpers/default_height.dart';
import 'package:anet_merchant_app/data/models/all_transaction_list.dart';
import 'package:anet_merchant_app/data/services/app_update_service.dart';
import 'package:anet_merchant_app/data/services/connectivity_service.dart';
import 'package:anet_merchant_app/presentation/pages/merchant_scaffold.dart';
import 'package:anet_merchant_app/presentation/providers/authProvider.dart';
import 'package:anet_merchant_app/presentation/providers/home_screen_provider.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_container.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_text_widget.dart';
import 'package:anet_merchant_app/presentation/widgets/form_field/custom_dropdown.dart';
import 'package:anet_merchant_app/presentation/widgets/transaction_tile.dart';
import 'package:anet_merchant_app/presentation/widgets/vpa_transaction_tile.dart';
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
  bool isDashboardVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).getIsDashboardVisible();
      Provider.of<AuthProvider>(context, listen: false).setMerchantIds([]);
      _transactionProvider =
          Provider.of<HomeScreenProvider>(context, listen: false);
      _transactionProvider.recentTransactionsPagination.reset();
      ConnectivityService().checkConnectivity();
      // _transactionProvider.getRecentTransactions();
      checkForCallingGetRecentTransactions(_transactionProvider);
      // _transactionProvider.getRecentVPATransactions();
      _transactionProvider.fetchDailySettlementTxnSummary();
      _transactionProvider.clearallVpalistPagination();
      _transactionProvider.getVpaByMerchantId();
      //  _transactionProvider.fetchDailyMerchantTxnSummary();
      _transactionProvider.recentTransScrollCtrl.addListener(_onScroll);
      _transactionProvider.recentVPATransScrollCtrl
          .addListener(_onScrollVpaist);
      _setStoreName();
    });

    InAppUpdateService().checkForUpdate();
  }

  Future<void> checkForCallingGetRecentTransactions(
      dynamic transactionProvider) async {
    final pref = await SharedPreferences.getInstance();
    // var merchantIds = pref.getString("merchantIds");
    var merchantIds = pref.getString("merchantInfoForDashboard");
    var decodedMerchantIds = json.decode(merchantIds ?? "{}");

    var allMerchantIds = pref.getString("merchantIds");
    Map<String, dynamic> decodedAllMerchantIds =
        json.decode(allMerchantIds ?? "{}");

    if (((decodedMerchantIds is Map && decodedMerchantIds.isEmpty) ||
            (decodedMerchantIds is List && decodedMerchantIds.isEmpty)) &&
        ((decodedAllMerchantIds.isEmpty) ||
            (decodedAllMerchantIds is List && decodedAllMerchantIds.isEmpty))) {
      await transactionProvider.getRecentTransactions();
    }
  }

//
  Future<void> _setStoreName() async {
    Provider.of<AuthProvider>(context, listen: false).setMerchantIds([]);

    final pref = await SharedPreferences.getInstance();
    // var merchantIds = pref.getString("merchantIds");
    var merchantInfoForDashboard = pref.getString("merchantInfoForDashboard");
    var decodedMerchantIds = json.decode(merchantInfoForDashboard ?? "{}");

    bool isTerminalUser = pref.getString('role') == "TERMINAL USER";

    if (isTerminalUser) return;

    var merchantIds = pref.getString("merchantIds");
    Map<String, dynamic> decodedAllMerchantIds =
        json.decode(merchantIds ?? "{}");

    List<dynamic> merchantIdMapEntries = [
      {
        "merchantId": "0",
        "shopName": "All",
        "serialNo": null,
      },
    ];

    // var acquirerMerchantId = pref.getString("acqMerchantId");

    if ((decodedMerchantIds is Map && decodedMerchantIds.isNotEmpty) ||
        (decodedMerchantIds is List && decodedMerchantIds.isNotEmpty)) {
      merchantIdMapEntries = [
        merchantIdMapEntries[0],
        ...decodedMerchantIds.map((e) => {
              "merchantId": e['acqid'],
              "shopName": e['shopName'],
              "serialNo": e['serialId'],
            })
      ];

      // merchantIdMapEntries.insert(0, object);

      // dbaName = merchantIdMapEntries[0]['shopName'];

      // pref.setString('shopName', merchantIdMapEntries[0]['shopName'].toString());
      // pref.setString('acqMerchantId', merchantIdMapEntries[0]['merchantId'].toString());

      // setShopNameAndAcquirerMerchantID(
      //     merchantIdMapEntries[0]['shopName'].toString(),
      //     merchantIdMapEntries[0]['merchantId'].toString());
    }

    if ((decodedAllMerchantIds.isNotEmpty) ||
        (decodedAllMerchantIds is List && decodedAllMerchantIds.isNotEmpty)) {
      // Combine and remove duplicates based on 'merchantId'
      // Step 1: Extract acqid list

      final acqIds =
          decodedMerchantIds.map((e) => e['acqid'] as String).toSet();

      // Step 2: Remove matching keys from map
      decodedAllMerchantIds.removeWhere((key, value) => acqIds.contains(key));

      // Step 3: Combine remaining map entries with new entries
      merchantIdMapEntries.addAll(
        decodedAllMerchantIds.entries.map((entry) => {
              "merchantId": entry.key,
              "shopName": entry.value,
              "serialNo": null,
            }),
      );
    }

    if (merchantIdMapEntries.length > 1) {
      // dbaName = merchantIdMapEntries[0]['shopName'];

      // pref.setString(
      //     'shopName', merchantIdMapEntries[0]['shopName'].toString());
      // pref.setString(
      //     'acqMerchantId', merchantIdMapEntries[0]['merchantId'].toString());

      setShopNameAndAcquirerMerchantID(
          merchantIdMapEntries[0]['shopName'].toString(),
          merchantIdMapEntries[0]['merchantId'].toString());
      // await Provider.of<HomeScreenProvider>(context, listen: false)
      //     .getAllTxnsTotalAndCount();
      Provider.of<AuthProvider>(context, listen: false)
          .setMerchantIds(merchantIdMapEntries);
    }
  }

  void setShopNameAndAcquirerMerchantID(
      String shopName, String acqMerchantId) async {
    Provider.of<HomeScreenProvider>(context, listen: false)
        .setSelectedAcquirerMerchantId(acqMerchantId);
    final pref = await SharedPreferences.getInstance();

    //  var dbaName = pref.getString("shopName") ?? "N/A";
    var dbaName = shopName;
    Provider.of<AuthProvider>(context, listen: false)
        .setMerchantDbaName(dbaName);

    pref.setString('shopName', shopName);
    pref.setString('acqMerchantId', acqMerchantId);
    _transactionProvider.allVpalistPagination.isFirstLoad = true;
    _transactionProvider.recentTransactionsPagination.reset();
    _transactionProvider.getVpaByMerchantId();

    if (acqMerchantId == 0.toString()) {
      await Provider.of<HomeScreenProvider>(context, listen: false)
          .getAllTxnsTotalAndCount();
    } else {
      _transactionProvider.getRecentTransactions();
    }

    // _transactionProvider.getRecentTransactions();
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

  void _onScrollVpaist() {
    if (_transactionProvider.recentVPATransScrollCtrl.position.pixels >=
            _transactionProvider
                    .recentVPATransScrollCtrl.position.maxScrollExtent -
                200 &&
        !_transactionProvider.recentVpaTransactionsPagination.isLoading) {
      _transactionProvider.getRecentVPATransactions();
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
        if (provider.selectedAcquirerMerchantId == "0") return Container();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _HomeScreenTab(
              screenHeight: screenHeight,
              width: screenWidth * 0.27,
              homeScreenTabItem: HomeScreenTabItem.TransactionHistory,
              selectedTabItem: provider.selectedTab,
              onTap: () => provider
                  .updateSelectedTab(HomeScreenTabItem.TransactionHistory),
              title: "POS Txns History",
            ),
            // defaultWidth(screenWidth * .03),
            _HomeScreenTab(
              screenHeight: screenHeight,
              width: screenWidth * 0.27,
              homeScreenTabItem: HomeScreenTabItem.VpaTransactions,
              selectedTabItem: provider.selectedTab,
              onTap: () =>
                  provider.updateSelectedTab(HomeScreenTabItem.VpaTransactions),
              title: "QR Txns History",
            ),
            // defaultWidth(screenWidth * .03),
            _HomeScreenTab(
              screenHeight: screenHeight,
              width: screenWidth * 0.27,
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
          case HomeScreenTabItem.VpaTransactions:
            {
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
                          text: provider
                              .recentVpaTransactionsPagination.totalItems
                              .toString(),
                          size: 18,
                        ),
                        CustomTextWidget(
                          text:
                              "₹ ${provider.totalVPATransactionAmount.toStringAsFixed(2)}",
                          size: 18,
                          color: Colors.white,
                        ),
                      ],
                    );
                  },
                ),
              );
            }
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
          case HomeScreenTabItem.TransactionHistory ||
                HomeScreenTabItem.VpaTransactions:
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
        if (provider.selectedAcquirerMerchantId == "0") {
          return AllTerminalsTxnWidget(provider.allTerminalsTxn,
              provider.recentTransactionsPagination.isLoading);
        }
        switch (provider.selectedTab) {
          case HomeScreenTabItem.TransactionHistory:
            return _TransactionHistoryList(
              transactionProvider: provider,
              screenWidth: screenWidth,
              screenHeight: screenHeight,
            );
          case HomeScreenTabItem.VpaTransactions:
            return _VPATransactionHistoryList(
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

class _VPATransactionHistoryList extends StatelessWidget {
  final HomeScreenProvider transactionProvider;
  final double screenWidth;
  final double screenHeight;
  const _VPATransactionHistoryList({
    required this.transactionProvider,
    required this.screenWidth,
    required this.screenHeight,
  });
  @override
  Widget build(BuildContext context) {
    final transactionElement =
        transactionProvider.recentVpaTransactionsPagination.items;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<HomeScreenProvider>(
          builder: (context, provider, child) {
            // if (provider.allVpalistPagination.items.isEmpty) {
            //   return const CircularProgressIndicator();
            // }
            return DropdownButtonFormField<dynamic>(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              isDense: true,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.kPrimaryColor,
              ),
              decoration: commonInputDecoration(
                hintText: provider.allVpalistPagination.items.isEmpty
                    ? 'No VPA available'
                    : "select one",
                Icons.qr_code_2,
              ),
              style: const TextStyle(fontFamily: 'Mont', fontSize: 10),
              value: provider.selectedVpa,
              items: provider.allVpalistPagination.items.map((action) {
                return DropdownMenuItem<String>(
                  value: action,
                  child: CustomTextWidget(text: action),
                );
              }).toList(),
              onChanged: (newValue) {
                provider.changeSelectedVpa(newValue);
                // setState(() {
                //   provider.selectedQuickAction = newValue;
                //   supportActionProvider.selectedSupportAction =
                //       newValue; // Update the provider with the selected value
                // });
              },
            );
          },
        ),
        defaultHeight(screenHeight * .01),
        InkWell(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              CustomTextWidget(text: "Recent transactions", size: 14),
              Icon(Icons.sync, color: AppColors.kPrimaryColor, size: 20),
            ],
          ),
          onTap: () {
            transactionProvider.refreshVpaTransactions();
          },
        ),
        Expanded(
          child: (transactionProvider
                      .recentVpaTransactionsPagination.isLoading &&
                  transactionProvider
                      .recentVpaTransactionsPagination.items.isEmpty)
              ? const Center(child: CircularProgressIndicator())
              : transactionElement.isNotEmpty
                  ? ListView.builder(
                      controller: transactionProvider.recentVPATransScrollCtrl,
                      itemCount: transactionElement.length + 1,
                      itemBuilder: (context, index) {
                        if (index < transactionElement.length) {
                          return Column(
                            children: [
                              SizedBox(height: screenHeight * .01),
                              VpaTransactionTile(
                                transaction: transactionElement[index],
                                width: screenWidth,
                              ),
                            ],
                          );
                        } else if (transactionProvider
                            .recentVpaTransactionsPagination.hasMore) {
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
                        "No Vpa transactions available",
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
          ? Colors.green
          : AppColors.kPrimaryColor,
      child: CustomTextWidget(
        text: title,
        size: 11,
        color: Colors.white,
      ),
    );
  }
}

class AllTerminalsTxnWidget extends StatelessWidget {
  final List<AllTerminalsTxn> allTerminalsTxn;
  final bool? loading;
  const AllTerminalsTxnWidget(this.allTerminalsTxn, this.loading, {super.key});
  @override
  Widget build(BuildContext context) {
    if (loading == true) {
      return const Center(child: CircularProgressIndicator());
    }
    if (allTerminalsTxn.isEmpty) {
      return Center(
        child: Text(
          "No transactions available",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: allTerminalsTxn.length,
      itemBuilder: (context, index) {
        final txn = allTerminalsTxn[index];
        return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.blue.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.05),
                    spreadRadius: -1,
                    blurRadius: 5,
                    offset: Offset(0, -1),
                  ),
                ],
              ),
              child: ListTile(
                title: CustomTextWidget(
                  text: "Terminal No: ${txn.serialNumber ?? "N/A"}",
                  size: 16,
                ),
                subtitle: CustomTextWidget(
                    text:
                        "Count: ${txn.count} \nTotal Amount: ₹ ${txn.totalAmount}",
                    size: 16,
                    isBold: false),
              ),
            ));
      },
    );
  }
}
