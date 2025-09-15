import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MapCardWidget extends StatelessWidget {
  final Map<String, dynamic> mapData;
  final VoidCallback? onTap;
  final VoidCallback? onDownload;
  final bool isDownloaded;

  const MapCardWidget({
    Key? key,
    required this.mapData,
    this.onTap,
    this.onDownload,
    this.isDownloaded = false,
  }) : super(key: key);

  String _formatYear(int year) {
    if (year < 0) {
      return '${(-year)} BCE';
    } else if (year == 0) {
      return '1 BCE';
    } else {
      return '$year CE';
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = mapData["title"] as String? ?? "Unknown Map";
    final year = mapData["year"] as int? ?? 0;
    final region = mapData["region"] as String? ?? "Unknown Region";
    final type = mapData["type"] as String? ?? "Historical";
    final imageUrl = mapData["imageUrl"] as String? ?? "";
    final description = mapData["description"] as String? ?? "";
    final resolution = mapData["resolution"] as String? ?? "High";
    final fileSize = mapData["fileSize"] as String? ?? "Unknown";

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(3.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and year
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          _formatYear(year),
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.tertiary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Download status indicator
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: isDownloaded
                          ? AppTheme.lightTheme.colorScheme.tertiary
                              .withValues(alpha: 0.1)
                          : AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName:
                              isDownloaded ? 'download_done' : 'cloud_download',
                          size: 16,
                          color: isDownloaded
                              ? AppTheme.lightTheme.colorScheme.tertiary
                              : AppTheme.lightTheme.colorScheme.outline,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          isDownloaded ? 'Downloaded' : 'Online',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: isDownloaded
                                ? AppTheme.lightTheme.colorScheme.tertiary
                                : AppTheme.lightTheme.colorScheme.outline,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 2.h),

              // Map preview image
              Container(
                width: double.infinity,
                height: 20.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageUrl.isNotEmpty
                      ? CustomImageWidget(
                          imageUrl: imageUrl,
                          width: double.infinity,
                          height: 20.h,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: AppTheme.lightTheme.colorScheme.surface,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomIconWidget(
                                  iconName: 'map',
                                  size: 32,
                                  color:
                                      AppTheme.lightTheme.colorScheme.outline,
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  'Map Preview',
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color:
                                        AppTheme.lightTheme.colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),

              SizedBox(height: 2.h),

              // Map details
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('Region', region),
                        SizedBox(height: 0.5.h),
                        _buildDetailRow('Type', type),
                        SizedBox(height: 0.5.h),
                        _buildDetailRow('Resolution', resolution),
                        SizedBox(height: 0.5.h),
                        _buildDetailRow('Size', fileSize),
                      ],
                    ),
                  ),
                ],
              ),

              if (description.isNotEmpty) ...[
                SizedBox(height: 1.h),
                Text(
                  description,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              SizedBox(height: 2.h),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onTap,
                      icon: CustomIconWidget(
                        iconName: 'visibility',
                        size: 18,
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                      label: Text('View Map'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isDownloaded ? null : onDownload,
                      icon: CustomIconWidget(
                        iconName: isDownloaded ? 'check' : 'download',
                        size: 18,
                        color: isDownloaded
                            ? AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6)
                            : AppTheme.lightTheme.colorScheme.onPrimary,
                      ),
                      label: Text(isDownloaded ? 'Downloaded' : 'Download'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        backgroundColor: isDownloaded
                            ? AppTheme.lightTheme.colorScheme.surface
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
