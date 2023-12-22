// dependencie: currency_text_input_formatter: ^2.1.10

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/services.dart';

class CurrencyTextField extends StatefulWidget {
  const CurrencyTextField({
    Key? key,
    this.width,
    this.height,
    required this.valor,
    required this.colorText,
    required this.fontSize,
    required this.borderRadius,
    required this.filledColor,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String valor;
  final Color colorText;
  final double fontSize;
  final double borderRadius;
  final Color filledColor;

  @override
  _CurrencyTextFieldState createState() => _CurrencyTextFieldState();
}

class _CurrencyTextFieldState extends State<CurrencyTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: widget.valor,
      keyboardType: TextInputType.number,
      inputFormatters: [
        CurrencyTextInputFormatter(
          locale: 'pt_BR',
          decimalDigits: 2,
          symbol: 'R\$',
          enableNegative: false,
        ),
        LengthLimitingTextInputFormatter(16),
      ],
      style: TextStyle(
        fontWeight: FontWeight.normal,
        color: widget.colorText,
        fontSize: widget.fontSize,
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: widget.filledColor,
      ),
      onChanged: (text) {
        print("valor fomartValue");
        print(text);
        FFAppState().valueFormat = text;
      },
    );
  }
}
