import 'package:flutter/services.dart';

class PanNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Get the current input text
    String newText = newValue.text;

    // Remove any non-alphanumeric characters and spaces
    newText = newText.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

    // Ensure that the length does not exceed 10 characters
    if (newText.length > 10) {
      newText = newText.substring(0, 10);
    }

    // Format the text as ABCDE1234F
    StringBuffer formattedText = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      if (i < 5) {
        // Allow only letters for the first 5 characters and convert to uppercase
        formattedText.write(
            newText[i].replaceAll(RegExp(r'[^a-zA-Z]'), '').toUpperCase());
      } else if (i < 9) {
        // Allow only numbers for the next 4 characters
        formattedText.write(newText[i].replaceAll(RegExp(r'[^0-9]'), ''));
      } else {
        // Allow only letters for the final character and convert to uppercase
        formattedText.write(
            newText[i].replaceAll(RegExp(r'[^a-zA-Z]'), '').toUpperCase());
      }
    }

    // Update the text editing value with the formatted text
    return TextEditingValue(
      text: formattedText.toString(),
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
