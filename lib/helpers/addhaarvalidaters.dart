import 'package:flutter/services.dart';

class AadhaarNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String formattedValue = _formatAadhaarNumber(newValue.text);

    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }

  String _formatAadhaarNumber(String input) {
    // Remove non-digits except spaces
    input = input.replaceAll(RegExp(r'[^\d\s]'), '');

    // Remove leading spaces
    input = input.trimLeft();

    if (input.length > 12) {
      input = input.substring(0, 12); // Trim input to 12 characters
    }

    // Add spaces for better readability (e.g., 1234 5678 9012)
    if (input.length > 4) {
      input = input.substring(0, 4) + input.substring(4);
    }
    if (input.length > 9) {
      input = input.substring(0, 9) + input.substring(9);
    }

    return input;
  }
}
