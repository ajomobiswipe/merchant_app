import 'package:anet_merchant_app/core/app_color.dart';
import 'package:anet_merchant_app/presentation/pages/merchant_scaffold.dart';
import 'package:anet_merchant_app/presentation/providers/vpa_transaction_providerr.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_text_widget.dart';
import 'package:anet_merchant_app/presentation/widgets/transaction_tile.dart';
import 'package:anet_merchant_app/presentation/widgets/vpa_transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VpaTransactionsScreen extends StatefulWidget {
  const VpaTransactionsScreen({
    super.key,
  });

  @override
  State<VpaTransactionsScreen> createState() => _VpaTransactionsScreenState();
}

class _VpaTransactionsScreenState extends State<VpaTransactionsScreen> {
  late VpaTransactionProvider _vpaTransactionProvider;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _vpaTransactionProvider =
          Provider.of<VpaTransactionProvider>(context, listen: false);
      _vpaTransactionProvider.clearTransactions();

      _vpaTransactionProvider.getRecentTransactions();
//
      _vpaTransactionProvider.recentTransScrollCtrl.addListener(_onScroll);
    });
  }

  void _onScroll() {
    if (_vpaTransactionProvider.recentTransScrollCtrl.position.pixels >=
            _vpaTransactionProvider
                    .recentTransScrollCtrl.position.maxScrollExtent -
                200 &&
        !_vpaTransactionProvider.isDailyTransactionsLoading) {
      _vpaTransactionProvider.getRecentTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return MerchantScaffold(
      child:
          Consumer<VpaTransactionProvider>(builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  CustomTextWidget(text: "Vpa transactions", size: 14),
                  Icon(Icons.sync, color: AppColors.kPrimaryColor, size: 20),
                ],
              ),
              onTap: () {
                provider.refreshRecentTransactions();
              },
            ),
            Expanded(
              child: (provider.isDailyTransactionsLoading &&
                      provider.recentTransactions.isEmpty)
                  ? const Center(child: CircularProgressIndicator())
                  : provider.transactions.isNotEmpty
                      ? ListView.builder(
                          controller: provider.recentTransScrollCtrl,
                          itemCount: provider.transactions.length + 1,
                          itemBuilder: (context, index) {
                            if (index < provider.transactions.length) {
                              return Column(
                                children: [
                                  SizedBox(height: screenHeight * .01),
                                  VpaTransactionTile(
                                    transaction: provider.transactions[index],
                                    width: screenWidth,
                                  ),
                                ],
                              );
                            } else if (provider.hasMoreTransactions) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              );
                            } else {
                              return Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    provider.transactions.length > 10
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
      }),
    );
  }
}
