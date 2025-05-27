import 'package:anet_merchant_app/core/constants/constants.dart';
import 'package:anet_merchant_app/presentation/providers/merchant_filtered_transaction_provider.dart';
import 'package:anet_merchant_app/presentation/widgets/app/alert_service.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_container.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MerchantTransactionFilterBottomSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Consumer<MerchantFilteredTransactionProvider>(
          builder: (context, provider, child) {
            double screenHeight = MediaQuery.of(context).size.height;
            double screenWidth = MediaQuery.of(context).size.width;
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.02,
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  CustomTextWidget(
                      text: Constants.storeName, size: screenHeight * 0.025),
                  SizedBox(height: screenHeight * 0.02),
                  CustomTextWidget(
                      text: "Payment transactions", size: screenHeight * 0.02),
                  SizedBox(height: screenHeight * 0.02),
                  _buildSearchField(provider),
                  SizedBox(height: screenHeight * 0.02),
                  _buildTidDropdown(provider),
                  SizedBox(height: screenHeight * 0.02),
                  _buildDateRangeSelector(provider),
                  if (provider.selectedDateRange == 'Custom Date Range')
                    Padding(
                      padding: EdgeInsets.only(top: screenHeight * 0.02),
                      child: _buildCustomDatePickers(provider, context),
                    ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildPaymentModeDropdown(provider),
                  SizedBox(height: screenHeight * 0.03),
                  _buildApplyButton(provider, context: context),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildSearchField(
      MerchantFilteredTransactionProvider provider) {
    return Row(
      children: [
        Radio<String>(
          value: 'RRN',
          groupValue: provider.searchType,
          onChanged: provider.setSearchType,
        ),
        CustomTextWidget(text: 'RRN', size: 10),
        Radio<String>(
          value: 'App Code',
          groupValue: provider.searchType,
          onChanged: provider.setSearchType,
        ),
        CustomTextWidget(text: 'App Code', size: 10),
        SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 30,
            child: TextField(
              controller: provider.searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, size: 16),
                suffixIcon: InkWell(
                  onTap: () {
                    provider.searchController.clear();
                  },
                  child: Icon(Icons.close, size: 16),
                ),
                labelText: 'Enter ${provider.searchType}',
                labelStyle: TextStyle(fontSize: 12),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              ),
              style: TextStyle(fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildTidDropdown(
      MerchantFilteredTransactionProvider provider) {
    return DropdownButtonFormField<String>(
      value: provider.selectedTid,
      decoration: InputDecoration(
        labelText: 'Terminal-All',
        border: OutlineInputBorder(),
      ),
      items: provider.tidOptions.map((tid) {
        return DropdownMenuItem(value: tid, child: Text(tid));
      }).toList(),
      onChanged: provider.setSelectedTid,
    );
  }

  static Widget _buildDateRangeSelector(
      MerchantFilteredTransactionProvider provider) {
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

  static Widget _buildCustomDatePickers(
      MerchantFilteredTransactionProvider provider, BuildContext context) {
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

  static Widget _buildDatePicker(String label, DateTime? selectedDate,
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

  static Widget _buildPaymentModeDropdown(
      MerchantFilteredTransactionProvider provider) {
    return DropdownButtonFormField<String>(
      value: provider.selectedPaymentMode,
      decoration: InputDecoration(
        labelText: 'Payment Mode',
        border: OutlineInputBorder(),
      ),
      items: provider.paymentModes.map((mode) {
        return DropdownMenuItem(value: mode, child: Text(mode));
      }).toList(),
      onChanged: provider.setSelectedPaymentMode,
    );
  }

  static Widget _buildApplyButton(MerchantFilteredTransactionProvider provider,
      {required BuildContext context}) {
    return CustomContainer(
      height: 70,
      onTap: () {
        if (provider.selectedDateRange == null ||
            provider.selectedDateRange!.isEmpty) {
          AlertService().error(
            "Please select a date range",
          );
          Navigator.pop(context);
          return;
        }
        Navigator.pop(context);
        Navigator.pushNamed(context, "viewAllTransaction");
        print(
            'Filters applied: ${provider.searchController.text}, ${provider.selectedTid}, ${provider.selectedDateRange}, ${provider.selectedPaymentMode}');
      },
      child: CustomTextWidget(text: 'Apply Filters', color: Colors.white),
    );
  }
}
