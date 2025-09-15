import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MultiSelectBottomBar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onMerge;
  final VoidCallback onShare;
  final VoidCallback onDelete;
  final VoidCallback onCancel;

  const MultiSelectBottomBar({
    Key? key,
    required this.selectedCount,
    required this.onMerge,
    required this.onShare,
    required this.onDelete,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8.0,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$selectedCount collection${selectedCount == 1 ? '' : 's'} selected',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onCancel,
                  child: Text(
                    'Cancel',
                    style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: 'merge_type',
                    label: 'Merge',
                    onTap: selectedCount >= 2 ? onMerge : null,
                    isEnabled: selectedCount >= 2,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: _buildActionButton(
                    icon: 'share',
                    label: 'Share',
                    onTap: onShare,
                    isEnabled: true,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: _buildActionButton(
                    icon: 'delete',
                    label: 'Delete',
                    onTap: onDelete,
                    isEnabled: true,
                    isDestructive: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String icon,
    required String label,
    required VoidCallback? onTap,
    required bool isEnabled,
    bool isDestructive = false,
  }) {
    final Color backgroundColor = isDestructive
        ? AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.1)
        : AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1);

    final Color foregroundColor = isDestructive
        ? AppTheme.lightTheme.colorScheme.error
        : AppTheme.lightTheme.colorScheme.primary;

    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        decoration: BoxDecoration(
          color: isEnabled
              ? backgroundColor
              : AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isEnabled
                ? foregroundColor.withValues(alpha: 0.3)
                : AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: icon,
              size: 24,
              color: isEnabled
                  ? foregroundColor
                  : AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.3),
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: isEnabled
                    ? foregroundColor
                    : AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.3),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
