/* ===============================================================
| Project : MERCHANT ONBOARDING
| Page    : CUSTOM_DROPDOWN.DART
| Date    : 04-OCT-2024
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'package:flutter/material.dart';
import 'package:anet_merchant_app/config/config.dart';

// Global Drop Down
// class CustomDropdown extends StatelessWidget {
//   // LOCAL VARIABLE DECLARATION
//   final String title;
//   final bool required;
//   final IconData? prefixIcon;
//   final List itemList;
//   final bool enabled;
//   final bool titleEnabled;
//   final FormFieldValidator? validator;
//   final FormFieldSetter? onSaved;
//   final ValueChanged? onChanged;
//   final String? selectedItem;
//   final String? hintText;
//   final DropdownSearchOnFind? asyncItems;
//   final DropdownSearchItemAsString? itemAsString;
//   final DropdownSearchFilterFn? filterFn;
//   final DropdownSearchCompareFn? compareFn;
//   final AutovalidateMode? autoValidateMode;
//   final bool dropDownIsEnabled;

//   const CustomDropdown(
//       {super.key,
//       required this.title,
//       this.required = false,
//       required this.itemList,
//       this.prefixIcon,
//       this.validator,
//       this.onSaved,
//       this.onChanged,
//       this.selectedItem,
//       this.asyncItems,
//       this.itemAsString,
//       this.filterFn,
//       this.compareFn,
//       this.autoValidateMode,
//       this.enabled = true,
//       this.hintText,
//       this.titleEnabled = true,
//       this.dropDownIsEnabled = true});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.start,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (titleEnabled)
//           required
//               ? RichText(
//                   text: TextSpan(
//                       text: title,
//                       style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                           fontWeight: FontWeight.w300,
//                           fontSize: 14,
//                           color: Colors.black,
//                           fontFamily: 'Mont'),
//                       children: const [
//                         TextSpan(
//                             text: ' *',
//                             style: TextStyle(
//                                 color: Colors.black, fontFamily: 'Mont'))
//                       ]),
//                 )
//               : Text(
//                   title,
//                   style: Theme.of(context)
//                       .textTheme
//                       .bodyLarge
//                       ?.copyWith(fontWeight: FontWeight.w300, fontSize: 16),
//                 ),
//         //Global Drop Down
//         if (titleEnabled)
//           const SizedBox(
//             height: 8,
//           ),
//         if (dropDownIsEnabled)
//           DropdownSearch(
//             items: itemList,
//             onChanged: onChanged,
//             onSaved: onSaved,
//             selectedItem: selectedItem,
//             validator: validator,
//             enabled: enabled,
//             asyncItems: asyncItems,
//             itemAsString: itemAsString,
//             compareFn: compareFn,
//             filterFn: filterFn,
//             dropdownButtonProps: const DropdownButtonProps(
//                 icon: Icon(Icons.keyboard_arrow_down),
//                 color: AppColors.kPrimaryColor),
//             autoValidateMode: AutovalidateMode.onUserInteraction,
//             popupProps: const PopupProps.menu(
//                 showSearchBox: true,
//                 menuProps: MenuProps(
//                   elevation: 16,
//                 )),
//             dropdownBuilder: (context, selectedItem) {
//               return Text(
//                 selectedItem ?? "$hintText",
//                 overflow: TextOverflow.ellipsis,
//                 style: Theme.of(context).textTheme.displaySmall?.copyWith(
//                     fontWeight: FontWeight.normal,
//                     fontSize: 13,
//                     color: selectedItem == null
//                         ? Colors.black.withValues(alpha: 0.25)
//                         : Colors.black),
//               );
//             },
//             dropdownDecoratorProps: DropDownDecoratorProps(
//               dropdownSearchDecoration: commonInputDecoration(prefixIcon),
//             ),
//           ),
//       ],
//     );
//   }
// }

InputDecoration commonInputDecoration(IconData? prefixIcon,
    {String? hintText,
    double? rightPadding,
    IconData? suffixIcon,
    String? helperText,
    TextStyle? helperStyle}) {
  return InputDecoration(
    // label: Text(title),
    helperText: helperText,
    helperStyle: helperStyle,
    hintText: hintText ?? '',
    fillColor: AppColors.kTileColor,
    filled: true,
    contentPadding: EdgeInsets.only(
        left: 10, top: 10, bottom: 10, right: rightPadding ?? 10),
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
    prefixIcon: Icon(prefixIcon, size: 25, color: AppColors.kPrimaryColor),
    suffixIcon: suffixIcon == null
        ? null
        : Icon(suffixIcon, size: 25, color: AppColors.kPrimaryColor),
  );
}
