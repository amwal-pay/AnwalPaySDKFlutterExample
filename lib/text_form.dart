import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextForm extends StatelessWidget {
  final String title;
  final String? initialValue;
  final TextEditingController controller;
  final bool isNumeric;
  final int? maxAmount;
  final int? maxLength;
  final String? Function(String?)? validator;

  const TextForm({
    Key? key,
    this.validator,
    required this.title,
    this.initialValue,
    required this.controller,
    this.isNumeric = false,
    this.maxLength,
    this.maxAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        const SizedBox(height: 8),
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          initialValue: initialValue,
          controller: controller,
          maxLength: maxLength,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Required Field';
            } else if (validator != null) {
              return validator!(value);
            } else {
              return null;
            }
          },
          inputFormatters: [
            if (isNumeric)
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            if (isNumeric && maxAmount != null)
              _InputAmountFormatter(maxAmount!),
          ],
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

class _InputAmountFormatter extends TextInputFormatter {
  final int maxAmount;

  const _InputAmountFormatter(this.maxAmount);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newValueOrNull = double.tryParse(newValue.text) ?? 1;
    if (newValueOrNull > maxAmount) {
      return TextEditingValue(
        text: maxAmount.toString(),
      );
    } else {
      return TextEditingValue(
        text: newValue.text.replaceAll(RegExp(r'^0+(?=.)'), ''),
      );
    }
  }
}
