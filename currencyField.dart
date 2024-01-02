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
    required this.borderColor,
    required this.borderColorFocus,
    required this.onChangeAction,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String valor;
  final Color colorText;
  final double fontSize;
  final double borderRadius;
  final Color borderColor;
  final Color borderColorFocus;
  final Future<dynamic> Function() onChangeAction;

  @override
  _CurrencyTextFieldState createState() => _CurrencyTextFieldState();
}

class _CurrencyTextFieldState extends State<CurrencyTextField> {
  bool isHovered = false;

  @override
  void initState() {
    super.initState();

    // Chamado quando o widget é inserido na árvore de widgets pela primeira vez, atualiza o valor do AppState. *Alterar o nome para o seu AppState.
    FFAppState().valorCurrencyField1 = widget.valor;
  }

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
        print(text);
        //*Alterar o nome para o seu AppState.
        FFAppState().valorCurrencyField1 = text;
        //Ação para executar no onChange do textField. Ex.: capturar o valor do app state e colocar em outro state (page ou component). 
        widget.onChangeAction();
      },
    );
  }
}
