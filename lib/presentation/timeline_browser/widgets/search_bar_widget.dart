import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchBarWidget extends StatefulWidget {
  final String searchQuery;
  final Function(String) onSearchChanged;
  final VoidCallback onJumpToDate;

  const SearchBarWidget({
    Key? key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onJumpToDate,
  }) : super(key: key);

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController _searchController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Search input field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: _focusNode.hasFocus
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.5),
                  width: _focusNode.hasFocus ? 2 : 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                onChanged: widget.onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search dates, eras, or regions...',
                  hintStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'search',
                      size: 20,
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            widget.onSearchChanged('');
                          },
                          icon: CustomIconWidget(
                            iconName: 'clear',
                            size: 20,
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 1.5.h,
                  ),
                ),
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
            ),
          ),

          SizedBox(width: 3.w),

          // Jump to date button
          Container(
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.tertiary,
              borderRadius: BorderRadius.circular(25),
            ),
            child: IconButton(
              onPressed: widget.onJumpToDate,
              icon: CustomIconWidget(
                iconName: 'calendar_today',
                size: 20,
                color: AppTheme.lightTheme.colorScheme.onTertiary,
              ),
              tooltip: 'Jump to Date',
            ),
          ),
        ],
      ),
    );
  }
}
