import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MapsNearYouWidget extends StatelessWidget {
  final List<Map<String, dynamic>> nearbyMaps;
  final Function(Map<String, dynamic>) onMapTap;

  const MapsNearYouWidget({
    Key? key,
    required this.nearbyMaps,
    required this.onMapTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (nearbyMaps.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'near_me',
                  color: AppTheme.primaryLight,
                  size: 20.sp,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Maps Near You',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          Container(
            height: 20.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: nearbyMaps.length,
              itemBuilder: (context, index) {
                final mapData = nearbyMaps[index];
                return _buildNearbyMapCard(context, mapData);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyMapCard(
      BuildContext context, Map<String, dynamic> mapData) {
    final String title = (mapData['title'] as String?) ?? 'Unknown Map';
    final String era = (mapData['era'] as String?) ?? 'Unknown Era';
    final String imageUrl = (mapData['imageUrl'] as String?) ?? '';
    final String distance = (mapData['distance'] as String?) ?? '0 km';

    return GestureDetector(
      onTap: () => onMapTap(mapData),
      child: Container(
        width: 40.w,
        margin: EdgeInsets.only(right: 3.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowLight,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: CustomImageWidget(
                imageUrl: imageUrl,
                width: double.infinity,
                height: 12.h,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(2.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      era,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryLight,
                        fontSize: 10.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Spacer(),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'location_on',
                          color: AppTheme.accentLight,
                          size: 10.sp,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          distance,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.accentLight,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
