import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import for HapticFeedback
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/collections_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/collection_card_widget.dart';
import './widgets/collection_search_widget.dart';
import './widgets/create_collection_dialog.dart';
import './widgets/empty_collections_widget.dart';
import './widgets/multi_select_bottom_bar.dart';

class CollectionsManager extends StatefulWidget {
  const CollectionsManager({Key? key}) : super(key: key);

  @override
  State<CollectionsManager> createState() => _CollectionsManagerState();
}

class _CollectionsManagerState extends State<CollectionsManager>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final RefreshIndicator _refreshIndicatorKey = RefreshIndicator(
    onRefresh: () async {},
    child: Container(),
  );

  List<Map<String, dynamic>> _collections = [];
  List<Map<String, dynamic>> _filteredCollections = [];
  List<String> _selectedCollectionIds = [];
  bool _isLoading = true;
  bool _isSelectionMode = false;
  String _searchQuery = '';
  dynamic _collectionsChannel; // Changed from RealtimeChannel to dynamic

  @override
  void initState() {
    super.initState();
    _loadCollections();
    _setupRealTimeSubscription();
  }

  @override
  void dispose() {
    _collectionsChannel.unsubscribe();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadCollections() async {
    try {
      setState(() => _isLoading = true);

      final collections = await CollectionsService.instance.getAllCollections(
        limit: 50,
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
      );

      setState(() {
        _collections = collections;
        _filteredCollections = collections;
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load collections: ${error.toString()}'),
            backgroundColor: AppTheme.errorLight,
          ),
        );
      }
    }
  }

  void _setupRealTimeSubscription() {
    _collectionsChannel =
        CollectionsService.instance.subscribeToCollectionUpdates(
      onCollectionInsert: (collection) {
        setState(() {
          _collections.insert(0, collection);
          _applyFilters();
        });
      },
      onCollectionUpdate: (updatedCollection) {
        setState(() {
          final index = _collections
              .indexWhere((col) => col['id'] == updatedCollection['id']);
          if (index != -1) {
            _collections[index] = updatedCollection;
            _applyFilters();
          }
        });
      },
      onCollectionDelete: (deletedCollection) {
        setState(() {
          _collections
              .removeWhere((col) => col['id'] == deletedCollection['id']);
          _applyFilters();
        });
      },
    );
  }

  void _applyFilters() {
    setState(() {
      _filteredCollections = _collections.where((collection) {
        final matchesSearch = _searchQuery.isEmpty ||
            collection['name']
                .toString()
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            (collection['description'] ?? '')
                .toString()
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
        return matchesSearch;
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
    // Debounce the search
    Future.delayed(Duration(milliseconds: 500), () {
      if (_searchQuery == query) {
        _loadCollections();
      }
    });
  }

  void _createCollection() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => CreateCollectionDialog(
        onCreateCollection: (String name, String description) {
          Navigator.pop(context, {
            'name': name,
            'description': description,
            'isPublic': false,
          });
        },
      ),
    );

    if (result != null) {
      try {
        await CollectionsService.instance.createCollection(
          name: result['name'],
          description: result['description'],
          isPublic: result['isPublic'] ?? false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Collection "${result['name']}" created successfully!'),
            backgroundColor: AppTheme.successLight,
          ),
        );

        _loadCollections(); // Refresh the list
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create collection: ${error.toString()}'),
            backgroundColor: AppTheme.errorLight,
          ),
        );
      }
    }
  }

  void _editCollection(Map<String, dynamic> collection) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => CreateCollectionDialog(
        onCreateCollection: (String name, String description) {
          Navigator.pop(context, {
            'name': name,
            'description': description,
            'isPublic': collection['is_public'] ?? false,
          });
        },
      ),
    );

    if (result != null) {
      try {
        await CollectionsService.instance.updateCollection(
          collection['id'],
          name: result['name'],
          description: result['description'],
          isPublic: result['isPublic'],
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Collection updated successfully!'),
            backgroundColor: AppTheme.successLight,
          ),
        );

        _loadCollections(); // Refresh the list
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update collection: ${error.toString()}'),
            backgroundColor: AppTheme.errorLight,
          ),
        );
      }
    }
  }

  void _deleteSelectedCollections() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Collections'),
        content: Text(
          'Are you sure you want to delete ${_selectedCollectionIds.length} collection(s)? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorLight,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        for (final collectionId in _selectedCollectionIds) {
          await CollectionsService.instance.deleteCollection(collectionId);
        }

        setState(() {
          _selectedCollectionIds.clear();
          _isSelectionMode = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Collections deleted successfully!'),
            backgroundColor: AppTheme.successLight,
          ),
        );

        _loadCollections();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete collections: ${error.toString()}'),
            backgroundColor: AppTheme.errorLight,
          ),
        );
      }
    }
  }

  void _onCollectionTap(Map<String, dynamic> collection) {
    if (_isSelectionMode) {
      _toggleSelection(collection['id']);
    } else {
      // Navigate to collection details
      Navigator.pushNamed(
        context,
        '/collection-details', // You'll need to add this route
        arguments: {
          'collectionId': collection['id'],
          'title': collection['name'],
        },
      );
    }
  }

  void _onCollectionLongPress(Map<String, dynamic> collection) {
    if (!_isSelectionMode) {
      setState(() {
        _isSelectionMode = true;
        _selectedCollectionIds.add(collection['id']);
      });
      HapticFeedback.mediumImpact();
    }
  }

  void _toggleSelection(String collectionId) {
    setState(() {
      if (_selectedCollectionIds.contains(collectionId)) {
        _selectedCollectionIds.remove(collectionId);
        if (_selectedCollectionIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedCollectionIds.add(collectionId);
      }
    });
    HapticFeedback.lightImpact();
  }

  void _exitSelectionMode() {
    setState(() {
      _selectedCollectionIds.clear();
      _isSelectionMode = false;
    });
  }

  void _onRefresh() async {
    _loadCollections();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Collections'),
        elevation: 0,
        backgroundColor: AppTheme.lightTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_isSelectionMode) ...[
            IconButton(
              onPressed: _deleteSelectedCollections,
              icon: CustomIconWidget(
                iconName: 'delete',
                size: 6.w,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: _exitSelectionMode,
              icon: CustomIconWidget(
                iconName: 'close',
                size: 6.w,
                color: Colors.white,
              ),
            ),
          ] else ...[
            IconButton(
              onPressed: _createCollection,
              icon: CustomIconWidget(
                iconName: 'add',
                size: 6.w,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
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
                // Search section
                Container(
                  padding: EdgeInsets.all(4.w),
                  child: CollectionSearchWidget(
                    onSearchChanged: _onSearchChanged,
                  ),
                ),

                // Selection mode info
                if (_isSelectionMode)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    color:
                        AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'check_circle',
                          size: 5.w,
                          color: AppTheme.lightTheme.primaryColor,
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          '${_selectedCollectionIds.length} collection(s) selected',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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
                      : _filteredCollections.isEmpty
                          ? EmptyCollectionsWidget(
                              onCreateCollection: _createCollection,
                            )
                          : ListView.builder(
                              padding: EdgeInsets.all(4.w),
                              itemCount: _filteredCollections.length,
                              itemBuilder: (context, index) {
                                final collection = _filteredCollections[index];
                                final isSelected = _selectedCollectionIds
                                    .contains(collection['id']);
                                final isOwner =
                                    AuthService.instance.currentUser?.id ==
                                        collection['user_profiles']?['id'];

                                return Padding(
                                  padding: EdgeInsets.only(bottom: 2.h),
                                  child: CollectionCardWidget(
                                    collection: collection,
                                    isSelected: isSelected,
                                    isMultiSelectMode: _isSelectionMode,
                                    onTap: () => _onCollectionTap(collection),
                                    onShare: () => {},
                                    onExport: () => {},
                                    onDuplicate: () => {},
                                    onDelete: () => {},
                                    onSelectionChanged: (selected) =>
                                        _toggleSelection(collection['id']),
                                  ),
                                );
                              },
                            ),
                ),

                // Multi-select bottom bar
                if (_isSelectionMode)
                  MultiSelectBottomBar(
                    selectedCount: _selectedCollectionIds.length,
                    onMerge: () => {}, // Add this required parameter
                    onShare: () => {},
                    onDelete: _deleteSelectedCollections,
                    onCancel: _exitSelectionMode,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}