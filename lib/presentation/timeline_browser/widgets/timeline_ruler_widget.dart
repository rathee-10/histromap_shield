import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TimelineRulerWidget extends StatefulWidget {
  final int startYear;
  final int endYear;
  final int selectedYear;
  final Function(int) onYearSelected;
  final Function(double) onZoomChanged;
  final double zoomLevel;

  const TimelineRulerWidget({
    Key? key,
    required this.startYear,
    required this.endYear,
    required this.selectedYear,
    required this.onYearSelected,
    required this.onZoomChanged,
    required this.zoomLevel,
  }) : super(key: key);

  @override
  State<TimelineRulerWidget> createState() => _TimelineRulerWidgetState();
}

class _TimelineRulerWidgetState extends State<TimelineRulerWidget> {
  late ScrollController _scrollController;
  double _lastPanUpdate = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedYear();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedYear() {
    if (_scrollController.hasClients) {
      final totalYears = widget.endYear - widget.startYear;
      final selectedIndex = widget.selectedYear - widget.startYear;
      final scrollPosition = (selectedIndex / totalYears) *
          _scrollController.position.maxScrollExtent;
      _scrollController.animateTo(
        scrollPosition,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  List<int> _getVisibleYears() {
    final totalYears = widget.endYear - widget.startYear;
    final step = widget.zoomLevel > 0.8
        ? 1
        : widget.zoomLevel > 0.5
            ? 5
            : widget.zoomLevel > 0.3
                ? 10
                : 50;

    List<int> years = [];
    for (int year = widget.startYear; year <= widget.endYear; year += step) {
      years.add(year);
    }
    return years;
  }

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
    final visibleYears = _getVisibleYears();

    return Container(
      height: 12.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.lightTheme.colorScheme.outline,
            width: 1,
          ),
        ),
      ),
      child: GestureDetector(
        onScaleStart: (details) {
          _lastPanUpdate = details.focalPoint.dx;
        },
        onScaleUpdate: (details) {
          if (details.scale != 1.0) {
            final newZoom = (widget.zoomLevel * details.scale).clamp(0.1, 1.0);
            widget.onZoomChanged(newZoom);
          } else {
            final delta = details.focalPoint.dx - _lastPanUpdate;
            _scrollController.jumpTo(_scrollController.offset - delta);
            _lastPanUpdate = details.focalPoint.dx;
          }
        },
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          itemCount: visibleYears.length,
          itemBuilder: (context, index) {
            final year = visibleYears[index];
            final isSelected = year == widget.selectedYear;
            final isNearSelected = (year - widget.selectedYear).abs() <= 5;

            return GestureDetector(
              onTap: () => widget.onYearSelected(year),
              child: Container(
                width: widget.zoomLevel > 0.8
                    ? 15.w
                    : widget.zoomLevel > 0.5
                        ? 12.w
                        : 10.w,
                margin: EdgeInsets.symmetric(horizontal: 1.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Map thumbnail preview for selected/nearby years
                    if (isNearSelected && widget.zoomLevel > 0.6)
                      Container(
                        width: 8.w,
                        height: 4.h,
                        margin: EdgeInsets.only(bottom: 1.h),
                        decoration: BoxDecoration(
                          color:
                              AppTheme.lightTheme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                          border: isSelected
                              ? Border.all(
                                  color:
                                      AppTheme.lightTheme.colorScheme.tertiary,
                                  width: 2,
                                )
                              : null,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: CustomImageWidget(
                            imageUrl:
                                "https://images.unsplash.com/photo-1519302959554-a75be0afc82a?w=100&h=60&fit=crop",
                            width: 8.w,
                            height: 4.h,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                    // Year marker line
                    Container(
                      width: 2,
                      height: isSelected
                          ? 3.h
                          : isNearSelected
                              ? 2.h
                              : 1.5.h,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.tertiary
                            : isNearSelected
                                ? AppTheme.lightTheme.colorScheme.primary
                                : AppTheme.lightTheme.colorScheme.outline,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),

                    SizedBox(height: 0.5.h),

                    // Year label
                    Text(
                      _formatYear(year),
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.tertiary
                            : AppTheme.lightTheme.colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        fontSize: widget.zoomLevel > 0.8 ? 9.sp : 8.sp,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
