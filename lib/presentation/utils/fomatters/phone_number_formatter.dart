import 'package:flutter/services.dart';

class PeruPhoneNumberFormatter extends TextInputFormatter {
  final bool includeCountryCode;

  PeruPhoneNumberFormatter({this.includeCountryCode = false});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;

    // Eliminar todo excepto números
    String digits = text.replaceAll(RegExp(r'[^0-9]'), '');

    // Limitar a 9 dígitos
    if (digits.length > 9) digits = digits.substring(0, 9);

    // Construir texto formateado
    String formatted = digits;

    if (digits.isNotEmpty) {
      if (digits.length <= 3) {
        formatted = digits;
      } else if (digits.length <= 6) {
        formatted = '${digits.substring(0, 3)} ${digits.substring(3)}';
      } else {
        formatted =
            '${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6)}';
      }
    }

    // Agregar +51 solo si es necesario y no está ya presente
    if (includeCountryCode) {
      if (!formatted.startsWith('+51')) {
        formatted = '+51 $formatted';
      }
    }

    // Ajustar cursor
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Validación: 9 dígitos
bool isValidPeruPhone(String text) {
  final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
  return digits.length == 9;
}
