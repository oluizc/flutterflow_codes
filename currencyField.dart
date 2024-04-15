// dependencie: currency_text_input_formatter: ^2.2.0

import 'dart:async';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/services.dart';

class CurrencyTextField extends StatefulWidget {
  const CurrencyTextField({
    super.key,
    this.width,
    this.height,
    required this.valor,
    required this.colorText,
    required this.fontSize,
    required this.borderRadius,
    required this.borderColor,
    required this.borderColorFocus,
    required this.onChangeAction,
  });

  final double? width;
  final double? height;
  final double valor;
  final Color colorText;
  final double fontSize;
  final double borderRadius;
  final Color borderColor;
  final Color borderColorFocus;
  final Future Function(double valor) onChangeAction;

  @override
  _CurrencyTextFieldState createState() => _CurrencyTextFieldState();

  String _formatCurrencyValue(double value) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: '').format(value);
  }
}

class _CurrencyTextFieldState extends State<CurrencyTextField> {
  bool isHovered = false;
  late Timer _debounce;

  @override
  void initState() {
    super.initState();
    _debounce = Timer(Duration(milliseconds: 1500), () {});
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: widget._formatCurrencyValue(widget.valor),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        CurrencyTextInputFormatter.currency(
          locale: 'pt_BR',
          decimalDigits: 2,
          symbol: '',
          enableNegative: false,
        ),
        LengthLimitingTextInputFormatter(16),
      ],
      textAlign: TextAlign.right,
      style: TextStyle(
        fontWeight: FontWeight.normal,
        color: widget.colorText,
        fontSize: widget.fontSize,
      ),
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: widget.borderColor, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: widget.borderColorFocus),
        ),
        filled: false,
      ),
      onChanged: (text) {
        _debounce.cancel();
        _debounce = Timer(Duration(milliseconds: 1500), () {
          final double parsedValue = double.tryParse(
                text.replaceAll('.', '').replaceFirst(RegExp(r','), '.'),
              ) ??
              0.0;
          widget.onChangeAction(parsedValue);
        });
      },
    );
  }
}
