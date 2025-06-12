import 'package:anet_merchant_app/core/app_color.dart';
import 'package:anet_merchant_app/core/constants/constants.dart';
import 'package:anet_merchant_app/core/utils/helpers/default_height.dart';
import 'package:anet_merchant_app/data/models/transaction_model.dart';
import 'package:anet_merchant_app/presentation/pages/users/merchant/merchant_scaffold.dart';
import 'package:anet_merchant_app/presentation/providers/settlement_provider.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_container.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_text_widget.dart';
import 'package:anet_merchant_app/presentation/widgets/settled_transaction_tile.dart';
import 'package:anet_merchant_app/presentation/widgets/transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ViewSettlementInfo extends StatefulWidget {
  const ViewSettlementInfo({super.key});

  @override
  State<ViewSettlementInfo> createState() => _ViewSettlementInfoState();
}

class _ViewSettlementInfoState extends State<ViewSettlementInfo> {
  late SettlementProvider _settlementProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _settlementProvider =
          Provider.of<SettlementProvider>(context, listen: false);
      _settlementProvider.allSettlementScrollCtrl.addListener(_onScroll);
      _settlementProvider.clearTransactionList();
      _settlementProvider.getTransactionsInSettlement();
    });
  }

  void _onScroll() {
    if (_settlementProvider.allSettlementScrollCtrl.position.pixels >=
            _settlementProvider
                    .allSettlementScrollCtrl.position.maxScrollExtent -
                200 &&
        !_settlementProvider.isAllTransactionsLoading) {
      _settlementProvider.getTransactionsInSettlement();
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
          defaultHeight(10),
          Consumer<SettlementProvider>(
              builder: (context, settlementProvider, child) {
            return CustomContainer(
              color: AppColors.kLightGreen,
              // height: screenHeight * 0.14,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  defaultHeight(10),
                  CustomTextWidget(
                      text:
                          "₹ ${settlementProvider.selectedSettlementAggregate?.grossTransactionAmount ?? 0}",
                      size: 18,
                      color: Colors.white),
                  CustomTextWidget(
                      text:
                          "${settlementProvider.selectedSettlementAggregate?.transactionCount ?? 0} Transactions",
                      size: 12,
                      color: Colors.white),
                  CustomTextWidget(
                      text:
                          "Settled on ${settlementProvider.selectedSettlementAggregate?.tranDate != null ? "${settlementProvider.selectedSettlementAggregate!.tranDate!.day.toString().padLeft(2, '0')}-${settlementProvider.selectedSettlementAggregate!.tranDate!.month.toString().padLeft(2, '0')}-${settlementProvider.selectedSettlementAggregate!.tranDate!.year}" : 'N/A'}",
                      size: 14,
                      color: Colors.white),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextWidget(
                              text: "Settled to",
                              size: 12,
                              color: Colors.white),
                          CustomTextWidget(
                              text: "Axis Bank Ltd | ***6545",
                              size: 12,
                              color: Colors.white),
                        ],
                      ),
                      Column(
                        children: [
                          CustomTextWidget(
                              text: "UTR No", size: 12, color: Colors.white),
                          CustomTextWidget(
                              text:
                                  "${settlementProvider.selectedSettlementAggregate?.utr ?? "N/A"}",
                              size: 10,
                              color: Colors.white),
                        ],
                      ),
                    ],
                  ),
                  defaultHeight(10),
                ],
              ),
            );
          }),

          // **Dynamic Content Based on Selected Tab**
          Expanded(
            child: Consumer<SettlementProvider>(
              builder: (context, settlementProvider, child) {
                return settlementProvider.showDeductions
                    ? ListView(
                        children: <Widget>[
                          defaultHeight(10),
                          buildSettlementRow(
                              "Amt Packed for Settlement",
                              settlementProvider.selectedSettlementAggregate
                                  ?.grossTransactionAmount),
                          buildSettlementRow("Refund Amount", null),
                          buildSettlementRow("Chargeback Amount", null),
                          buildSettlementRow("Loan Recovery Amount", null),
                          buildSettlementRow(
                              "MSF/MDR",
                              settlementProvider
                                  .selectedSettlementAggregate?.mdrAmount),
                          buildSettlementRow("MAR", null),
                          buildSettlementRow("Late Stl Fee", null),
                          buildSettlementRow(
                              "GST",
                              settlementProvider
                                  .selectedSettlementAggregate?.gst),
                          buildSettlementRow("Others", null),
                          // buildSettlementRow(
                          //     "Settled Amount",
                          //     settlementProvider.selectedSettlementAggregate
                          //         ?.totalAmountPayable),
                          ListTile(
                            title: CustomTextWidget(
                                text: "Settled Amount",
                                size: 13,
                                color: Colors.black),
                            trailing: CustomTextWidget(
                                text:
                                    "₹ ${settlementProvider.selectedSettlementAggregate?.totalAmountPayable ?? 0.00}",
                                size: 13,
                                color: Colors.black),
                          ),
                          changeDeductionButton(
                            screenWidth,
                            screenHeight,
                            settlementProvider,
                          ),
                          SizedBox(
                            height: screenHeight * .015,
                          )
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          defaultHeight(10),
                          changeDeductionButton(
                            screenWidth,
                            screenHeight,
                            settlementProvider,
                          ),
                          defaultHeight(10),
                          Expanded(
                            child: (settlementProvider
                                        .isAllTransactionsLoading &&
                                    settlementProvider.allTransactions.isEmpty)
                                ? Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : settlementProvider.allTransactions.isNotEmpty
                                    ? ListView.builder(
                                        controller: settlementProvider
                                            .allSettlementScrollCtrl,
                                        itemCount: settlementProvider
                                                .allTransactions.length +
                                            1,
                                        itemBuilder: (context, index) {
                                          if (index <
                                              settlementProvider
                                                  .allTransactions.length) {
                                            return SettledTransactionTile(
                                              transaction: settlementProvider
                                                  .allTransactions[index],
                                              width: screenWidth,
                                            );
                                          } else if (settlementProvider
                                              .hasMoreTransactions) {
                                            return Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 16),
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            );
                                          } else {
                                            return Center(
                                              child: Text(
                                                settlementProvider
                                                            .allTransactions
                                                            .length >
                                                        10
                                                    ? "No more transactions to display"
                                                    : '',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey,
                                                    fontStyle:
                                                        FontStyle.italic),
                                              ),
                                            );
                                          }
                                        },
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
                      );
              },
            ),
          ),
          Consumer<SettlementProvider>(
            builder: (context, settlementProvider, child) {
              return settlementProvider.isEmailSending
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
                        settlementProvider
                            .sendSettlementDashboardReportTOEmail();
                      },
                      height: screenHeight * 0.06,
                      child: CustomTextWidget(
                        text: "Send By Email",
                        color: AppColors.gray,
                      ),
                    );
            },
          ),
        ],
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

  Center changeDeductionButton(
    double screenWidth,
    double screenHeight,
    SettlementProvider settlementProvider,
  ) {
    return Center(
      child: CustomContainer(
        color: Colors.grey[300]!,
        height: screenHeight * .06,
        width: screenWidth * .5,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextWidget(
                text: settlementProvider.showDeductions
                    ? "Hide Deductions"
                    : "View Deductions",
                isBold: true,
                size: 14,
              ),
              Icon(
                settlementProvider.showDeductions
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
              )
            ],
          ),
        ),
        onTap: () {
          settlementProvider.toggleDeductions();
        },
      ),
    );
  }

  /// **Function to Return Content Based on Selected Tab*

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

  Widget buildSettlementRow(String label, double? amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomTextWidget(
              text: label, size: 13, color: Colors.black.withOpacity(.5)),
          CustomTextWidget(
              text: "₹ ${amount?.toStringAsFixed(2) ?? "0.00"}",
              size: 14,
              color: Colors.black.withOpacity(.5)),
        ],
      ),
    );
  }
}
