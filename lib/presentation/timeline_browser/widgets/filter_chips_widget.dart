import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class FilterChipsWidget extends StatelessWidget {
  final List<String> selectedRegions;
  final List<String> selectedTypes;
  final List<String> selectedAvailability;
  final Function(String, bool) onRegionChanged;
  final Function(String, bool) onTypeChanged;
  final Function(String, bool) onAvailabilityChanged;
  final VoidCallback onClearAll;

  const FilterChipsWidget({
    Key? key,
    required this.selectedRegions,
    required this.selectedTypes,
    required this.selectedAvailability,
    required this.onRegionChanged,
    required this.onTypeChanged,
    required this.onAvailabilityChanged,
    required this.onClearAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final regions = [
      'Europe',
      'Asia',
      'Africa',
      'Americas',
      'Oceania',
      'Middle East'
    ];
    final types = [
      'Political',
      'Topographical',
      'Trade Routes',
      'Military',
      'Cultural',
      'Religious'
    ];
    final availability = ['Downloaded', 'Online Only', 'High Resolution'];

    final hasActiveFilters = selectedRegions.isNotEmpty ||
        selectedTypes.isNotEmpty ||
        selectedAvailability.isNotEmpty;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with clear all button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (hasActiveFilters)
                TextButton(
                  onPressed: onClearAll,
                  child: Text(
                    'Clear All',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.tertiary,
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: 1.h),

          // Region filters
          _buildFilterSection(
            'Region',
            regions,
            selectedRegions,
            onRegionChanged,
          ),

          SizedBox(height: 1.h),

          // Type filters
          _buildFilterSection(
            'Map Type',
            types,
            selectedTypes,
            onTypeChanged,
          ),

          SizedBox(height: 1.h),

          // Availability filters
          _buildFilterSection(
            'Availability',
            availability,
            selectedAvailability,
            onAvailabilityChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(
    String title,
    List<String> options,
    List<String> selected,
    Function(String, bool) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 0.5.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: options.map((option) {
            final isSelected = selected.contains(option);

            return FilterChip(
              label: Text(
                option,
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.onPrimary
                      : AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) => onChanged(option, selected),
              backgroundColor: AppTheme.lightTheme.colorScheme.surface,
              selectedColor: AppTheme.lightTheme.colorScheme.primary,
              checkmarkColor: AppTheme.lightTheme.colorScheme.onPrimary,
              side: BorderSide(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.5),
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
            );
          }).toList(),
        ),
      ],
    );
  }
}
