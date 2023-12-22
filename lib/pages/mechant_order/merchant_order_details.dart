import 'package:flutter/material.dart';
import 'package:sifr_latest/common_widgets/custom_app_button.dart';
import 'package:sifr_latest/common_widgets/custom_app_dropdown.dart';
import 'package:sifr_latest/common_widgets/form_title_widget.dart';
import 'package:sifr_latest/common_widgets/icon_text_widget.dart';
import 'package:sifr_latest/config/config.dart';
import 'package:sifr_latest/helpers/default_height.dart';
import 'package:sifr_latest/widgets/app_scafold.dart';
import 'package:sifr_latest/widgets/custom_text_widget.dart';

class MerchantOrderDetails extends StatefulWidget {
  const MerchantOrderDetails({super.key});

  @override
  State<MerchantOrderDetails> createState() => _MerchantOrderDetailsState();
}

class _MerchantOrderDetailsState extends State<MerchantOrderDetails> {
  List<SelectedProduct> selectedItems = [];
  String? selectedProduct;
  String? selectedPackage;
  int? selectedQuantity;

  List<String> products = [
    'SoftPOS',
    'Soundbox',
    'OMA Android Terminal A880',
  ];
  List<String> packages = [
    '1999+499 standard',
    ' 999+799 tactical',
    'Special 999',
  ];

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    return AppScafofld(
      child: ListView(
        children: [
          defaultHeight(20),
          Row(
            children: [
              CustomTextWidget(
                  text: "Merchant order",
                  fontWeight: FontWeight.w500,
                  size: 24),
            ],
          ),
          defaultHeight(20),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.kSelectedBackgroundColor,
            ),
            // height: screenHeight / 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconTextWidget(
                    screenHeight: screenHeight,
                    color: AppColors.kPrimaryColor,
                    iconPath: 'assets/app_icons/merchant_order_icon.png',
                    title: "Order\nDetails")
              ],
            ),
          ),
          defaultHeight(20),
          const FormTitleWidget(subWord: 'Merchant Order Details'),
          defaultHeight(20),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomAppDropdown<String>(
                  label: 'Product',
                  hint: 'Select Product Type',
                  value: selectedProduct,
                  onChanged: (value) {
                    setState(() {
                      selectedProduct = value;
                    });
                  },
                  items: products,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a product';
                    }
                    return null;
                  },
                ),

                CustomAppDropdown<String>(
                  label: 'Package',
                  hint: 'Select Package Type',
                  value: selectedPackage,
                  onChanged: (value) {
                    setState(() {
                      selectedPackage = value;
                    });
                  },
                  items: packages,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a package';
                    }
                    return null;
                  },
                ),

                CustomAppDropdown<int>(
                  label: 'Quantity',
                  hint: 'Select Product Quantity',
                  value: selectedQuantity,
                  onChanged: (value) {
                    setState(() {
                      selectedQuantity = value;
                    });
                  },
                  items: [1, 2, 3, 4, 5],
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a quantity';
                    }
                    return null;
                  },
                ),
                defaultHeight(20),
                IconButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      SelectedProduct newItem = SelectedProduct(
                        productName: selectedProduct!,
                        package: selectedPackage!,
                        quantity: selectedQuantity!,
                      );
                      setState(() {
                        selectedItems.add(newItem);
                        selectedProduct = null;
                        selectedPackage = null;
                        selectedQuantity = null;
                      });
                    }
                  },
                  icon: Row(
                    children: [
                      Image.asset(
                        "assets/app_icons/add_icon.png",
                        height: 50,
                        color: AppColors.kPrimaryColor,
                      ),
                      defaultWidth(10),
                      CustomTextWidget(
                        text: 'Add Product',
                        color: AppColors.kLightGreen,
                        fontWeight: FontWeight.w500,
                        size: 16,
                      )
                    ],
                  ),
                ),
                // Display Selected Items
                defaultHeight(20),
                CustomTextWidget(
                  text: 'Product Summary:',
                  fontWeight: FontWeight.bold,
                ),
                defaultHeight(10),
                // Container(
                //   color: Colors.black12,
                //   child: DataTable(
                //     headingRowHeight: 0,
                //     columnSpacing: 25,
                //     columns: [
                //       DataColumn(label: Text('Product')),
                //       DataColumn(label: Text('Package')),
                //       DataColumn(label: Text('Quantity')),
                //       DataColumn(label: Text('Actions')),
                //     ],
                //     rows: selectedItems.map((item) {
                //       return DataRow(cells: [
                //         DataCell(Text(item.productName)),
                //         DataCell(Text(item.package)),
                //         DataCell(Text(item.quantity.toString())),
                //         DataCell(
                //           IconButton(
                //             icon: Icon(
                //               Icons.remove_circle_outline_rounded,
                //               color: Colors.red,
                //             ),
                //             onPressed: () {
                //               setState(() {
                //                 selectedItems.remove(item);
                //               });
                //             },
                //           ),
                //         ),
                //       ]);
                //     }).toList(),
                //   ),
                // ),
                Container(
                  color: AppColors.kTileColor,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        DataTable(
                          headingRowHeight: 0,
                          columnSpacing: 5,
                          dataRowMinHeight: 20,
                          dataRowMaxHeight: 30,
                          columns: [
                            DataColumn(label: Text('Product')),
                            DataColumn(label: Text('Package')),
                            DataColumn(label: Text('Quantity')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: selectedItems.map((item) {
                            return DataRow(cells: [
                              DataCell(CustomTextWidget(
                                text: item.productName,
                                size: 8,
                              )),
                              DataCell(CustomTextWidget(
                                text: item.package,
                                size: 8,
                              )),
                              DataCell(CustomTextWidget(
                                text: item.quantity.toString(),
                                size: 8,
                              )),
                              DataCell(
                                IconButton(
                                  icon: Icon(
                                    Icons.remove_circle_outline_rounded,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      selectedItems.remove(item);
                                    });
                                  },
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                        defaultHeight(15),
                        Container(
                          color: AppColors.kSelectedBackgroundColor,
                          child: ExpansionTile(
                            title: CustomTextWidget(
                              text: "View Complete order Summery",
                              color: Colors.grey.shade600,
                              size: 10,
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text("content"),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),

                  //  Column(
                  //   crossAxisAlignment: CrossAxisAlignment.stretch,
                  //   children: selectedItems.asMap().entries.map((entry) {
                  //     int index = entry.key;
                  //     SelectedProduct item = entry.value;
                  //     return Padding(
                  //       padding: const EdgeInsets.all(8.0),
                  //       child: Row(
                  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //         children: [
                  //           Text(
                  //             '${item.productName},\n Package: ${item.package},\n Quantity: ${item.quantity}',
                  //           ),
                  //           IconButton(
                  //             icon: Icon(Icons.delete),
                  //             onPressed: () {
                  //               setState(() {
                  //                 selectedItems.removeAt(index);
                  //               });
                  //             },
                  //           ),
                  //         ],
                  //       ),
                  //     );
                  //   }).toList(),
                  // ),
                ),

                defaultHeight(20),
                CustomAppButton(
                  onPressed: () {
                    if (selectedItems.isEmpty) {
                      print("add atlest one product");
                    } else {
                      print("no of products: ${selectedItems.length}");
                      Navigator.pushNamed(context, 'merchantOnboarding');
                    }
                  },
                  title: 'Next',
                ),
                defaultHeight(30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// demo model for add products
class SelectedProduct {
  String productName;
  String package;
  int quantity;

  SelectedProduct({
    required this.productName,
    required this.package,
    required this.quantity,
  });
}
