import 'package:anet_merchant_app/core/app_color.dart';
import 'package:anet_merchant_app/core/constants/constants.dart';
import 'package:anet_merchant_app/core/utils/helpers/default_height.dart';
import 'package:anet_merchant_app/data/models/transaction_model.dart';
import 'package:anet_merchant_app/presentation/pages/users/merchant/merchant_scaffold.dart';
import 'package:anet_merchant_app/presentation/providers/merchant_filtered_transaction_provider.dart';
import 'package:anet_merchant_app/presentation/providers/transactions_provider.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_container.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_text_widget.dart';
import 'package:anet_merchant_app/presentation/widgets/transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ViewAllTransactionScreen extends StatefulWidget {
  const ViewAllTransactionScreen({super.key});

  @override
  State<ViewAllTransactionScreen> createState() =>
      _ViewAllTransactionScreenState();
}

class _ViewAllTransactionScreenState extends State<ViewAllTransactionScreen> {
  late MerchantFilteredTransactionProvider transactionProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      transactionProvider = Provider.of<MerchantFilteredTransactionProvider>(
          context,
          listen: false);
      transactionProvider.refreshAllTransactions();
      transactionProvider.getAllTransactions();

      transactionProvider.allTransScrollCtrl.addListener(_onScroll);
    });
  }

  // @override
  // void dispose() {
  //   transactionProvider.recentTransScrollCtrl.removeListener(_onScroll);
  //   transactionProvider.recentTransScrollCtrl.dispose();
  //   super.dispose();
  // }

  void _onScroll() {
    if (transactionProvider.allTransScrollCtrl.position.pixels >=
            transactionProvider.allTransScrollCtrl.position.maxScrollExtent -
                200 &&
        !transactionProvider.isAllTransactionsLoading) {
      transactionProvider.getAllTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return MerchantScaffold(
      child: Consumer<MerchantFilteredTransactionProvider>(
        builder: (context, transactionProvider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextWidget(text: Constants.storeName, size: 18),
              defaultHeight(15),
              CustomTextWidget(
                  text: transactionProvider.getFormattedDateRange(), size: 12),
              defaultHeight(10),
              CustomContainer(
                height: screenHeight * 0.05,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomTextWidget(
                        color: Colors.white,
                        text: transactionProvider.todaysTnxCount.toString(),
                        size: 18),
                    CustomTextWidget(
                        text: "₹ " +
                            transactionProvider.totalSettlementAmount
                                .toString(),
                        size: 18,
                        color: Colors.white),
                  ],
                ),
              ),
              defaultHeight(20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    defaultHeight(10),
                    Expanded(
                      child: (transactionProvider.isAllTransactionsLoading &&
                              transactionProvider.allTransactions.isEmpty)
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : transactionProvider.allTransactions.isNotEmpty
                              ? GestureDetector(
                                  onTapUp: (details) {
                                    print("onTapUp");
                                  },
                                  child: ListView.builder(
                                    controller:
                                        transactionProvider.allTransScrollCtrl,
                                    itemCount: transactionProvider
                                            .allTransactions.length +
                                        1,
                                    itemBuilder: (context, index) {
                                      if (index <
                                          transactionProvider
                                              .allTransactions.length) {
                                        return TransactionTile(
                                          transaction: transactionProvider
                                              .allTransactions[index],
                                          width: screenWidth,
                                        );
                                      } else if (transactionProvider
                                          .hasMoreTransactions) {
                                        return Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 16),
                                          child: Center(
                                              child:
                                                  CircularProgressIndicator()),
                                        );
                                      } else {
                                        return Center(
                                            child: Text(
                                                "-----   END OF LIST  ------"));
                                      }
                                    },
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    "No transactions available",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                  ),
                                ),
                    ),
                  ],
                ),
              ),
              transactionProvider.isEmailSending
                  ? Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: CustomContainer(
                        height: screenHeight * 0.06,
                        child: CustomTextWidget(
                          text: "Sending Email...",
                          color: AppColors.gray,
                        ),
                      ),
                    )
                  : CustomContainer(
                      onTap: () {
                        transactionProvider.sendAllTransactionsToEmail();
                      },
                      height: screenHeight * 0.06,
                      child: CustomTextWidget(
                        text: "Send By Email",
                        color: AppColors.gray,
                      ),
                    ),
            ],
          );
        },
      ),
      onTapHome: () {
        Navigator.pushNamedAndRemoveUntil(
            context, "merchantHomeScreen", (route) => false);
      },
      onTapSupport: () {
        Navigator.pushNamedAndRemoveUntil(
            context, "merchantHomeScreen", (route) => false);
        Navigator.pushNamed(context, "merchantHelpScreen");
      },
    );
  }
}
