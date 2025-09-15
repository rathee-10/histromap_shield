import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AnnotationTools extends StatelessWidget {
  final VoidCallback onTextNote;
  final VoidCallback onLocationMarker;
  final VoidCallback onFreehandDraw;
  final VoidCallback onColorPicker;
  final Color selectedColor;

  const AnnotationTools({
    super.key,
    required this.onTextNote,
    required this.onLocationMarker,
    required this.onFreehandDraw,
    required this.onColorPicker,
    required this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Annotation Tools',
            style: AppTheme.lightTheme.textTheme.titleMedium,
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildToolButton(
                icon: 'text_fields',
                label: 'Text Note',
                onTap: onTextNote,
              ),
              _buildToolButton(
                icon: 'location_on',
                label: 'Marker',
                onTap: onLocationMarker,
              ),
              _buildToolButton(
                icon: 'brush',
                label: 'Draw',
                onTap: onFreehandDraw,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'palette',
                color: AppTheme.textSecondaryLight,
                size: 18,
              ),
              SizedBox(width: 2.w),
              Text(
                'Color:',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              SizedBox(width: 2.w),
              GestureDetector(
                onTap: onColorPicker,
                child: Container(
                  width: 8.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: selectedColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.lightTheme.primaryColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: icon,
              color: AppTheme.lightTheme.primaryColor,
              size: 24,
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: AppTheme.lightTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
