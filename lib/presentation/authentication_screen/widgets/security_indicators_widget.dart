import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SecurityIndicatorsWidget extends StatefulWidget {
  final bool isConnected;
  final bool isSecure;

  const SecurityIndicatorsWidget({
    Key? key,
    required this.isConnected,
    required this.isSecure,
  }) : super(key: key);

  @override
  State<SecurityIndicatorsWidget> createState() =>
      _SecurityIndicatorsWidgetState();
}

class _SecurityIndicatorsWidgetState extends State<SecurityIndicatorsWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSecurityIndicator(
            icon: 'wifi',
            label: 'Connection',
            isActive: widget.isConnected,
            activeColor: AppTheme.successLight,
            inactiveColor: AppTheme.warningLight,
          ),
          _buildSecurityIndicator(
            icon: 'security',
            label: 'SSL Secure',
            isActive: widget.isSecure,
            activeColor: AppTheme.successLight,
            inactiveColor: AppTheme.errorLight,
          ),
          _buildSecurityIndicator(
            icon: 'verified_user',
            label: 'Encrypted',
            isActive: true,
            activeColor: AppTheme.accentLight,
            inactiveColor: AppTheme.errorLight,
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityIndicator({
    required String icon,
    required String label,
    required bool isActive,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isActive ? _pulseAnimation.value : 1.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: (isActive ? activeColor : inactiveColor)
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive ? activeColor : inactiveColor,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: icon,
                    size: 6.w,
                    color: isActive ? activeColor : inactiveColor,
                  ),
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                label,
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: isActive ? activeColor : inactiveColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
