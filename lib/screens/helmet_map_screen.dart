import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import '../models/helmet_model.dart';

class HelmetMapScreen extends StatefulWidget {
  final Helmet helmet;

  const HelmetMapScreen({super.key, required this.helmet});

  @override
  State<HelmetMapScreen> createState() => _HelmetMapScreenState();
}

class _HelmetMapScreenState extends State<HelmetMapScreen> {
  GoogleMapController? _mapController;

  // Cairo as fallback if no GPS data
  static const _fallbackLat = 30.0444;
  static const _fallbackLon = 31.2357;

  LatLng get _helmetLocation => LatLng(
        widget.helmet.latitude ?? _fallbackLat,
        widget.helmet.longitude ?? _fallbackLon,
      );

  bool get _hasRealLocation =>
      widget.helmet.latitude != null && widget.helmet.longitude != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('helmet_details.location'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            tooltip: 'Center on helmet',
            onPressed: () {
              _mapController?.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(target: _helmetLocation, zoom: 16),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _helmetLocation,
              zoom: 15,
            ),
            onMapCreated: (controller) => _mapController = controller,
            markers: {
              Marker(
                markerId: MarkerId(widget.helmet.id),
                position: _helmetLocation,
                infoWindow: InfoWindow(
                  title: 'Helmet ${widget.helmet.id}',
                  snippet: widget.helmet.workerName != null
                      ? 'Worker: ${widget.helmet.workerName}'
                      : widget.helmet.location ?? '',
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  widget.helmet.status.toLowerCase() == 'active'
                      ? BitmapDescriptor.hueGreen
                      : BitmapDescriptor.hueOrange,
                ),
              ),
            },
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
          ),

          // Info overlay at bottom
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          theme.colorScheme.primary.withOpacity(0.12),
                      child: Icon(Icons.engineering,
                          color: theme.colorScheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Helmet ${widget.helmet.id}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          if (widget.helmet.workerName != null)
                            Text(widget.helmet.workerName!,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 13)),
                          if (!_hasRealLocation)
                            const Text(
                              '⚠️ No GPS data — showing default location',
                              style: TextStyle(
                                  color: Colors.orange, fontSize: 12),
                            )
                          else
                            Text(
                              '📍 ${_helmetLocation.latitude.toStringAsFixed(4)}, '
                              '${_helmetLocation.longitude.toStringAsFixed(4)}',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.helmet.status.toLowerCase() == 'active'
                            ? Colors.green.withOpacity(0.12)
                            : Colors.orange.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              widget.helmet.status.toLowerCase() == 'active'
                                  ? Colors.green
                                  : Colors.orange,
                        ),
                      ),
                      child: Text(
                        widget.helmet.status,
                        style: TextStyle(
                          color:
                              widget.helmet.status.toLowerCase() == 'active'
                                  ? Colors.green
                                  : Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
