import 'package:anet_merchant_app/core/app_color.dart';
import 'package:anet_merchant_app/core/utils/helpers/default_height.dart';
import 'package:anet_merchant_app/presentation/pages/merchant_scaffold.dart';
import 'package:anet_merchant_app/presentation/providers/merchant_filtered_transaction_provider.dart';
import 'package:anet_merchant_app/presentation/widgets/app/alert_service.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_container.dart';
import 'package:anet_merchant_app/presentation/widgets/custom_text_widget.dart';
import 'package:anet_merchant_app/presentation/widgets/form_field/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MerchantTransactionFilterScreen extends StatefulWidget {
  const MerchantTransactionFilterScreen({super.key});

  @override
  State<MerchantTransactionFilterScreen> createState() =>
      _MerchantTransactionFilterScreenState();
}

class _MerchantTransactionFilterScreenState
    extends State<MerchantTransactionFilterScreen> {
  late MerchantFilteredTransactionProvider transactionProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      transactionProvider = Provider.of<MerchantFilteredTransactionProvider>(
          context,
          listen: false);

      transactionProvider.resetFilters();
      transactionProvider.allTidScrollCtrl.addListener(_onScroll);
    });
  }

  void _onScroll() {
    if (transactionProvider.allTidScrollCtrl.position.pixels >=
            transactionProvider.allTidScrollCtrl.position.maxScrollExtent -
                200 &&
        !transactionProvider.isAllTidLoading) {
      transactionProvider.getTidByMerchantId();
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Consumer<MerchantFilteredTransactionProvider>(
      builder: (context, provider, child) {
        return MerchantScaffold(
          showStoreName: true,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.02,
            ),
            child: ListView(
              children: [
                CustomTextWidget(text: "Payment Tid", size: 12),
                defaultHeight(screenHeight * .01),
                _buildFilterSelection(
                  provider,
                ),

                // SizedBox(height: screenHeight * 0.02),
                defaultHeight(screenHeight * .01),
                provider.selectedSearchFilterType == FilterType.DATERANGE
                    ? Column(
                        children: [
                          _buildTidTextFelid(screenWidth),
                          defaultHeight(screenHeight * .02),
                          _buildDateRangeSelector(provider),
                          if (provider.selectedDateRange == 'Custom Date Range')
                            Padding(
                              padding:
                                  EdgeInsets.only(top: screenHeight * 0.02),
                              child: _buildCustomDatePickers(provider, context),
                            ),
                          defaultHeight(screenHeight * .03),
                          _buildPaymentModeDropdown(provider, screenWidth),
                          defaultHeight(screenHeight * .03),
                        ],
                      )
                    : Column(
                        children: [
                          _buildRrnAppCodeSearchField(
                              provider, screenWidth, screenHeight),
                        ],
                      ),
                defaultHeight(screenHeight * .05),

                _buildApplyButton(provider,
                    context: context, screenHeight: screenHeight),
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

  Widget _buildFilterSelection(MerchantFilteredTransactionProvider provider) {
    return Column(
      children: [
        Row(
          children: [
            CustomTextWidget(text: "Search By", size: 12),
          ],
        ),
        Row(
          children: [
            Radio<FilterType>(
              value: FilterType.DATERANGE,
              groupValue: provider.selectedSearchFilterType,
              onChanged: provider.setFilterType,
            ),
            CustomTextWidget(text: 'Date', size: 10),
            Radio<FilterType>(
              value: FilterType.RRNAPPCODE,
              groupValue: provider.selectedSearchFilterType,
              onChanged: provider.setFilterType,
            ),
            CustomTextWidget(text: 'RRN/App Code', size: 10),
          ],
        ),
      ],
    );
  }

  Widget _buildRrnAppCodeSearchField(
      MerchantFilteredTransactionProvider provider,
      double screenWidth,
      double screenHeight) {
    return Column(
      children: [
        DropdownButtonFormField<SearchType>(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          isDense: true,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.kPrimaryColor,
          ),
          decoration: commonInputDecoration(
            hintText: "select one",
            Icons.receipt_long,
          ),
          value: provider.selectedSearchType,
          items: [
            DropdownMenuItem<SearchType>(
              value: SearchType.RRN,
              child: Text("RRN"),
            ),
            DropdownMenuItem<SearchType>(
              value: SearchType.APP_CODE,
              child: Text("App Code"),
            ),
          ],
          onChanged: (newValue) {
            if (newValue != null) {
              provider.setSearchType(newValue);
            }
          },
          validator: (value) {
            if (value == null) {
              return 'Select one!';
            }
            return null;
          },
        ),
        SizedBox(height: screenHeight * 0.03),
        TextField(
          controller: provider.searchController,

          decoration: commonInputDecoration(
              hintText:
                  'Enter ${provider.selectedSearchType == SearchType.RRN ? 'RRN' : 'App Code'}',
              suffixIcon: Icons.clear,
              Icons.pin_outlined, onTapSuffixIcon: () {
            provider.searchController.clear();
          }),

          // ),
          style: TextStyle(fontSize: 12),
        ),
        SizedBox(height: screenHeight * 0.3),
      ],
    );
  }

  Widget _buildTidTextFelid(double screenWidth) {
    return Column(
      children: [
        Consumer<MerchantFilteredTransactionProvider>(
          builder: (context, midProvider, child) {
            return Row(
              children: [
                CustomTextWidget(text: "Tid", size: 12),
                SizedBox(width: screenWidth * 0.2),
                Expanded(
                  child: TextField(
                    controller: midProvider.tidSearchController,
                    enabled: true,
                    readOnly: true,
                    onTap: () {
                      showBottomSheet(screenWidth);
                    },
                    //  controller: provider.tidSearchController,
                    decoration: commonInputDecoration(
                      hintText: "Select",
                      Icons.point_of_sale_outlined,
                    ),
                    onChanged: (value) => print("Entered: $value"),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  void showBottomSheet(double screenWidth) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextWidget(
                text: "Select Terminal ID",
                color: AppColors.kPrimaryColor,
                size: 16,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: 16),
              Expanded(
                child: Consumer<MerchantFilteredTransactionProvider>(
                  builder: (context, tidProvider, child) {
                    if (tidProvider.isAllTidLoading &&
                        tidProvider.allTid.isEmpty) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (tidProvider.allTid.isEmpty) {
                      return Center(
                        child: Text(
                          "No Tid available",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      controller: tidProvider.allTidScrollCtrl,
                      itemCount: tidProvider.allTid.length + 1,
                      itemBuilder: (context, index) {
                        if (index < tidProvider.allTid.length) {
                          return TextField(
                            enabled: true,
                            readOnly: true,
                            onTap: () {
                              tidProvider
                                  .setTid(tidProvider.allTid[index] ?? '');
                              // tidProvider.tidSearchController.text =
                              //     tidProvider.allTid[index] ?? '';
                              Navigator.pop(context);
                            },
                            decoration: commonInputDecoration(
                              hintText: tidProvider.allTid[index] ?? '',
                              Icons.point_of_sale_outlined,
                            ),
                            onChanged: (value) => print("Entered: $value"),
                          );
                        } else if (tidProvider.hasMoreTid) {
                          return Center(child: CircularProgressIndicator());
                        } else {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                tidProvider.allTid.length > 15
                                    ? "No more Tid"
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
                      separatorBuilder: (context, index) => Divider(
                        color: Colors.grey,
                        height: 1,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: CustomContainer(
                  width: screenWidth * 0.85,
                  height: 40,
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Center(
                    child: CustomTextWidget(
                      text: "Close",
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateRangeSelector(MerchantFilteredTransactionProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextWidget(text: "Date", size: 12),
        Column(
          children: provider.dateRanges.map((range) {
            return Row(
              children: [
                Radio<String>(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  value: range,
                  groupValue: provider.selectedDateRange,
                  onChanged: provider.setSelectedDateRange,
                ),
                Text(range, style: TextStyle(fontSize: 10)),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCustomDatePickers(
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

  Widget _buildDatePicker(String label, DateTime? selectedDate,
      Function(DateTime) onPicked, BuildContext context) {
    return ListTile(
      title: CustomTextWidget(
          size: 12,
          isBold: false,
          text: selectedDate == null
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

  Widget _buildPaymentModeDropdown(
      MerchantFilteredTransactionProvider provider, double screenWidth) {
    return Row(
      children: [
        CustomTextWidget(text: "Payment Mode", size: 12),
        SizedBox(width: screenWidth * 0.1),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: provider.selectedPaymentMode,
            decoration: commonInputDecoration(
              hintText: "select one",
              Icons.credit_card_outlined,
            ),
            items: provider.paymentModes.map((mode) {
              return DropdownMenuItem(
                  value: mode,
                  child: Text(
                    mode,
                    style: TextStyle(fontSize: 10),
                  ));
            }).toList(),
            onChanged: provider.setSelectedPaymentMode,
          ),
        ),
      ],
    );
  }

  Widget _buildApplyButton(MerchantFilteredTransactionProvider provider,
      {required BuildContext context, required double screenHeight}) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: CustomContainer(
            color: Colors.red.shade400,
            height: screenHeight * 0.06,
            onTap: () {
              provider.resetFilters();
            },
            child: CustomTextWidget(text: 'Reset', color: Colors.white),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: CustomContainer(
            height: screenHeight * 0.06,
            onTap: () {
              if (provider.selectedSearchFilterType == FilterType.DATERANGE) {
                // provider.selectedDateRange == 'Custom Date Range' &&
                if (provider.isDateNotSelected() &&
                    provider.tidSearchController.text.isEmpty) {
                  AlertService()
                      .error("Please select a date range or enter TID.");
                  return;
                }
                //  else if (provider.selectedTid == null ||
                //     provider.selectedTid!.isEmpty) {
                // }

                Navigator.pushNamed(context, "viewAllTransaction");
              } else if (provider.selectedSearchFilterType ==
                  FilterType.RRNAPPCODE) {
                if (provider.selectedSearchType == SearchType.RRN &&
                    provider.searchController.text.isEmpty) {
                  AlertService().error("Please enter RRN.");
                  return;
                } else if (provider.selectedSearchType == SearchType.APP_CODE &&
                    provider.searchController.text.isEmpty) {
                  AlertService().error("Please enter App Code.");

                  return;
                }

                Navigator.pushNamed(context, "viewAllTransaction");
              }

              //Navigator.pushNamed(context, "viewAllTransaction");
            },
            child: CustomTextWidget(text: 'Apply', color: Colors.white),
          ),
        ),
      ],
    );
  }
}
