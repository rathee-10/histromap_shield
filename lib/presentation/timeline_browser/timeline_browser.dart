import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/bottom_navigation_widget.dart';
import './widgets/filter_chips_widget.dart';
import './widgets/map_card_widget.dart';
import './widgets/search_bar_widget.dart';
import './widgets/timeline_ruler_widget.dart';

class TimelineBrowser extends StatefulWidget {
  const TimelineBrowser({Key? key}) : super(key: key);

  @override
  State<TimelineBrowser> createState() => _TimelineBrowserState();
}

class _TimelineBrowserState extends State<TimelineBrowser>
    with TickerProviderStateMixin {
  // Timeline state
  int _selectedYear = 1500;
  double _zoomLevel = 0.5;
  final int _startYear = -600; // 600 BCE
  final int _endYear = 2025; // Present

  // Search and filter state
  String _searchQuery = '';
  List<String> _selectedRegions = [];
  List<String> _selectedTypes = [];
  List<String> _selectedAvailability = [];

  // Navigation state
  int _currentNavIndex = 2; // Timeline tab active

  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Mock data for historical maps
  final List<Map<String, dynamic>> _allMaps = [
    {
      "id": 1,
      "title": "Roman Empire at its Peak",
      "year": 117,
      "region": "Europe",
      "type": "Political",
      "imageUrl":
          "https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=300&fit=crop",
      "description":
          "Detailed map showing the Roman Empire under Emperor Trajan, including all provinces and major cities.",
      "resolution": "4K",
      "fileSize": "15.2 MB",
      "isDownloaded": true,
    },
    {
      "id": 2,
      "title": "Medieval Trade Routes",
      "year": 1200,
      "region": "Europe",
      "type": "Trade Routes",
      "imageUrl":
          "https://images.unsplash.com/photo-1519302959554-a75be0afc82a?w=400&h=300&fit=crop",
      "description":
          "Comprehensive map of medieval European trade routes including the Hanseatic League connections.",
      "resolution": "HD",
      "fileSize": "8.7 MB",
      "isDownloaded": false,
    },
    {
      "id": 3,
      "title": "Ancient Silk Road",
      "year": 200,
      "region": "Asia",
      "type": "Trade Routes",
      "imageUrl":
          "https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=300&fit=crop",
      "description":
          "Historical map depicting the ancient Silk Road trade routes connecting East and West.",
      "resolution": "4K",
      "fileSize": "22.1 MB",
      "isDownloaded": true,
    },
    {
      "id": 4,
      "title": "Byzantine Constantinople",
      "year": 1453,
      "region": "Europe",
      "type": "Military",
      "imageUrl":
          "https://images.unsplash.com/photo-1519302959554-a75be0afc82a?w=400&h=300&fit=crop",
      "description":
          "Detailed military map of Constantinople during the Ottoman siege of 1453.",
      "resolution": "HD",
      "fileSize": "12.4 MB",
      "isDownloaded": false,
    },
    {
      "id": 5,
      "title": "Mongol Empire Expansion",
      "year": 1279,
      "region": "Asia",
      "type": "Political",
      "imageUrl":
          "https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=300&fit=crop",
      "description":
          "Map showing the vast extent of the Mongol Empire under Kublai Khan.",
      "resolution": "4K",
      "fileSize": "18.9 MB",
      "isDownloaded": true,
    },
    {
      "id": 6,
      "title": "Renaissance Italy",
      "year": 1500,
      "region": "Europe",
      "type": "Cultural",
      "imageUrl":
          "https://images.unsplash.com/photo-1519302959554-a75be0afc82a?w=400&h=300&fit=crop",
      "description":
          "Cultural map of Renaissance Italy showing major city-states and artistic centers.",
      "resolution": "HD",
      "fileSize": "10.3 MB",
      "isDownloaded": false,
    },
    {
      "id": 7,
      "title": "Ancient Egyptian Kingdoms",
      "year": -1550,
      "region": "Africa",
      "type": "Political",
      "imageUrl":
          "https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=300&fit=crop",
      "description":
          "Map of ancient Egypt during the New Kingdom period, showing territorial extent.",
      "resolution": "4K",
      "fileSize": "16.7 MB",
      "isDownloaded": true,
    },
    {
      "id": 8,
      "title": "Aztec Empire Territory",
      "year": 1519,
      "region": "Americas",
      "type": "Political",
      "imageUrl":
          "https://images.unsplash.com/photo-1519302959554-a75be0afc82a?w=400&h=300&fit=crop",
      "description":
          "Pre-Columbian map showing the extent of the Aztec Empire before Spanish conquest.",
      "resolution": "HD",
      "fileSize": "11.8 MB",
      "isDownloaded": false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredMaps {
    return _allMaps.where((map) {
      // Year range filter (within 50 years of selected year for better UX)
      final mapYear = map["year"] as int;
      final yearDiff = (mapYear - _selectedYear).abs();
      final yearMatch = yearDiff <= 100;

      // Search query filter
      final searchMatch = _searchQuery.isEmpty ||
          (map["title"] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (map["region"] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (map["type"] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());

      // Region filter
      final regionMatch = _selectedRegions.isEmpty ||
          _selectedRegions.contains(map["region"] as String);

      // Type filter
      final typeMatch = _selectedTypes.isEmpty ||
          _selectedTypes.contains(map["type"] as String);

      // Availability filter
      final availabilityMatch = _selectedAvailability.isEmpty ||
          (_selectedAvailability.contains('Downloaded') &&
              (map["isDownloaded"] as bool)) ||
          (_selectedAvailability.contains('Online Only') &&
              !(map["isDownloaded"] as bool)) ||
          (_selectedAvailability.contains('High Resolution') &&
              (map["resolution"] as String) == '4K');

      return yearMatch &&
          searchMatch &&
          regionMatch &&
          typeMatch &&
          availabilityMatch;
    }).toList()
      ..sort((a, b) => (a["year"] as int).compareTo(b["year"] as int));
  }

  void _onYearSelected(int year) {
    setState(() {
      _selectedYear = year;
    });
    HapticFeedback.selectionClick();
    _fadeController.reset();
    _fadeController.forward();
  }

  void _onZoomChanged(double zoom) {
    setState(() {
      _zoomLevel = zoom;
    });
    HapticFeedback.lightImpact();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _onRegionFilterChanged(String region, bool selected) {
    setState(() {
      selected ? _selectedRegions.add(region) : _selectedRegions.remove(region);
    });
  }

  void _onTypeFilterChanged(String type, bool selected) {
    setState(() {
      selected ? _selectedTypes.add(type) : _selectedTypes.remove(type);
    });
  }

  void _onAvailabilityFilterChanged(String availability, bool selected) {
    setState(() {
      selected
          ? _selectedAvailability.add(availability)
          : _selectedAvailability.remove(availability);
    });
  }

  void _onClearAllFilters() {
    setState(() {
      _selectedRegions.clear();
      _selectedTypes.clear();
      _selectedAvailability.clear();
    });
  }

  void _onJumpToDate() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDatePicker(),
    );
  }

  void _onNavigationTap(int index) {
    if (index == _currentNavIndex) return;

    final routes = [
      '/map-explorer-home',
      '/map-viewer',
      '/timeline-browser',
      '/collections-manager',
    ];

    Navigator.pushReplacementNamed(context, routes[index]);
  }

  void _onMapTap(Map<String, dynamic> mapData) {
    Navigator.pushNamed(context, '/map-viewer', arguments: mapData);
  }

  void _onMapDownload(Map<String, dynamic> mapData) {
    // Simulate download process
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading ${mapData["title"]}...'),
        action: SnackBarAction(
          label: 'Cancel',
          onPressed: () {},
        ),
      ),
    );

    // Update download status after delay (simulate download)
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        final index = _allMaps.indexWhere((map) => map["id"] == mapData["id"]);
        if (index != -1) {
          _allMaps[index]["isDownloaded"] = true;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${mapData["title"]} downloaded successfully!'),
          backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        ),
      );
    });
  }

  Widget _buildDatePicker() {
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 12.w,
            height: 0.5.h,
            margin: EdgeInsets.symmetric(vertical: 2.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Jump to Date',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Done'),
                ),
              ],
            ),
          ),

          Divider(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3)),

          // Date picker content
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                children: [
                  // Year input
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Year',
                      hintText: 'Enter year (use negative for BCE)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.numberWithOptions(signed: true),
                    onSubmitted: (value) {
                      final year = int.tryParse(value);
                      if (year != null &&
                          year >= _startYear &&
                          year <= _endYear) {
                        _onYearSelected(year);
                        Navigator.pop(context);
                      }
                    },
                  ),

                  SizedBox(height: 2.h),

                  // Quick date buttons
                  Text(
                    'Quick Jump',
                    style: AppTheme.lightTheme.textTheme.titleSmall,
                  ),

                  SizedBox(height: 1.h),

                  Wrap(
                    spacing: 2.w,
                    runSpacing: 1.h,
                    children: [
                      _buildQuickDateButton('Ancient Egypt', -1500),
                      _buildQuickDateButton('Classical Greece', -400),
                      _buildQuickDateButton('Roman Empire', 100),
                      _buildQuickDateButton('Medieval Period', 1000),
                      _buildQuickDateButton('Renaissance', 1500),
                      _buildQuickDateButton('Age of Exploration', 1600),
                      _buildQuickDateButton('Industrial Revolution', 1800),
                      _buildQuickDateButton('Modern Era', 1900),
                      _buildQuickDateButton('Present Day', 2025),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickDateButton(String label, int year) {
    return ElevatedButton(
      onPressed: () {
        _onYearSelected(year);
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        foregroundColor: AppTheme.lightTheme.colorScheme.onSurface,
        elevation: 1,
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      ),
      child: Text(
        label,
        style: AppTheme.lightTheme.textTheme.labelSmall,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredMaps = _filteredMaps;

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Timeline Browser',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        foregroundColor: AppTheme.lightTheme.colorScheme.onSurface,
        actions: [
          IconButton(
            onPressed: () {
              // Show timeline help
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Timeline Navigation'),
                  content: Text(
                    'Pinch to zoom in/out on timeline\nTap markers to select dates\nUse search to find specific periods\nFilter maps by region and type',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Got it'),
                    ),
                  ],
                ),
              );
            },
            icon: CustomIconWidget(
              iconName: 'help_outline',
              size: 24,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          SearchBarWidget(
            searchQuery: _searchQuery,
            onSearchChanged: _onSearchChanged,
            onJumpToDate: _onJumpToDate,
          ),

          // Filter chips
          FilterChipsWidget(
            selectedRegions: _selectedRegions,
            selectedTypes: _selectedTypes,
            selectedAvailability: _selectedAvailability,
            onRegionChanged: _onRegionFilterChanged,
            onTypeChanged: _onTypeFilterChanged,
            onAvailabilityChanged: _onAvailabilityFilterChanged,
            onClearAll: _onClearAllFilters,
          ),

          // Timeline ruler
          TimelineRulerWidget(
            startYear: _startYear,
            endYear: _endYear,
            selectedYear: _selectedYear,
            onYearSelected: _onYearSelected,
            onZoomChanged: _onZoomChanged,
            zoomLevel: _zoomLevel,
          ),

          // Maps list
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: filteredMaps.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'search_off',
                            size: 48,
                            color: AppTheme.lightTheme.colorScheme.outline,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'No maps found',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Try adjusting your filters or search query',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.only(bottom: 2.h),
                      itemCount: filteredMaps.length,
                      itemBuilder: (context, index) {
                        final mapData = filteredMaps[index];
                        return MapCardWidget(
                          mapData: mapData,
                          onTap: () => _onMapTap(mapData),
                          onDownload: () => _onMapDownload(mapData),
                          isDownloaded: mapData["isDownloaded"] as bool,
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationWidget(
        currentIndex: _currentNavIndex,
        onTap: _onNavigationTap,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onJumpToDate,
        tooltip: 'Jump to Date',
        child: CustomIconWidget(
          iconName: 'calendar_today',
          size: 24,
          color: AppTheme.lightTheme.colorScheme.onTertiary,
        ),
      ),
    );
  }
}
