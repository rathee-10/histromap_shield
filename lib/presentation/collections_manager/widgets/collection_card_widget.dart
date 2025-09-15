import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CollectionCardWidget extends StatelessWidget {
  final Map<String, dynamic> collection;
  final VoidCallback onTap;
  final VoidCallback onShare;
  final VoidCallback onExport;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;
  final bool isSelected;
  final bool isMultiSelectMode;
  final ValueChanged<bool?>? onSelectionChanged;

  const CollectionCardWidget({
    Key? key,
    required this.collection,
    required this.onTap,
    required this.onShare,
    required this.onExport,
    required this.onDuplicate,
    required this.onDelete,
    this.isSelected = false,
    this.isMultiSelectMode = false,
    this.onSelectionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Slidable(
        key: ValueKey(collection['id']),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onShare(),
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              foregroundColor: Colors.white,
              icon: Icons.share,
              label: 'Share',
              borderRadius: BorderRadius.circular(8.0),
            ),
            SlidableAction(
              onPressed: (_) => onExport(),
              backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
              foregroundColor: Colors.white,
              icon: Icons.download,
              label: 'Export',
              borderRadius: BorderRadius.circular(8.0),
            ),
            SlidableAction(
              onPressed: (_) => onDuplicate(),
              backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
              foregroundColor: Colors.black,
              icon: Icons.copy,
              label: 'Duplicate',
              borderRadius: BorderRadius.circular(8.0),
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
              borderRadius: BorderRadius.circular(8.0),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: isMultiSelectMode
              ? () => onSelectionChanged?.call(!isSelected)
              : onTap,
          onLongPress: () => onSelectionChanged?.call(!isSelected),
          child: Card(
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: isSelected
                  ? BorderSide(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      width: 2.0)
                  : BorderSide.none,
            ),
            child: Container(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (isMultiSelectMode)
                        Container(
                          margin: EdgeInsets.only(right: 3.w),
                          child: Checkbox(
                            value: isSelected,
                            onChanged: onSelectionChanged,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                        ),
                      Expanded(
                        child: Text(
                          collection['name'] ?? 'Untitled Collection',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(
                          '${collection['mapCount'] ?? 0} maps',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  if (collection['description'] != null &&
                      (collection['description'] as String).isNotEmpty)
                    Container(
                      margin: EdgeInsets.only(bottom: 2.h),
                      child: Text(
                        collection['description'],
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  _buildThumbnailGrid(),
                  SizedBox(height: 2.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'access_time',
                            size: 16,
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            'Modified ${_formatDate(collection['lastModified'])}',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                      if (collection['syncPending'] == true)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.tertiary
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomIconWidget(
                                iconName: 'sync',
                                size: 12,
                                color: AppTheme.lightTheme.colorScheme.tertiary,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                'Sync Pending',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.tertiary,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailGrid() {
    final thumbnails = (collection['thumbnails'] as List?) ?? [];

    if (thumbnails.isEmpty) {
      return Container(
        height: 12.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'map',
                size: 24,
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.4),
              ),
              SizedBox(height: 1.h),
              Text(
                'No maps yet',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 12.h,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 1.w,
          mainAxisSpacing: 1.w,
        ),
        itemCount: thumbnails.length > 6 ? 6 : thumbnails.length,
        itemBuilder: (context, index) {
          if (index == 5 && thumbnails.length > 6) {
            return Container(
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: Center(
                child: Text(
                  '+${thumbnails.length - 5}',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }

          return ClipRRect(
            borderRadius: BorderRadius.circular(6.0),
            child: CustomImageWidget(
              imageUrl: thumbnails[index],
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Unknown';

    DateTime dateTime;
    if (date is String) {
      dateTime = DateTime.tryParse(date) ?? DateTime.now();
    } else if (date is DateTime) {
      dateTime = date;
    } else {
      return 'Unknown';
    }

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
