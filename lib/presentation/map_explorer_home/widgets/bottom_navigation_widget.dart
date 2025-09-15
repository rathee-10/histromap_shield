import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BottomNavigationWidget extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavigationWidget({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 8.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                index: 0,
                iconName: 'home',
                label: 'Home',
              ),
              _buildNavItem(
                context: context,
                index: 1,
                iconName: 'collections_bookmark',
                label: 'Collections',
              ),
              _buildNavItem(
                context: context,
                index: 2,
                iconName: 'timeline',
                label: 'Timeline',
              ),
              _buildNavItem(
                context: context,
                index: 3,
                iconName: 'person',
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required String iconName,
    required String label,
  }) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: isSelected
                  ? AppTheme.primaryLight
                  : AppTheme.textSecondaryLight,
              size: 24.sp,
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: isSelected
                    ? AppTheme.primaryLight
                    : AppTheme.textSecondaryLight,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
