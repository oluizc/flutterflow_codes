import 'dart:io';
import 'dart:typed_data';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';

/// Reproduz arquivo de media (video ou imagem) em bytes. Aceita um json no seguinte formato:
///
/// { 'base64': '', 'bytes': null, 'fileSize': '', 'fileName': '', 'fileType':
/// '', 'error': 'no_file', }


class MediaByte extends StatefulWidget {
  const MediaByte({
    super.key,
    this.width,
    this.height,
    this.mediaData,
  });

  final double? width;
  final double? height;
  final dynamic mediaData;

  @override
  State<MediaByte> createState() => _MediaByteState();
}

class _MediaByteState extends State<MediaByte> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeMedia();
  }

  @override
  void didUpdateWidget(MediaByte oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Se o mediaData mudou, reinicializa
    if (widget.mediaData != oldWidget.mediaData) {
      _disposeVideo();
      _initializeMedia();
    }
  }

  Future<void> _initializeMedia() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Verifica se mediaData é válido
    if (widget.mediaData == null) {
      setState(() {
        _error = 'Nenhuma mídia fornecida';
        _isLoading = false;
      });
      return;
    }

    // Verifica se tem erro no mediaData
    final error = widget.mediaData['error'];
    if (error != null && error != 'null') {
      setState(() {
        _error = _getErrorMessage(error);
        _isLoading = false;
      });
      return;
    }

    // Verifica se tem bytes
    final bytes = widget.mediaData['bytes'];
    if (bytes == null) {
      setState(() {
        _error = 'Dados da mídia não encontrados';
        _isLoading = false;
      });
      return;
    }

    // Pega o tipo de arquivo
    final fileType = widget.mediaData['fileType'] ?? '';

    // Se for vídeo, inicializa o controller
    if (fileType == 'video') {
      await _initializeVideo(bytes);
    } else {
      // Se for imagem, apenas marca como carregado
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _initializeVideo(List<int> bytes) async {
    try {
      // Converte para Uint8List se necessário
      final uint8Bytes = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);

      // Cria arquivo temporário
      final tempDir = await getTemporaryDirectory();
      final fileName = widget.mediaData['fileName'] ?? 'temp_video.mp4';
      final tempFile = File(
          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}_$fileName');
      await tempFile.writeAsBytes(uint8Bytes);

      // Inicializa o VideoPlayerController
      _videoController = VideoPlayerController.file(tempFile);
      await _videoController!.initialize();

      // Adiciona listener para deletar o arquivo quando terminar
      _videoController!.addListener(() {
        if (_videoController!.value.position ==
                _videoController!.value.duration &&
            _videoController!.value.duration.inSeconds > 0) {
          tempFile.deleteSync();
        }
      });

      setState(() {
        _isVideoInitialized = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar vídeo: $e';
        _isLoading = false;
      });
    }
  }

  void _disposeVideo() {
    _videoController?.dispose();
    _videoController = null;
    _isVideoInitialized = false;
  }

  @override
  void dispose() {
    _disposeVideo();
    super.dispose();
  }

  String _getErrorMessage(String error) {
    switch (error) {
      case 'no_file':
        return 'Nenhum arquivo selecionado';
      case 'size_exceeded':
        return 'Arquivo muito grande';
      case 'video_duration_exceeded':
        return 'Vídeo muito longo';
      case 'video_not_found':
        return 'Vídeo não encontrado';
      case 'video_duration_check_error':
        return 'Erro ao verificar duração do vídeo';
      default:
        return 'Erro desconhecido';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Se está carregando
    if (_isLoading) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Se tem erro
    if (_error != null) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red[300]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red[300],
              size: 48,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red[700],
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Verifica o tipo de mídia
    final fileType = widget.mediaData['fileType'] ?? '';
    final bytes = widget.mediaData['bytes'];

    if (bytes == null) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text('Dados não encontrados'),
        ),
      );
    }

    // Se for vídeo
    if (fileType == 'video' &&
        _isVideoInitialized &&
        _videoController != null) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
              _VideoControls(controller: _videoController!),
            ],
          ),
        ),
      );
    }

    // Se for imagem
    final uint8Bytes = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          uint8Bytes,
          width: widget.width,
          height: widget.height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: widget.width,
              height: widget.height,
              color: Colors.grey[200],
              child: const Center(
                child: Icon(
                  Icons.broken_image,
                  color: Colors.grey,
                  size: 48,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Widget de controles para o vídeo
class _VideoControls extends StatefulWidget {
  final VideoPlayerController controller;

  const _VideoControls({required this.controller});

  @override
  State<_VideoControls> createState() => _VideoControlsState();
}

class _VideoControlsState extends State<_VideoControls> {
  bool _isPlaying = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_videoListener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_videoListener);
    super.dispose();
  }

  void _videoListener() {
    if (mounted) {
      setState(() {
        _isPlaying = widget.controller.value.isPlaying;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showControls = !_showControls;
        });

        // Auto-esconde os controles após 3 segundos se estiver tocando
        if (_showControls && _isPlaying) {
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted && _isPlaying) {
              setState(() {
                _showControls = false;
              });
            }
          });
        }
      },
      child: Container(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Overlay escuro quando mostra controles
            if (_showControls)
              Container(
                color: Colors.black.withOpacity(0.3),
              ),

            // Botão play/pause
            if (_showControls)
              Center(
                child: IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 50,
                  ),
                  onPressed: () {
                    setState(() {
                      if (_isPlaying) {
                        widget.controller.pause();
                      } else {
                        widget.controller.play();
                        // Auto-esconde após começar a tocar
                        Future.delayed(const Duration(seconds: 2), () {
                          if (mounted && widget.controller.value.isPlaying) {
                            setState(() {
                              _showControls = false;
                            });
                          }
                        });
                      }
                    });
                  },
                ),
              ),

            // Barra de progresso
            if (_showControls)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: VideoProgressIndicator(
                  widget.controller,
                  allowScrubbing: true,
                  padding: const EdgeInsets.all(16),
                  colors: VideoProgressColors(
                    playedColor: Theme.of(context).primaryColor,
                    bufferedColor: Colors.white.withOpacity(0.3),
                    backgroundColor: Colors.white.withOpacity(0.2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
