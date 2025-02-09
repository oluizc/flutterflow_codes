import 'package:markdown_toolbar/markdown_toolbar.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MarkDownEditor extends StatefulWidget {
  const MarkDownEditor({
    super.key,
    this.width,
    this.height,
    required this.hint,
    this.initialValue,
    this.onChange,
  });

  final double? width;
  final double? height;
  final String hint;
  final String? initialValue;
  final Future Function(String? inputValue)? onChange;

  @override
  State<MarkDownEditor> createState() => _MarkDownEditorState();
}

class _MarkDownEditorState extends State<MarkDownEditor> {
  late TextEditingController _controller;
  bool _isPreview = false; // Alternar entre edição e visualização

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? 400, // Altura padrão se não for especificada
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.transparent), // Borda transparente
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Barra de ferramentas Markdown (visível apenas no modo edição)
          if (!_isPreview)
            MarkdownToolbar(
              controller: _controller,
              useIncludedTextField: false,
            ),

          // Campo de entrada ou visualização
          Expanded(
            child: _isPreview
                ? Markdown(
                    data: _controller.text, // Exibe o Markdown formatado
                    padding: EdgeInsets.all(8),
                  )
                : TextField(
                    controller: _controller,
                    maxLines: null,
                    onChanged: (value) {
                      if (widget.onChange != null) {
                        widget.onChange!(value);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: widget.hint,
                      border: InputBorder.none, // Remove a borda do TextField
                    ),
                  ),
          ),

          // Botão de alternância (ícone neutro)
          Align(
            alignment: Alignment.bottomRight,
            child: IconButton(
              onPressed: () {
                setState(() {
                  _isPreview = !_isPreview;
                });
              },
              icon: Icon(
                _isPreview
                    ? Icons.edit
                    : Icons.visibility, // Alterna entre ✏ e 👁
                color: Colors.grey[700], // Cor neutra como os botões da toolbar
              ),
            ),
          ),
        ],
      ),
    );
  }
}
