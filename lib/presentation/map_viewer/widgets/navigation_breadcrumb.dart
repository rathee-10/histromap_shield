import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NavigationBreadcrumb extends StatelessWidget {
  final double zoomLevel;
  final double latitude;
  final double longitude;

  const NavigationBreadcrumb({
    super.key,
    required this.zoomLevel,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: 'zoom_in',
            color: AppTheme.textSecondaryLight,
            size: 16,
          ),
          SizedBox(width: 1.w),
          Text(
            '${(zoomLevel * 100).toInt()}%',
            style: AppTheme.lightTheme.textTheme.labelMedium,
          ),
          SizedBox(width: 2.w),
          Container(
            width: 1,
            height: 2.h,
            color: AppTheme.dividerLight,
          ),
          SizedBox(width: 2.w),
          CustomIconWidget(
            iconName: 'location_on',
            color: AppTheme.textSecondaryLight,
            size: 16,
          ),
          SizedBox(width: 1.w),
          Text(
            '${latitude.toStringAsFixed(3)}, ${longitude.toStringAsFixed(3)}',
            style: AppTheme.lightTheme.textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}
