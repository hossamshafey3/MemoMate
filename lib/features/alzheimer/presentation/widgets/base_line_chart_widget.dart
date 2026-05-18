import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class BaseLineChartWidget extends StatelessWidget {
  final List<double> values;
  final List<DateTime> dates;
  final String title;
  final Color Function(double) getColorForValue;
  final double minY;
  final double maxY;
  final int interval;
  final String Function(double)? getTooltipText;

  const BaseLineChartWidget({
    super.key,
    required this.values,
    required this.dates,
    required this.title,
    required this.getColorForValue,
    required this.minY,
    required this.maxY,
    this.interval = 1,
    this.getTooltipText,
  });

  @override
  Widget build(BuildContext context) {
    // Check if we have valid numeric data points (excluding 0.0 placeholders if applicable, 
    // but here we just check if the list is empty or all values are 0 if that's not expected)
    final hasData = values.isNotEmpty && values.any((v) => v != 0);

    if (!hasData || dates.isEmpty) {
      return Container(
        height: 280.h,
        width: double.infinity,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, size: 48.r, color: Colors.grey.shade300),
            SizedBox(height: 16.h),
            Text(
              'No data recorded for $title yet.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Complete a diagnostic check to see your progress.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      );
    }

    // Take the last 7 checks as requested
    final recentValues = values.length > 7 ? values.sublist(values.length - 7) : values;
    final recentDates = dates.length > 7 ? dates.sublist(dates.length - 7) : dates;

    final spots = List.generate(
      recentValues.length,
      (index) {
        final val = recentValues[index];
        return FlSpot(index.toDouble() + 1, val);
      },
    );

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 24.h),
          SizedBox(
            height: 220.h,
            child: LineChart(
              LineChartData(
                minX: 1,
                maxX: 7,
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.grey.withValues(alpha: 0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 1 || index > 7) {
                          return const SizedBox.shrink();
                        }
                        
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            index.toString(),
                            style: GoogleFonts.poppins(
                              color: AppColors.grey,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: interval.toDouble(),
                      reservedSize: 42.w,
                      getTitlesWidget: (value, meta) {
                        if (value < minY || value > maxY) return const SizedBox.shrink();
                        return Text(
                          value.toStringAsFixed(0),
                          style: GoogleFonts.poppins(
                            color: AppColors.grey,
                            fontSize: 12.sp,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.primary.withValues(alpha: 0.5),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 5.r,
                          color: getColorForValue(spot.y),
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => Colors.blueGrey,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((touchedSpot) {
                        final date = recentDates[touchedSpot.spotIndex];
                        final dateStr = DateFormat('MMM dd, yyyy').format(date);
                        final valText = getTooltipText != null
                            ? getTooltipText!(touchedSpot.y)
                            : touchedSpot.y.toStringAsFixed(1);
                        return LineTooltipItem(
                          '$dateStr\n$valText',
                          GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
