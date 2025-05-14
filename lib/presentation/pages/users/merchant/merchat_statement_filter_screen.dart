import 'package:anet_merchant_app/core/constants/constants.dart';
import 'package:anet_merchant_app/presentation/pages/users/merchant/merchant_scaffold.dart';
import 'package:anet_merchant_app/presentation/providers/merchant_transaction_filter_provider.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_container.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';


class MerchantStatementFilterScreen extends StatelessWidget {
  const MerchantStatementFilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Consumer<MerchantTransactionFilterProvider>(
      builder: (context, provider, child) {
        return MerchantScaffold(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextWidget(
                    text: Constants.storeName,
                    size: screenHeight * 0.025),
                Spacer(flex: 1),
                CustomTextWidget(
                    text: "Settlements", size: screenHeight * 0.02),
                Spacer(flex: 2),
                CustomTextWidget(
                  text: "Total Settlements",
                  size: 12,
                ),
                _buildDateRangeSelector(provider),
                if (provider.selectedDateRange == 'Custom Date Range')
                  Padding(
                    padding: EdgeInsets.only(top: screenHeight * 0.02),
                    child: _buildCustomDatePickers(provider, context),
                  ),
                Spacer(flex: 1),
                Spacer(flex: 2),
                _buildApplyButton(provider, context: context),
              ],
            ),
          ),
          onTapHome: () {
            Navigator.pop(context);
          },
          onTapSupport: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, "merchantHelpScreen");
          },
        );
      },
    );
  }

  Widget _buildDateRangeSelector(MerchantTransactionFilterProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
        Column(
          children: provider.dateRanges.map((range) {
            return RadioListTile<String>(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(range, style: TextStyle(fontSize: 12)),
              value: range,
              groupValue: provider.selectedDateRange,
              onChanged: provider.setSelectedDateRange,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCustomDatePickers(
      MerchantTransactionFilterProvider provider, BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildDatePicker('Start Date', provider.customStartDate,
              (picked) {
            provider.setCustomStartDate(picked);
          }, context),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _buildDatePicker('End Date', provider.customEndDate, (picked) {
            provider.setCustomEndDate(picked);
          }, context),
        ),
      ],
    );
  }

  Widget _buildDatePicker(String label, DateTime? selectedDate,
      Function(DateTime) onPicked, BuildContext context) {
    return ListTile(
      title: Text(selectedDate == null
          ? 'Select $label'
          : DateFormat.yMMMd().format(selectedDate)),
      trailing: Icon(Icons.calendar_today),
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          onPicked(picked);
        }
      },
    );
  }

  Widget _buildApplyButton(MerchantTransactionFilterProvider provider,
      {required BuildContext context}) {
    return CustomContainer(
      height: 70,
      onTap: () {
        Navigator.pushNamed(context, "settlementDashboard");
      },
      child: CustomTextWidget(text: 'Apply Filters', color: Colors.white),
    );
  }
}
