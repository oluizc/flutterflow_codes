import 'dart:typed_data';
import 'package:crop_your_image/crop_your_image.dart';

class CropWidget extends StatefulWidget {
  const CropWidget({
    Key? key,
    this.width,
    this.height,
    required this.uploadedImage,
    required this.onCrop,
    required this.onReset,
    required this.primaryColor,
    this.borderRadius = 0.0, // Parâmetro para bordas arredondadas
  }) : super(key: key);

  final double? width;
  final double? height;
  final FFUploadedFile uploadedImage; // Imagem recebida
  final Future Function(FFUploadedFile croppedFile) onCrop; // Ação para corte
  final Future Function() onReset; // Ação para redefinir
  final Color primaryColor; // Cor principal para destacar proporções
  final double borderRadius; // Raio das bordas

  @override
  State<CropWidget> createState() => _CropWidgetState();
}

class _CropWidgetState extends State<CropWidget> {
  final CropController _cropController = CropController();
  Uint8List? imageBytes; // Armazena os bytes da imagem carregada
  bool hasCropped = false; // Controla se a imagem foi cortada
  double aspectRatio = 1.0; // Proporção padrão (1:1)

  @override
  void initState() {
    super.initState();
    _loadImage(); // Carrega a imagem ao iniciar
  }

  void _loadImage() {
    setState(() {
      imageBytes = widget.uploadedImage.bytes; // Carrega os bytes da imagem
      hasCropped = false; // Reseta o estado de corte
    });
  }

  Future<void> _cropImage() async {
    _cropController.crop();
  }

  Future<void> _onCropped(Uint8List croppedBytes) async {
    final FFUploadedFile croppedFile = FFUploadedFile(
      name: widget.uploadedImage.name,
      bytes: croppedBytes,
      height: widget.uploadedImage.height,
      width: widget.uploadedImage.width,
    );

    await widget
        .onCrop(croppedFile); // Chama a ação passada com a imagem cortada

    setState(() {
      imageBytes = croppedBytes; // Atualiza a exibição com a imagem cortada
      hasCropped = true; // Marca como cortada
    });
  }

  Future<void> _resetCrop() async {
    await widget.onReset(); // Chama a ação de redefinir passada pelo parâmetro
    _loadImage(); // Restaura a imagem original
  }

  void _setAspectRatio(double ratio) {
    setState(() {
      aspectRatio = ratio;
    });
    _cropController.aspectRatio = ratio; // Atualiza o aspecto do controlador
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A), // Fundo cinza escuro do widget
        borderRadius:
            BorderRadius.circular(widget.borderRadius), // Borda arredondada
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
            widget.borderRadius), // Aplica borda no conteúdo
        child: Column(
          children: [
            // Área de recorte
            Expanded(
              child: Container(
                width: double.infinity,
                color: const Color(0xFFECECEC), // Fundo da área de recorte
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (!hasCropped)
                      Crop(
                        image: imageBytes!,
                        controller: _cropController,
                        onCropped: _onCropped,
                        initialSize: 0.9,
                        aspectRatio:
                            aspectRatio, // Aplica a proporção selecionada
                      ),
                    if (hasCropped)
                      Center(
                        child: Image.memory(
                          imageBytes!,
                          fit: BoxFit.contain,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Divider entre a área da imagem e a área de serviço
            const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFECECEC),
            ),
            // Barra inferior com proporções e botão de ação
            Container(
              width: double.infinity,
              color: Colors.white, // Fundo branco para a área de serviço
              child: Column(
                children: [
                  // Seleção de proporções
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _aspectRatioButton('5:4', 5 / 4),
                        _aspectRatioButton('1:1', 1.0),
                        _aspectRatioButton('4:5', 4 / 5),
                      ],
                    ),
                  ),
                  // Divider entre proporções e botão de ação
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFECECEC),
                    ),
                  ),
                  // Botão de ação centralizado
                  Center(
                    child: _actionButton(
                      icon: hasCropped ? Icons.refresh : Icons.check,
                      color: hasCropped ? Colors.red : widget.primaryColor,
                      onPressed: hasCropped ? _resetCrop : _cropImage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _aspectRatioButton(String label, double ratio) {
    return GestureDetector(
      onTap: () => _setAspectRatio(ratio),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: aspectRatio == ratio ? widget.primaryColor : Colors.black,
              fontSize: 16, // Fonte maior para destaque
              fontWeight:
                  aspectRatio == ratio ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, color: color, size: 36), // Botão maior para destaque
      onPressed: onPressed,
    );
  }
}
