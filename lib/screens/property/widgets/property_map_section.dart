import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:latlong2/latlong.dart';
import '../../../models/property_model.dart';
import '../../../theme/app_theme.dart';

class PropertyMapSection extends StatelessWidget {
  final Property property;
  final MapController mapController;
  final bool isSatelliteMode;
  final VoidCallback onToggleSatellite;
  final bool isDark;

  const PropertyMapSection({
    super.key,
    required this.property,
    required this.mapController,
    required this.isSatelliteMode,
    required this.onToggleSatellite,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Where you'll be",
          style: TextStyle(
            fontFamily: 'Cabinet Grotesk',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "${property.area}, ${property.city}, ${property.state}, Nigeria",
          style: TextStyle(
            fontSize: 14,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 14),

        // Map Container with custom marker and on-screen controls
        Container(
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: LatLng(
                      property.latitude,
                      property.longitude,
                    ),
                    initialZoom: 15.0,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: isSatelliteMode
                          ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                          : 'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png',
                      userAgentPackageName: 'com.homehub.app',
                    ),
                    if (isSatelliteMode)
                      TileLayer(
                        urlTemplate:
                            'https://basemaps.cartocdn.com/rastertiles/voyager_only_labels/{z}/{x}/{y}@2x.png',
                        userAgentPackageName: 'com.homehub.app',
                      ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(
                            property.latitude,
                            property.longitude,
                          ),
                          width: 50,
                          height: 50,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkSurface
                                  : Colors.black87,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                LucideIcons.house,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Map Controls Overlay (Layer, Zoom In, Zoom Out, Locate)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildMapControlButton(
                        icon: LucideIcons.layers,
                        active: isSatelliteMode,
                        onTap: onToggleSatellite,
                      ),
                      const SizedBox(height: 6),
                      _buildMapControlButton(
                        icon: LucideIcons.plus,
                        onTap: () {
                          final zoom = mapController.camera.zoom;
                          mapController.move(
                            mapController.camera.center,
                            zoom + 1,
                          );
                        },
                      ),
                      const SizedBox(height: 6),
                      _buildMapControlButton(
                        icon: LucideIcons.minus,
                        onTap: () {
                          final zoom = mapController.camera.zoom;
                          mapController.move(
                            mapController.camera.center,
                            zoom - 1,
                          );
                        },
                      ),
                      const SizedBox(height: 6),
                      _buildMapControlButton(
                        icon: LucideIcons.locate_fixed,
                        onTap: () {
                          mapController.move(
                            LatLng(property.latitude, property.longitude),
                            15.0,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapControlButton({
    required IconData icon,
    bool active = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: active
              ? AppColors.accent
              : (isDark ? AppColors.darkSurface : Colors.white).withValues(
                  alpha: 0.95,
                ),
          shape: BoxShape.circle,
          border: Border.all(
            color: active
                ? AppColors.accent
                : (isDark ? AppColors.darkBorder : AppColors.border),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            size: 16,
            color: active
                ? Colors.white
                : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}
