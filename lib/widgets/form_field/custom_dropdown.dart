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
  const CustomDropdown({
    Key? key,
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
    this.enabled = true, this.hintText, this.titleEnabled=true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var isDarkMode = context.isDarkMode;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       if(titleEnabled) required
            ? RichText(
                text: TextSpan(
                    text: title,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontWeight: FontWeight.w300,fontSize: 14,color: Colors.black),
                    children: const [
                      TextSpan(text: ' *', style: TextStyle(color: Colors.red))
                    ]),
              )
            : Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w300,fontSize: 16),
              ),
        //Global Drop Down
        if(titleEnabled)SizedBox(height: 8,),
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
          popupProps: PopupProps.menu(
              showSearchBox: false,
              menuProps: MenuProps(
                elevation: 16,
              )),
          dropdownBuilder: (context, selectedItem) {
            return Text(
              selectedItem ?? "$hintText",
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .displaySmall
                  ?.copyWith(fontWeight: FontWeight.w300, fontSize: 13,color: Colors.black.withOpacity(0.7)),
            );
          },
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              // label: Text(title),
              fillColor: AppColors.kTileColor,
              filled: true,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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
              prefixIcon: Icon(prefixIcon,
                  size: 25, color: Colors.black.withOpacity(0.6)),
            ),
          ),
        ),
      ],
    );
  }
}
