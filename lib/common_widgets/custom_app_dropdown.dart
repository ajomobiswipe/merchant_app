import 'package:flutter/material.dart';
import 'package:sifr_latest/config/app_color.dart';
import 'package:sifr_latest/helpers/default_height.dart';
import 'package:sifr_latest/widgets/custom_text_widget.dart';

// class CustomAppDropdown extends StatefulWidget {
//   final Widget hint;
//   final String selected;
//   final Function(String?)? onChanged;
//   final List<DropdownMenuItem<String>> items;
//   final String? Function(String?)? validator;
//   CustomAppDropdown(
//       {super.key,
//       required this.hint,
//       required this.selected,
//       required this.items,
//       this.onChanged,
//       this.validator});

//   @override
//   State<CustomAppDropdown> createState() => _CustomAppDropdownState();
// }

// class _CustomAppDropdownState extends State<CustomAppDropdown> {
//   @override
//   Widget build(BuildContext context) {
//     return DropdownButtonFormField<String>(
//       hint: widget.hint,
//       value: widget.selected,
//       onChanged: widget.onChanged,
//       items: widget.items,
//       validator: widget.validator,
//       decoration: InputDecoration(
//         border: InputBorder.none,
//         errorBorder: InputBorder.none,
//         enabledBorder: InputBorder.none,
//         focusedBorder: InputBorder.none,
//         focusedErrorBorder: InputBorder.none,
//       ),
//     );
//   }
// }
class CustomAppDropdown<T> extends StatelessWidget {
  final String label;
  final String hint;
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;

  const CustomAppDropdown({super.key, 
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextWidget(text: label, fontWeight: FontWeight.bold, size: 14),
        defaultHeight(8),
        DropdownButtonFormField<T>(
          hint: CustomTextWidget(
              text: hint, size: 12, color: Colors.grey.shade700),
          value: value,
          onChanged: onChanged,
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: CustomTextWidget(
                  text: item.toString(), size: 12, color: Colors.grey.shade600),
            );
          }).toList(),
          validator: validator,
          icon: const Icon(
            Icons.keyboard_arrow_down_sharp,
            color: AppColors.kPrimaryColor,
          ),
          decoration: const InputDecoration(
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            border: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            fillColor: AppColors.kTileColor,
            filled: true,
            hintStyle: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
