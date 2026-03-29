import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/location_map_service.dart';
import '../theme/app_theme.dart';

class ContactMapWidget extends StatefulWidget {
  const ContactMapWidget({super.key});

  @override
  State<ContactMapWidget> createState() => _ContactMapWidgetState();
}

class _ContactMapWidgetState extends State<ContactMapWidget> {
  final MapController _mapController = MapController();

  LatLng? _userLocation;
  bool _loadingLocation = false;
  String? _locationError;
  String? _distanceText;

  Future<void> _fetchUserLocation() async {
    setState(() {
      _loadingLocation = true;
      _locationError = null;
    });

    try {
      final Position pos = await LocationMapService.getUserLocation();
      final userLatLng = LatLng(pos.latitude, pos.longitude);
      final distKm = LocationMapService.distanceKm(
        userLatLng,
        LocationMapService.cafeLocation,
      );

      setState(() {
        _userLocation = userLatLng;
        _distanceText = distKm < 1
            ? '${(distKm * 1000).toStringAsFixed(0)} m away'
            : '${distKm.toStringAsFixed(1)} km away';
      });

      final bounds = LatLngBounds.fromPoints([
        LocationMapService.cafeLocation,
        userLatLng,
      ]);
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(60)),
      );
    } catch (e) {
      setState(() => _locationError = e.toString());
    } finally {
      setState(() => _loadingLocation = false);
    }
  }

  Future<void> _openDirections() async {
    final cafe = LocationMapService.cafeLocation;
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${cafe.latitude},${cafe.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(children: [_buildMap(), _buildTopBar(), _buildBottomBar()]),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: LocationMapService.cafeLocation,
        initialZoom: 15,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.flutter_app',
        ),

        if (_userLocation != null)
          PolylineLayer(
            polylines: [
              Polyline(
                points: [_userLocation!, LocationMapService.cafeLocation],
                strokeWidth: 3,
                color: AppTheme.burgundy.withAlpha(200),
                pattern: StrokePattern.dashed(segments: [10, 6]),
              ),
            ],
          ),

        MarkerLayer(
          markers: [
            Marker(
              point: LocationMapService.cafeLocation,
              width: 48,
              height: 56,
              child: _CafePin(),
            ),

            if (_userLocation != null)
              Marker(
                point: _userLocation!,
                width: 40,
                height: 40,
                child: _UserPin(),
              ),
          ],
        ),

        const RichAttributionWidget(
          attributions: [TextSourceAttribution('OpenStreetMap contributors')],
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 10,
      right: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _MapButton(
            icon: _loadingLocation
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.white,
                    ),
                  )
                : const Icon(
                    Icons.my_location,
                    color: AppTheme.white,
                    size: 20,
                  ),
            onTap: _loadingLocation ? null : _fetchUserLocation,
            tooltip: 'Show my location',
          ),

          if (_locationError != null) ...[
            const SizedBox(height: 8),
            _ErrorBubble(message: _locationError!),
          ],

          if (_distanceText != null) ...[
            const SizedBox(height: 8),
            _InfoBubble(text: _distanceText!),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      bottom: 10,
      left: 10,
      child: _MapButton(
        icon: const Icon(Icons.directions, color: AppTheme.white, size: 20),
        label: 'Get Directions',
        onTap: _openDirections,
        tooltip: 'Open in Maps',
      ),
    );
  }
}

class _CafePin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppTheme.burgundy,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.white, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(6),
          child: const Icon(Icons.local_cafe, color: AppTheme.white, size: 18),
        ),
        CustomPaint(
          size: const Size(12, 8),
          painter: _TrianglePainter(color: AppTheme.burgundy),
        ),
      ],
    );
  }
}

class _UserPin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.white, width: 2.5),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: const Icon(Icons.person, color: AppTheme.white, size: 20),
    );
  }
}

class _MapButton extends StatelessWidget {
  final Widget icon;
  final String? label;
  final VoidCallback? onTap;
  final String tooltip;

  const _MapButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppTheme.charcoal.withAlpha(220),
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: label != null ? 14 : 10,
              vertical: 10,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                if (label != null) ...[
                  const SizedBox(width: 6),
                  Text(
                    label!,
                    style: const TextStyle(
                      color: AppTheme.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoBubble extends StatelessWidget {
  final String text;
  const _InfoBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.charcoal.withAlpha(220),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ErrorBubble extends StatelessWidget {
  final String message;
  const _ErrorBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red.shade700.withAlpha(220),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: const TextStyle(color: AppTheme.white, fontSize: 11),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  const _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrianglePainter old) => old.color != color;
}
