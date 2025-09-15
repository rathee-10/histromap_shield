import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MapOverlayControls extends StatelessWidget {
  final bool isOverlayMode;
  final double overlayOpacity;
  final VoidCallback onOverlayToggle;
  final ValueChanged<double> onOpacityChanged;

  const MapOverlayControls({
    super.key,
    required this.isOverlayMode,
    required this.overlayOpacity,
    required this.onOverlayToggle,
    required this.onOpacityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'layers',
                color: AppTheme.lightTheme.primaryColor,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Overlay Mode',
                style: AppTheme.lightTheme.textTheme.titleSmall,
              ),
              const Spacer(),
              Switch(
                value: isOverlayMode,
                onChanged: (_) => onOverlayToggle(),
                activeColor: AppTheme.lightTheme.primaryColor,
              ),
            ],
          ),
          if (isOverlayMode) ...[
            SizedBox(height: 2.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'opacity',
                  color: AppTheme.textSecondaryLight,
                  size: 18,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Slider(
                    value: overlayOpacity,
                    onChanged: onOpacityChanged,
                    min: 0.1,
                    max: 1.0,
                    divisions: 9,
                    activeColor: AppTheme.lightTheme.primaryColor,
                    inactiveColor:
                        AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                Text(
                  '${(overlayOpacity * 100).round()}%',
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
