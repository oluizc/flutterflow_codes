import 'package:flutter_map/flutter_map.dart';
// Importação explícita com alias para evitar conflitos
import 'package:latlong2/latlong.dart' as latlong2;

class SimpleMap extends StatefulWidget {
  const SimpleMap({
    super.key,
    this.width,
    this.height,
    this.lat,
    required this.lng,
  });
  final double? width;
  final double? height;
  final String? lat;
  final String lng;
  @override
  State<SimpleMap> createState() => _SimpleMapState();
}

class _SimpleMapState extends State<SimpleMap> {
  final String pinImageUrl =
      'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/pure-pilates-1yliq7/assets/ahyay0xs1osr/pin_map_purepilates.png';

  @override
  Widget build(BuildContext context) {
    // Converter strings de lat/lng para double
    // Caso lat seja nulo, usamos um valor padrão
    final double latitude =
        widget.lat != null ? double.tryParse(widget.lat!) ?? 0.0 : 0.0;
    final double longitude = double.tryParse(widget.lng) ?? 0.0;

    // Usar largura e altura fornecidas ou preencher o espaço disponível
    final double mapWidth = widget.width ?? double.infinity;
    final double mapHeight = widget.height ?? 300.0;

    return SizedBox(
      width: mapWidth,
      height: mapHeight,
      child: FlutterMap(
        mapController: MapController(),
        options: MapOptions(
          initialCenter: latlong2.LatLng(latitude, longitude),
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: latlong2.LatLng(latitude, longitude),
                width: 50,
                height: 50,
                child: Image.network(
                  pinImageUrl,
                  width: 50,
                  height: 50,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
