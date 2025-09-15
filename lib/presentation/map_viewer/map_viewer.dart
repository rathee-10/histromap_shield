import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/annotation_tools.dart';
import './widgets/color_picker_dialog.dart';
import './widgets/map_info_panel.dart';
import './widgets/map_overlay_controls.dart';
import './widgets/navigation_breadcrumb.dart';
import './widgets/zoom_controls.dart';

class MapViewer extends StatefulWidget {
  const MapViewer({super.key});

  @override
  State<MapViewer> createState() => _MapViewerState();
}

class _MapViewerState extends State<MapViewer>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  GoogleMapController? _mapController;
  bool _isOverlayMode = false;
  double _overlayOpacity = 0.7;
  bool _showControls = true;
  bool _showInfoPanel = false;
  bool _showAnnotationTools = false;
  double _currentZoom = 1.0;
  LatLng _currentCenter = const LatLng(40.7128, -74.0060); // New York default
  Color _selectedAnnotationColor = Colors.red;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  late AnimationController _controlsAnimationController;
  late AnimationController _panelAnimationController;
  late Animation<double> _controlsAnimation;
  late Animation<double> _panelAnimation;

  // Mock historical map data
  final Map<String, dynamic> _currentMapData = {
    "id": "map_001",
    "title": "New York Harbor - Revolutionary War Era",
    "era": "1776-1783 CE",
    "region": "New York Harbor, Colonial America",
    "description":
        """Detailed cartographic representation of New York Harbor during the Revolutionary War period. 
    This map shows British naval positions, colonial settlements, and strategic waterways that played crucial roles in the American Revolution.""",
    "resolution": "4096x3072",
    "verified": true,
    "downloadSize": "12.4 MB",
    "checksum": "a1b2c3d4e5f6789012345678901234567890abcd",
    "watermark": "© Historical Maps Archive 2024",
    "annotations": [],
    "overlayUrl":
        "https://images.unsplash.com/photo-1578662996442-48f60103fc96?fm=jpg&q=60&w=3000",
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAnimations();
    _requestLocationPermission();
    _startControlsTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controlsAnimationController.dispose();
    _panelAnimationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _controlsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _panelAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _controlsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controlsAnimationController,
      curve: Curves.easeInOut,
    ));

    _panelAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _panelAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _controlsAnimationController.forward();
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentCenter = LatLng(position.latitude, position.longitude);
      });
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(_currentCenter),
      );
    } catch (e) {
      // Handle location error silently
    }
  }

  void _startControlsTimer() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _showControls) {
        setState(() {
          _showControls = false;
        });
        _controlsAnimationController.reverse();
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _applyMapStyle();
  }

  void _applyMapStyle() {
    const String mapStyle = '''
    [
      {
        "featureType": "all",
        "elementType": "geometry.fill",
        "stylers": [
          {
            "color": "#f8f6f2"
          }
        ]
      },
      {
        "featureType": "water",
        "elementType": "geometry.fill",
        "stylers": [
          {
            "color": "#5d6d7e"
          }
        ]
      }
    ]
    ''';
    _mapController?.setMapStyle(mapStyle);
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) {
      _controlsAnimationController.forward();
      _startControlsTimer();
    } else {
      _controlsAnimationController.reverse();
    }
  }

  void _onMapLongPress(LatLng position) {
    HapticFeedback.mediumImpact();
    _createAnnotation(position);
  }

  void _createAnnotation(LatLng position) {
    final markerId =
        MarkerId('annotation_${DateTime.now().millisecondsSinceEpoch}');
    final marker = Marker(
      markerId: markerId,
      position: position,
      icon: BitmapDescriptor.defaultMarkerWithHue(
        _getHueFromColor(_selectedAnnotationColor),
      ),
      infoWindow: InfoWindow(
        title: 'Annotation',
        snippet: 'Tap to edit',
        onTap: () => _editAnnotation(markerId),
      ),
    );

    setState(() {
      _markers.add(marker);
    });
  }

  double _getHueFromColor(Color color) {
    if (color == Colors.red) return BitmapDescriptor.hueRed;
    if (color == Colors.blue) return BitmapDescriptor.hueBlue;
    if (color == Colors.green) return BitmapDescriptor.hueGreen;
    if (color == Colors.orange) return BitmapDescriptor.hueOrange;
    if (color == Colors.purple) return BitmapDescriptor.hueViolet;
    return BitmapDescriptor.hueRed;
  }

  void _editAnnotation(MarkerId markerId) {
    // Implementation for editing annotations
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Annotation'),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'Enter annotation text...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Save annotation logic here
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _toggleOverlayMode() {
    setState(() {
      _isOverlayMode = !_isOverlayMode;
    });
    HapticFeedback.lightImpact();
  }

  void _onOpacityChanged(double value) {
    setState(() {
      _overlayOpacity = value;
    });
  }

  void _zoomIn() {
    _mapController?.animateCamera(CameraUpdate.zoomIn());
    HapticFeedback.selectionClick();
  }

  void _zoomOut() {
    _mapController?.animateCamera(CameraUpdate.zoomOut());
    HapticFeedback.selectionClick();
  }

  void _fitToScreen() {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_currentCenter, 12.0),
    );
    HapticFeedback.mediumImpact();
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _currentZoom = position.zoom / 20.0; // Normalize for display
      _currentCenter = position.target;
    });
  }

  void _toggleInfoPanel() {
    setState(() {
      _showInfoPanel = !_showInfoPanel;
    });

    if (_showInfoPanel) {
      _panelAnimationController.forward();
    } else {
      _panelAnimationController.reverse();
    }
  }

  void _toggleAnnotationTools() {
    setState(() {
      _showAnnotationTools = !_showAnnotationTools;
    });
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => ColorPickerDialog(
        initialColor: _selectedAnnotationColor,
        onColorSelected: (color) {
          setState(() {
            _selectedAnnotationColor = color;
          });
        },
      ),
    );
  }

  void _shareMap() {
    HapticFeedback.lightImpact();
    // Implementation for sharing map
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Map sharing functionality will be implemented'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _downloadMap() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Download Map'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Size: ${_currentMapData['downloadSize']}'),
            SizedBox(height: 1.h),
            Text(
                'This map will be encrypted and stored securely on your device.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Start download process
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Download started...'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text('Download'),
          ),
        ],
      ),
    );
  }

  void _addToCollection() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added to collection'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _viewMetadata() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Map Metadata'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMetadataRow('Title', _currentMapData['title']),
              _buildMetadataRow('Era', _currentMapData['era']),
              _buildMetadataRow('Region', _currentMapData['region']),
              _buildMetadataRow('Resolution', _currentMapData['resolution']),
              _buildMetadataRow('Size', _currentMapData['downloadSize']),
              _buildMetadataRow('Checksum',
                  _currentMapData['checksum'].substring(0, 16) + '...'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20.w,
            child: Text(
              '$label:',
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      body: Stack(
        children: [
          // Main map view
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _currentCenter,
              zoom: 12.0,
            ),
            onTap: _onMapTap,
            onLongPress: _onMapLongPress,
            onCameraMove: _onCameraMove,
            markers: _markers,
            polylines: _polylines,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            compassEnabled: false,
          ),

          // Historical map overlay
          if (_isOverlayMode)
            Positioned.fill(
              child: Opacity(
                opacity: _overlayOpacity,
                child: CustomImageWidget(
                  imageUrl: _currentMapData['overlayUrl'],
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

          // Watermark
          Positioned(
            bottom: 8.h,
            right: 4.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _currentMapData['watermark'],
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Top toolbar
          AnimatedBuilder(
            animation: _controlsAnimation,
            builder: (context, child) {
              return Positioned(
                top: MediaQuery.of(context).padding.top +
                    (2.h * _controlsAnimation.value),
                left: 4.w,
                right: 4.w,
                child: Opacity(
                  opacity: _controlsAnimation.value,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface
                          .withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.shadowLight,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: CustomIconWidget(
                            iconName: 'arrow_back',
                            color: AppTheme.lightTheme.primaryColor,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            _currentMapData['title'],
                            style: AppTheme.lightTheme.textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: _shareMap,
                          child: CustomIconWidget(
                            iconName: 'share',
                            color: AppTheme.lightTheme.primaryColor,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        GestureDetector(
                          onTap: _toggleInfoPanel,
                          child: CustomIconWidget(
                            iconName: 'more_vert',
                            color: AppTheme.lightTheme.primaryColor,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Navigation breadcrumb
          Positioned(
            bottom: 2.h,
            left: 4.w,
            child: NavigationBreadcrumb(
              zoomLevel: _currentZoom,
              latitude: _currentCenter.latitude,
              longitude: _currentCenter.longitude,
            ),
          ),

          // Zoom controls
          Positioned(
            right: 4.w,
            top: 30.h,
            child: ZoomControls(
              onZoomIn: _zoomIn,
              onZoomOut: _zoomOut,
              onFitToScreen: _fitToScreen,
              currentZoom: _currentZoom,
            ),
          ),

          // Overlay controls
          Positioned(
            left: 4.w,
            bottom: 12.h,
            child: MapOverlayControls(
              isOverlayMode: _isOverlayMode,
              overlayOpacity: _overlayOpacity,
              onOverlayToggle: _toggleOverlayMode,
              onOpacityChanged: _onOpacityChanged,
            ),
          ),

          // Floating action button for annotations
          Positioned(
            right: 4.w,
            bottom: 12.h,
            child: FloatingActionButton(
              onPressed: _toggleAnnotationTools,
              backgroundColor: AppTheme.lightTheme.primaryColor,
              child: CustomIconWidget(
                iconName: _showAnnotationTools ? 'close' : 'edit',
                color: Colors.white,
                size: 24,
              ),
            ),
          ),

          // Annotation tools
          if (_showAnnotationTools)
            Positioned(
              right: 4.w,
              bottom: 22.h,
              child: AnnotationTools(
                onTextNote: () {
                  // Implementation for text note
                  _toggleAnnotationTools();
                },
                onLocationMarker: () {
                  // Implementation for location marker
                  _toggleAnnotationTools();
                },
                onFreehandDraw: () {
                  // Implementation for freehand draw
                  _toggleAnnotationTools();
                },
                onColorPicker: _showColorPicker,
                selectedColor: _selectedAnnotationColor,
              ),
            ),

          // Info panel
          AnimatedBuilder(
            animation: _panelAnimation,
            builder: (context, child) {
              return Positioned(
                left: 0,
                right: 0,
                bottom: -50.h + (50.h * _panelAnimation.value),
                child: MapInfoPanel(
                  mapData: _currentMapData,
                  onDownload: _downloadMap,
                  onAddToCollection: _addToCollection,
                  onViewMetadata: _viewMetadata,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
