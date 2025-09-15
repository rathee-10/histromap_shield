import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CollectionSearchWidget extends StatefulWidget {
  final Function(String) onSearchChanged;
  final VoidCallback? onFilterTap;
  final bool hasActiveFilters;

  const CollectionSearchWidget({
    Key? key,
    required this.onSearchChanged,
    this.onFilterTap,
    this.hasActiveFilters = false,
  }) : super(key: key);

  @override
  State<CollectionSearchWidget> createState() => _CollectionSearchWidgetState();
}

class _CollectionSearchWidgetState extends State<CollectionSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: _isSearchActive
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.3),
                  width: _isSearchActive ? 2.0 : 1.0,
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  widget.onSearchChanged(value);
                  setState(() {
                    _isSearchActive = value.isNotEmpty;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search collections...',
                  hintStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.5),
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'search',
                      size: 20,
                      color: _isSearchActive
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                    ),
                  ),
                  suffixIcon: _isSearchActive
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            widget.onSearchChanged('');
                            setState(() {
                              _isSearchActive = false;
                            });
                          },
                          icon: CustomIconWidget(
                            iconName: 'clear',
                            size: 20,
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 2.h,
                  ),
                ),
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
            ),
          ),
          if (widget.onFilterTap != null) ...[
            SizedBox(width: 3.w),
            GestureDetector(
              onTap: widget.onFilterTap,
              child: Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: widget.hasActiveFilters
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: widget.hasActiveFilters
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3),
                  ),
                ),
                child: CustomIconWidget(
                  iconName: 'tune',
                  size: 20,
                  color: widget.hasActiveFilters
                      ? AppTheme.lightTheme.colorScheme.onPrimary
                      : AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
