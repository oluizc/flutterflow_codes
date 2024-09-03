// Gera uma imagem e compartilha no dispositivo do user a partir do código do widget.

import 'dart:typed_data';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<void> captureAndShareImage(
  FFUploadedFile localImagem,
  String nomeArtista,
) async {
  try {
    // Captura o widget como uma imagem
    Uint8List? image = await ScreenshotController().captureFromWidget(
      Builder(
        builder: (BuildContext context) {
          return MediaQuery(
            data: MediaQueryData.fromWindow(WidgetsBinding.instance.window),
            child: Material(
              child: Container(
                width: 400.0,
                height: 550.0,
                decoration: BoxDecoration(
                  color: Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: Color(0xFFF0F0F0),
                  ),
                ),
                child: Stack(
                  alignment: AlignmentDirectional(0.0, -1.0),
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(
                        'assets/images/bg_certificado_creevo.png',
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 32.0, 0.0, 32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFFFFFFF),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 16.0,
                                    color: Color(0x0D000000),
                                    offset: Offset(0.0, 0.0),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: Color(0xFFF0F0F0),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.memory(
                                  localImagem.bytes ?? Uint8List.fromList([]),
                                  width: 330.0,
                                  height: 185.0,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 300.0,
                            decoration: BoxDecoration(),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Você deu um show de criatividade!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Exo 2',
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFFF9500),
                                    fontSize: 20.0,
                                  ),
                                ),
                                Text(
                                  nomeArtista,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Exo 2',
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF01CCD2),
                                    fontSize: 16.0,
                                  ),
                                ),
                                Text(
                                  'Seu desenho ficou incrível!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Exo 2',
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFFF9500),
                                    fontSize: 20.0,
                                  ),
                                ),
                              ].divide(SizedBox(height: 8.0)),
                            ),
                          ),
                        ].divide(SizedBox(height: 16.0)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );

    if (image != null) {
      // Nome do arquivo com base no nome do artista
      final safeArtistName =
          nomeArtista.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');
      final directory = (await getTemporaryDirectory()).path;
      final imagePath = '$directory/certificado_creevo_$safeArtistName.png';
      File imgFile = File(imagePath);
      imgFile.writeAsBytesSync(image);

      // Compartilha a imagem usando share_plus, sem texto adicional
      await Share.shareXFiles([XFile(imagePath)]);

      print("Compartilhamento iniciado: $imagePath");
    } else {
      print("Erro ao capturar a imagem");
    }
  } catch (e) {
    print("Erro ao capturar a imagem: $e");
  }
}
