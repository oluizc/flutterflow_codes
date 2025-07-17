// Lê um arquivo FFUploadedFile (vídeo ou imagem) e retorna os dados deste arquivo.


import 'dart:convert';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';

Future<dynamic> returnMediaData(
  FFUploadedFile? media,
  double? maxMBAllowed,
  int? maxVideoDurationInSeconds,
) async {
  if (media == null) {
    return {
      'base64': '',
      'bytes': null, // Adicionado
      'fileSize': '',
      'fileName': '',
      'fileType': '',
      'error': 'no_file',
    };
  }

  // Nome do arquivo, bytes e extensões para distinguir vídeo
  final fileName = media.name ?? '';
  final lowerName = fileName.toLowerCase();
  final fileSizeInBytes = media.bytes?.length ?? 0;

  // Função auxiliar para formatar bytes em B, KB, MB, GB...
  String formatBytes(int bytes, [int decimals = 2]) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    int i = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  // Exemplo simples para classificar se é vídeo ou imagem
  final videoExtensions = ['.mp4', '.mov', '.mkv', '.avi', '.wmv', '.m4v'];
  final isVideo = videoExtensions.any((ext) => lowerName.endsWith(ext));
  final fileType = isVideo ? 'video' : 'image';

  // Formatamos o tamanho do arquivo
  final fileSizeString = formatBytes(fileSizeInBytes, 2);

  // 1) Verifica limite de tamanho em MB
  if (maxMBAllowed != null && maxMBAllowed > 0) {
    // Converte limite para bytes
    final maxBytes = (maxMBAllowed * 1024 * 1024).toInt();
    if (fileSizeInBytes > maxBytes) {
      return {
        'base64': '',
        'bytes': null, // Adicionado
        'fileSize': fileSizeString, // Ex: "2.34 MB"
        'fileName': fileName,
        'fileType': fileType,
        'error': 'size_exceeded',
      };
    }
  }

  // 2) Se for vídeo e tiver limite de duração, checa duração
  if (isVideo &&
      maxVideoDurationInSeconds != null &&
      maxVideoDurationInSeconds > 0) {
    try {
      // Cria arquivo temporário para poder usar VideoPlayerController
      final tempDir = await getTemporaryDirectory();
      final tempFilePath =
          '${tempDir.path}/temp_${DateTime.now().millisecondsSinceEpoch}$lowerName';
      final tempFile = File(tempFilePath);

      // Escreve bytes no arquivo temporário
      await tempFile.writeAsBytes(media.bytes!);

      if (!tempFile.existsSync()) {
        return {
          'base64': '',
          'bytes': null, // Adicionado
          'fileSize': fileSizeString,
          'fileName': fileName,
          'fileType': fileType,
          'error': 'video_not_found',
        };
      }

      // Inicia o VideoPlayerController para ler a duração
      final controller = VideoPlayerController.file(tempFile);
      await controller.initialize();
      final duration = controller.value.duration;
      await controller.dispose();

      // Checa limite de duração
      if (duration.inSeconds > maxVideoDurationInSeconds) {
        await tempFile.delete();
        return {
          'base64': '',
          'bytes': null, // Adicionado
          'fileSize': fileSizeString,
          'fileName': fileName,
          'fileType': fileType,
          'error': 'video_duration_exceeded',
        };
      }

      // Deleta o arquivo temporário pois deu tudo certo
      await tempFile.delete();
    } catch (e) {
      return {
        'base64': '',
        'bytes': null, // Adicionado
        'fileSize': fileSizeString,
        'fileName': fileName,
        'fileType': fileType,
        'error': 'video_duration_check_error',
      };
    }
  }

  // 3) Converte para Base64
  final base64String = (media.bytes != null) ? base64Encode(media.bytes!) : '';

  // 4) Retorna JSON final
  return {
    'base64': base64String,
    'bytes': media.bytes, // Adicionado - retorna os bytes diretamente
    'fileSize': fileSizeString, // ex: "123 B", "45.67 KB", "12.34 MB"
    'fileName': fileName,
    'fileType': fileType,
    'error': null, // sem erro
  };
}
