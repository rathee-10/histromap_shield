import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickActionsBottomSheet extends StatelessWidget {
  final Map<String, dynamic> mapData;
  final VoidCallback onDownload;
  final VoidCallback onAddToCollection;
  final VoidCallback onShare;
  final VoidCallback onViewDetails;

  const QuickActionsBottomSheet({
    Key? key,
    required this.mapData,
    required this.onDownload,
    required this.onAddToCollection,
    required this.onShare,
    required this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String title = (mapData['title'] as String?) ?? 'Unknown Map';
    final bool isDownloaded = (mapData['isDownloaded'] as bool?) ?? false;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.dividerLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 3.h),
          // Map title
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16.sp,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          // Action buttons
          Column(
            children: [
              _buildActionButton(
                context: context,
                iconName: isDownloaded ? 'check_circle' : 'download',
                label: isDownloaded ? 'Downloaded' : 'Download for Offline',
                onTap: isDownloaded ? null : onDownload,
                isDisabled: isDownloaded,
              ),
              SizedBox(height: 2.h),
              _buildActionButton(
                context: context,
                iconName: 'collections_bookmark',
                label: 'Add to Collection',
                onTap: onAddToCollection,
              ),
              SizedBox(height: 2.h),
              _buildActionButton(
                context: context,
                iconName: 'share',
                label: 'Share',
                onTap: onShare,
              ),
              SizedBox(height: 2.h),
              _buildActionButton(
                context: context,
                iconName: 'info',
                label: 'View Details',
                onTap: onViewDetails,
              ),
            ],
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String iconName,
    required String label,
    required VoidCallback? onTap,
    bool isDisabled = false,
  }) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 2.h),
        decoration: BoxDecoration(
          color: isDisabled
              ? AppTheme.lightTheme.cardColor
              : AppTheme.lightTheme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.dividerLight,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            SizedBox(width: 4.w),
            CustomIconWidget(
              iconName: iconName,
              color: isDisabled
                  ? AppTheme.textDisabledLight
                  : AppTheme.primaryLight,
              size: 20.sp,
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                label,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: isDisabled
                      ? AppTheme.textDisabledLight
                      : AppTheme.textPrimaryLight,
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                ),
              ),
            ),
            if (!isDisabled)
              CustomIconWidget(
                iconName: 'chevron_right',
                color: AppTheme.textSecondaryLight,
                size: 16.sp,
              ),
            SizedBox(width: 4.w),
          ],
        ),
      ),
    );
  }
}
