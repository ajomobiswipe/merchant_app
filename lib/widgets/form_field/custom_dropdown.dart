/* ===============================================================
| Project : SIFR
| Page    : CUSTOM_DROPDOWN.DART
| Date    : 22-MAR-2023
|
*  ===============================================================*/

// Dependencies or Plugins - Models - Services - Global Functions
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:sifr_latest/config/config.dart';

// Global Drop Down
class CustomDropdown extends StatelessWidget {
  // LOCAL VARIABLE DECLARATION
  final String title;
  final bool required;
  final IconData? prefixIcon;
  final List itemList;
  final bool enabled;
  final bool titleEnabled;
  final FormFieldValidator? validator;
  final FormFieldSetter? onSaved;
  final ValueChanged? onChanged;
  final String? selectedItem;
  final String? hintText;
  final DropdownSearchOnFind? asyncItems;
  final DropdownSearchItemAsString? itemAsString;
  final DropdownSearchFilterFn? filterFn;
  final DropdownSearchCompareFn? compareFn;
  final AutovalidateMode? autoValidateMode;
  final bool dropDownIsEnabled;

  const CustomDropdown(
      {Key? key,
      required this.title,
      this.required = false,
      required this.itemList,
      this.prefixIcon,
      this.validator,
      this.onSaved,
      this.onChanged,
      this.selectedItem,
      this.asyncItems,
      this.itemAsString,
      this.filterFn,
      this.compareFn,
      this.autoValidateMode,
      this.enabled = true,
      this.hintText,
      this.titleEnabled = true,
      this.dropDownIsEnabled = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var isDarkMode = context.isDarkMode;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (titleEnabled)
          required
              ? RichText(
                  text: TextSpan(
                      text: title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w300,
                          fontSize: 14,
                          color: Colors.black,
                          fontFamily: 'Mont'),
                      children: const [
                        TextSpan(
                            text: ' *',
                            style: TextStyle(
                                color: Colors.black, fontFamily: 'Mont'))
                      ]),
                )
              : Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w300, fontSize: 16),
                ),
        //Global Drop Down
        if (titleEnabled)
          const SizedBox(
            height: 8,
          ),
        if (dropDownIsEnabled)
          DropdownSearch(
            items: itemList,
            onChanged: onChanged,
            onSaved: onSaved,
            selectedItem: selectedItem,
            validator: validator,
            enabled: enabled,
            asyncItems: asyncItems,
            itemAsString: itemAsString,
            compareFn: compareFn,
            filterFn: filterFn,
            dropdownButtonProps: const DropdownButtonProps(
                icon: Icon(Icons.keyboard_arrow_down),
                color: AppColors.kPrimaryColor),
            autoValidateMode: AutovalidateMode.onUserInteraction,
            popupProps: const PopupProps.menu(
                showSearchBox: false,
                menuProps: MenuProps(
                  elevation: 16,
                )),
            dropdownBuilder: (context, selectedItem) {
              return Text(
                selectedItem ?? "$hintText",
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.normal,
                    fontSize: 13,
                    color: selectedItem == null
                        ? Colors.black.withOpacity(0.25)
                        : Colors.black),
              );
            },
            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: commonInputDecoration(prefixIcon),
            ),
          ),
      ],
    );
  }
}

InputDecoration commonInputDecoration(prefixIcon, {String? hintText}) {
  return InputDecoration(
    // label: Text(title),
    hintText: hintText ?? '',
    fillColor: AppColors.kTileColor,
    filled: true,
    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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
  );
}
