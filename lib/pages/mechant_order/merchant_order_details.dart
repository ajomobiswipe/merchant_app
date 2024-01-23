import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:sifr_latest/common_widgets/custom_app_button.dart';
import 'package:sifr_latest/common_widgets/form_title_widget.dart';
import 'package:sifr_latest/common_widgets/icon_text_widget.dart';
import 'package:sifr_latest/config/config.dart';
import 'package:sifr_latest/helpers/default_height.dart';
import 'package:sifr_latest/pages/mechant_order/models/mechant_additionalingo_model.dart';
import 'package:sifr_latest/widgets/app_scafold.dart';
import 'package:sifr_latest/widgets/custom_text_widget.dart';
import 'package:sifr_latest/widgets/widget.dart';

class MerchantOrderDetails extends StatefulWidget {
  final MerchantAdditionalInfoRequestmodel merchantCompanyDetailsReq;
  List tmsProductMaster;
  Function orderNext;
  MerchantOrderDetails(
      {super.key,
      required this.orderNext,
      required this.tmsProductMaster,
      required this.merchantCompanyDetailsReq});

  @override
  State<MerchantOrderDetails> createState() => _MerchantOrderDetailsState();
}

class _MerchantOrderDetailsState extends State<MerchantOrderDetails> {
  int? selectedProductId;
  int? selectedPackageId;
  List<Map<String, dynamic>> selectedProductPackages = [];
  List<SelectedProduct> selectedItems = [];
  // String? selectedProduct;
  // String? selectedPackage;
  String selectedPackage = '';
  String selectedProduct = '';
  String selectedQuantity = '';

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
  void initState() {
    // TODO: implement initState
    super.initState();
    addproduct();
  }

  addproduct() {
    widget.merchantCompanyDetailsReq.merchantProductDetails!.add(
        MerchantProductDetails(
            productName: "aadf",
            productId: 1,
            package: "package",
            packagetId: 2,
            quantity: 5));
    print(widget.merchantCompanyDetailsReq.merchantProductDetails);
  }

