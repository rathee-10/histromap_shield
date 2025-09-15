import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ZoomControls extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onFitToScreen;
  final double currentZoom;

  const ZoomControls({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onFitToScreen,
    required this.currentZoom,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
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
          _buildZoomButton(
            icon: 'add',
            onTap: onZoomIn,
            isEnabled: currentZoom < 3.0,
          ),
          Container(
            width: 1,
            height: 1.h,
            color: AppTheme.dividerLight,
          ),
          _buildZoomButton(
            icon: 'remove',
            onTap: onZoomOut,
            isEnabled: currentZoom > 0.5,
          ),
          Container(
            width: 1,
            height: 1.h,
            color: AppTheme.dividerLight,
          ),
          _buildZoomButton(
            icon: 'fit_screen',
            onTap: onFitToScreen,
            isEnabled: true,
          ),
        ],
      ),
    );
  }

  Widget _buildZoomButton({
    required String icon,
    required VoidCallback onTap,
    required bool isEnabled,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        width: 12.w,
        height: 6.h,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: icon,
            color: isEnabled
                ? AppTheme.lightTheme.primaryColor
                : AppTheme.textDisabledLight,
            size: 24,
          ),
        ),
      ),
    );
  }
}
