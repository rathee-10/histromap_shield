import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MapCardWidget extends StatelessWidget {
  final Map<String, dynamic> mapData;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const MapCardWidget({
    Key? key,
    required this.mapData,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String title = (mapData['title'] as String?) ?? 'Unknown Map';
    final String era = (mapData['era'] as String?) ?? 'Unknown Era';
    final String region = (mapData['region'] as String?) ?? 'Unknown Region';
    final String imageUrl = (mapData['imageUrl'] as String?) ?? '';
    final bool isDownloaded = (mapData['isDownloaded'] as bool?) ?? false;
    final bool isDownloading = (mapData['isDownloading'] as bool?) ?? false;
    final double downloadProgress =
        (mapData['downloadProgress'] as double?) ?? 0.0;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowLight,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map thumbnail with status indicator
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: CustomImageWidget(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    height: 25.h,
                    fit: BoxFit.cover,
                  ),
                ),
                // Download status indicator
                Positioned(
                  top: 2.h,
                  right: 4.w,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: _getStatusColor(isDownloaded, isDownloading),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: _getStatusIcon(isDownloaded, isDownloading),
                          color: Colors.white,
                          size: 12.sp,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          _getStatusText(isDownloaded, isDownloading),
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: Colors.white,
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Download progress indicator
                if (isDownloading)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(
                      value: downloadProgress,
                      backgroundColor: Colors.black.withValues(alpha: 0.3),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppTheme.accentLight),
                    ),
                  ),
              ],
            ),
            // Map details
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'schedule',
                        color: AppTheme.textSecondaryLight,
                        size: 12.sp,
                      ),
                      SizedBox(width: 1.w),
                      Expanded(
                        child: Text(
                          era,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondaryLight,
                            fontSize: 11.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'location_on',
                        color: AppTheme.textSecondaryLight,
                        size: 12.sp,
                      ),
                      SizedBox(width: 1.w),
                      Expanded(
                        child: Text(
                          region,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondaryLight,
                            fontSize: 11.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(bool isDownloaded, bool isDownloading) {
    if (isDownloading) return AppTheme.warningLight;
    if (isDownloaded) return AppTheme.successLight;
    return AppTheme.textSecondaryLight;
  }

  String _getStatusIcon(bool isDownloaded, bool isDownloading) {
    if (isDownloading) return 'download';
    if (isDownloaded) return 'check_circle';
    return 'cloud_download';
  }

  String _getStatusText(bool isDownloaded, bool isDownloading) {
    if (isDownloading) return 'Downloading';
    if (isDownloaded) return 'Downloaded';
    return 'Available';
  }
}
