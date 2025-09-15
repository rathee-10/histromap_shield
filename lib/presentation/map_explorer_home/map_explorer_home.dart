import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/maps_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/bottom_navigation_widget.dart';
import './widgets/era_filter_chip_widget.dart';
import './widgets/map_card_widget.dart';
import './widgets/maps_near_you_widget.dart';
import './widgets/quick_actions_bottom_sheet.dart';
import './widgets/search_header_widget.dart';

class MapExplorerHome extends StatefulWidget {
  @override
  _MapExplorerHomeState createState() => _MapExplorerHomeState();
}

class _MapExplorerHomeState extends State<MapExplorerHome>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  int _currentBottomNavIndex = 0;
  String _selectedEra = 'All';
  String _searchQuery = '';
  List<Map<String, dynamic>> _maps = [];
  List<Map<String, dynamic>> _filteredMaps = [];
  List<Map<String, dynamic>> _nearbyMaps = [];
  bool _isLoading = false;
  bool _isLoadingNearby = false;
  late Animation<Offset> _slideAnimation;
  late dynamic _mapsChannel;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => _onSearchChanged(_searchController.text));
    _loadMaps();
    _loadNearbyMaps();
    _setupRealTimeSubscription();
  }

  @override
  void dispose() {
    if (_mapsChannel != null) {
      // _mapsChannel.unsubscribe();
    }
    _searchController.removeListener(() => _onSearchChanged(_searchController.text));
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
    Future.delayed(Duration(milliseconds: 500), () {
      if (_searchQuery == query) {
        _loadMaps();
      }
    });
  }

  void _onEraFilterChanged(String era) {
    setState(() => _selectedEra = era);
    _loadMaps();
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentBottomNavIndex = index;
    });

    switch (index) {
      case 0:
        // Already on Home
        break;
      case 1:
        Navigator.pushNamed(context, '/collections-manager');
        break;
      case 2:
        Navigator.pushNamed(context, '/timeline-browser');
        break;
      case 3:
        // Navigate to profile (not implemented in this screen)
        Fluttertoast.showToast(
          msg: "Profile feature coming soon",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        break;
    }
  }

  void _onMapTap(Map<String, dynamic> map) {
    Navigator.pushNamed(
      context,
      AppRoutes.mapViewer,
      arguments: {
        'mapId': map['id'],
        'title': map['title'],
      },
    );
  }

  void _onMapLongPress(Map<String, dynamic> mapData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickActionsBottomSheet(
        mapData: mapData,
        onDownload: () {
          Navigator.pop(context);
          _downloadMap(mapData);
        },
        onAddToCollection: () {
          Navigator.pop(context);
          _addToCollection(mapData);
        },
        onShare: () {
          Navigator.pop(context);
          _shareMap(mapData);
        },
        onViewDetails: () {
          Navigator.pop(context);
          _viewMapDetails(mapData);
        },
      ),
    );
  }

  void _downloadMap(Map<String, dynamic> mapData) {
    final String title = (mapData['title'] as String?) ?? 'Unknown Map';
    Fluttertoast.showToast(
      msg: "Downloading $title...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );

    // Simulate download progress
    setState(() {
      final int index = _maps.indexWhere((map) => map['id'] == mapData['id']);
      if (index != -1) {
        _maps[index]['isDownloading'] = true;
        _maps[index]['downloadProgress'] = 0.0;
      }
    });
  }

  void _addToCollection(Map<String, dynamic> mapData) {
    final String title = (mapData['title'] as String?) ?? 'Unknown Map';
    Fluttertoast.showToast(
      msg: "Added $title to collection",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _shareMap(Map<String, dynamic> mapData) {
    final String title = (mapData['title'] as String?) ?? 'Unknown Map';
    Fluttertoast.showToast(
      msg: "Sharing $title...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _viewMapDetails(Map<String, dynamic> mapData) {
    _onMapTap(mapData);
  }

  void _onFilterTap() {
    Fluttertoast.showToast(
      msg: "Advanced filters coming soon",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _onFloatingActionButtonTap() {
    Fluttertoast.showToast(
      msg: "Advanced map search coming soon",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  Future<void> _loadMaps() async {
    try {
      setState(() => _isLoading = true);

      final maps = await MapsService.instance.getAllMaps(
        limit: 50,
        era: _selectedEra == 'All' ? null : _selectedEra.toLowerCase(),
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
      );

      setState(() {
        _maps = maps;
        _filteredMaps = maps;
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load maps: ${error.toString()}'),
            backgroundColor: AppTheme.errorLight,
          ),
        );
      }
    }
  }

  Future<void> _loadNearbyMaps() async {
    try {
      setState(() => _isLoadingNearby = true);

      // Using example coordinates (could be replaced with actual location)
      final nearbyMaps = await MapsService.instance.getMapsNearLocation(
        51.5074, // London latitude
        -0.1278, // London longitude
        radiusKm: 100.0,
        limit: 5,
      );

      setState(() {
        _nearbyMaps = nearbyMaps;
        _isLoadingNearby = false;
      });
    } catch (error) {
      setState(() => _isLoadingNearby = false);
      // Silently handle nearby maps error as it's not critical
      print('Failed to load nearby maps: $error');
    }
  }

  void _setupRealTimeSubscription() {
    _mapsChannel = MapsService.instance.subscribeToMapUpdates(
      onMapInsert: (map) {
        setState(() {
          _maps.insert(0, map);
          _applyFilters();
        });
      },
      onMapUpdate: (updatedMap) {
        setState(() {
          final index =
              _maps.indexWhere((map) => map['id'] == updatedMap['id']);
          if (index != -1) {
            _maps[index] = updatedMap;
            _applyFilters();
          }
        });
      },
      onMapDelete: (deletedMap) {
        setState(() {
          _maps.removeWhere((map) => map['id'] == deletedMap['id']);
          _applyFilters();
        });
      },
    );
  }

  void _applyFilters() {
    setState(() {
      _filteredMaps = _maps.where((map) {
        final matchesEra = _selectedEra == 'All' ||
            map['era'].toString().toLowerCase() == _selectedEra.toLowerCase();
        final matchesSearch = _searchQuery.isEmpty ||
            map['title']
                .toString()
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            map['location_name']
                .toString()
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
        return matchesEra && matchesSearch;
      }).toList();
    });
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      Future.microtask(() => _loadMaps()),
      Future.microtask(() => _loadNearbyMaps()),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                AppTheme.lightTheme.colorScheme.surface,
              ],
            ),
          ),
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: Column(
              children: [
                // Search header
                SearchHeaderWidget(
                  searchController: _searchController,
                  onSearchChanged: _onSearchChanged,
                  onFilterTap: () {}, // Keep existing functionality
                ),

                // Era filters
                Container(
                  height: 6.h,
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      'All',
                      'Ancient',
                      'Medieval',
                      'Renaissance',
                      'Industrial',
                      'Modern',
                      'Contemporary'
                    ]
                        .map<Widget>((era) => EraFilterChipWidget(
                              label: era,
                              isSelected: _selectedEra == era,
                              onTap: () => _onEraFilterChanged(era),
                            ))
                        .toList(),
                  ),
                ),

                Expanded(
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.lightTheme.primaryColor,
                            ),
                          ),
                        )
                      : ListView(
                          padding: EdgeInsets.all(4.w),
                          children: [
                            // Nearby maps section
                            if (_nearbyMaps.isNotEmpty) ...[
                              MapsNearYouWidget(
                                nearbyMaps: _nearbyMaps,
                                onMapTap: _onMapTap,
                              ),
                              SizedBox(height: 3.h),
                            ],

                            // All maps section
                            Text(
                              'All Historical Maps',
                              style: AppTheme
                                  .lightTheme.textTheme.titleLarge
                                  ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2.h),

                            if (_filteredMaps.isEmpty) ...[
                              Container(
                                height: 30.h,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      CustomIconWidget(
                                        iconName: 'map',
                                        size: 15.w,
                                        color: AppTheme
                                            .lightTheme.colorScheme.outline,
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        'No maps found',
                                        style: AppTheme.lightTheme.textTheme
                                            .titleMedium
                                            ?.copyWith(
                                          color: AppTheme.lightTheme
                                              .colorScheme.outline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ] else ...[
                              ..._filteredMaps.map((map) => Padding(
                                    padding: EdgeInsets.only(bottom: 2.h),
                                    child: MapCardWidget(
                                      mapData: map,
                                      onTap: () => _onMapTap(map),
                                    ),
                                  )),
                            ],

                            SizedBox(
                                height:
                                    10.h), // Space for bottom navigation
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),

      // Bottom navigation
      bottomNavigationBar: BottomNavigationWidget(
        currentIndex: _currentBottomNavIndex,
        onTap: _onBottomNavTap,
      ),

      // Floating action button
      floatingActionButton: FloatingActionButton(
        onPressed: _onFloatingActionButtonTap,
        backgroundColor: AppTheme.accentLight,
        child: CustomIconWidget(
          iconName: 'search',
          color: Colors.black,
          size: 24.sp,
        ),
      ),
    );
  }
}