  resetvalues() {
    selectedProductId = null;
    selectedPackageId = null;
    selectedProductPackages = [];
  }

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
                ElevatedButton(
                    onPressed: () {
                      print(jsonEncode(
                          widget.merchantCompanyDetailsReq.toJson()));
                    },
                    child: Text("demo")),
                DropdownButtonFormField<int>(
                  value: selectedProductId,
                  hint: const Text('Select a Product'),
                  items: widget.tmsProductMaster
                      .asMap()
                      .entries
                      .map<DropdownMenuItem<int>>((entry) {
                    Map<String, dynamic> product = entry.value;

                    int productId = product['productId'];

                    return DropdownMenuItem<int>(
                      value: productId,
                      child: Text(product['productName'].toString()),
                    );
                  }).toList(),
                  onChanged: (int? value) {
                    setState(() {
                      selectedProductId = value;
                      selectedProductPackages = [];

                      var selectedProduct = widget.tmsProductMaster.firstWhere(
                        (product) => (product['tmsPackage'] as List<dynamic>)
                            .any((innerProduct) =>
                                innerProduct['productId'] == selectedProductId),
                        orElse: () => null,
                      );

                      if (selectedProduct != null) {
                        selectedProductPackages =
                            (selectedProduct['tmsPackage'] as List<dynamic>)
                                .cast<Map<String, dynamic>>();
                      }

                      selectedPackageId = null;
                    });
                  },
                  validator: (value) {
                    if (value == null || value < 0) {
                      return 'Please Select a Product!';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    // label: Text(title),
                    fillColor: AppColors.kTileColor,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: const BorderSide(
                        color: Colors.black,
                      ),
                    ),
                    enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        borderSide: BorderSide(color: Colors.transparent)),
                    disabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        borderSide: BorderSide(color: Colors.transparent)),
                    focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        borderSide: BorderSide(color: Colors.transparent)),
                    prefixIcon: Icon(Icons.ad_units,
                        size: 25, color: Theme.of(context).primaryColor),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                DropdownButtonFormField<int>(
                  key: ValueKey<int>(selectedProductId ??
                      0), // Use ValueKey to track selectedProductId
                  value: selectedPackageId,
                  hint: const Text('Select a Package'),
                  items: selectedProductPackages.isNotEmpty
                      ? selectedProductPackages
                          .asMap()
                          .entries
                          .map<DropdownMenuItem<int>>((entry) {
                          Map<String, dynamic> package = entry.value;
                          return DropdownMenuItem<int>(
                            value: package['packageId'] as int,
                            child: Text(
                                '${package['packageName']} ${package['description']}'),
                          );
                        }).toList()
                      : [
                          const DropdownMenuItem<int>(
                            value: 0,
                            child: Text('No Packages'),
                          )
                        ],

                  onChanged: (int? value) {
                    setState(() {
                      selectedPackageId = value == 0 ? null : value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value < 0) {
                      return 'Please Select a Package!';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    // label: Text(title),
                    fillColor: AppColors.kTileColor,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: const BorderSide(
                        color: Colors.black,
                      ),
                    ),
                    enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        borderSide: BorderSide(color: Colors.transparent)),
                    disabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        borderSide: BorderSide(color: Colors.transparent)),
                    focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        borderSide: BorderSide(color: Colors.transparent)),
                    prefixIcon: Icon(Icons.ad_units,
                        size: 25, color: Theme.of(context).primaryColor),
                  ),
                ),

                const SizedBox(height: 16.0),

                // CustomDropdown(
                //   title: "Product",
                //   // enabled: selectedState != '' && enabledState
                //   //     ? enabledcity = true
                //   //     : enabledcity = false,
                //   required: true,
                //   selectedItem: selectedProduct != '' ? selectedProduct : null,
                //   prefixIcon: FontAwesome.product_hunt,
                //   itemList: widget.tmsProductMaster
                //       .map((e) => e['productName'].toString())
                //       .toList(),

                //   // nationalityList
                //   //     .map((map) => map['label'].toString())
                //   //     .toList(),
                //   //countryList.map((e) => e['ctyName']).toList(),
                //   onChanged: (value) {
                //     setState(() {
                //       selectedProduct = value;
                //       // requestModel.city = value;
                //     });
                //   },
                //   onSaved: (value) {
                //     // merchantPersonalReq.currentNationality = value;
                //   },
                //   validator: (value) {
                //     if (value == null || value.isEmpty) {
                //       return 'Please select Product !';
                //     }
                //     return null;
                //   },
                // ),
                // SizedBox(
                //   height: 20,
                // ),
                // CustomDropdown(
                //   title: "Package",
                //   // enabled: selectedState != '' && enabledState
                //   //     ? enabledcity = true
                //   //     : enabledcity = false,

                //   required: true,
                //   selectedItem: selectedPackage != '' ? selectedPackage : null,
                //   prefixIcon: FontAwesome.product_hunt,
                //   itemList: packages,

                //   // nationalityList
                //   //     .map((map) => map['label'].toString())
                //   //     .toList(),
                //   //countryList.map((e) => e['ctyName']).toList(),
                //   onChanged: (value) {
                //     setState(() {
                //       selectedPackage = value;
                //       // requestModel.city = value;
                //     });
                //   },
                //   onSaved: (value) {
                //     // merchantPersonalReq.currentNationality = value;
                //   },
                //   validator: (value) {
                //     if (value == null || value.isEmpty) {
                //       return 'Please select package !';
                //     }
                //     return null;
                //   },
                // ),
                SizedBox(
                  height: 20,
                ),
                CustomDropdown(
                  title: "Quantity",
                  // enabled: selectedState != '' && enabledState
                  //     ? enabledcity = true
                  //     : enabledcity = false,
                  required: true,
                  selectedItem:
                      selectedQuantity != '' ? selectedQuantity : null,
                  prefixIcon: FontAwesome.product_hunt,
                  itemList: const ['1', '2', '3', '4', '5'],

                  // nationalityList
                  //     .map((map) => map['label'].toString())
                  //     .toList(),
                  //countryList.map((e) => e['ctyName']).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedQuantity = value;
                      // requestModel.city = value;
                    });
                  },
                  onSaved: (value) {
                    // merchantPersonalReq.currentNationality = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Product Quantity!';
                    }
                    return null;
                  },
                ),

                Text('Selected Product ID: ${selectedProductId ?? "None"}'),
                Text('Selected Package ID: ${selectedPackageId ?? "None"}'),
                if (selectedPackageId != null &&
                    selectedProductPackages.isNotEmpty)
                  Text(
                      'Selected Package Name: ${selectedProductPackages.firstWhere((package) => package['packageId'] == selectedPackageId)['packageName']}'),
                if (selectedProductId != null &&
                    widget.tmsProductMaster.isNotEmpty)
                  Text(
                      'Selected Product Description: ${widget.tmsProductMaster.firstWhere((product) => product['productId'] == selectedProductId)['description']}'),
                // ElevatedButton(
                //   onPressed: () {
                //     setState(() {
                //       selectedProductId = null;
                //       selectedPackageId = null;
                //       selectedProductPackages = [];
                //     });
                //   },
                //   child: Text('Clear Selection'),
                // ),
                defaultHeight(20),
                IconButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      var Product = selectedProductPackages.firstWhere(
                          (package) =>
                              package['packageId'] ==
                              selectedPackageId)['packageName'];
                      var package = widget.tmsProductMaster.firstWhere(
                          (product) =>
                              product['productId'] ==
                              selectedProductId)['description'];
                      SelectedProduct newItem = SelectedProduct(
                        productName: Product,
                        package: package,
                        quantity: int.parse(selectedQuantity),
                        productId: selectedProductId!,
                        packagetId: selectedPackageId!,
                      );
                      setState(() {
                        selectedProductId = null;
                        selectedPackageId = null;
                        selectedProductPackages = [];
                        selectedItems.add(newItem);
                        selectedQuantity = '';
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
                              text: "View Complete order Summary",
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
                  onPressed: () async {
                    widget.orderNext();
                    // if (selectedItems.isEmpty) {
                    //   print("add atlest one product");
                    // } else {
                    //   print("no of products: ${selectedItems.length}");
                    //   widget.orderNext;
                    // }
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
  int productId;
  String package;
  int packagetId;
  int quantity;

  SelectedProduct({
    required this.productName,
    required this.productId,
    required this.package,
    required this.packagetId,
    required this.quantity,
  });
}
