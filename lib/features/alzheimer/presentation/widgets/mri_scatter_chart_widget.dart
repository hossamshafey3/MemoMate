import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradproj/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class MriScatterChartWidget extends StatelessWidget {
  final List<double> values; // 0, 1, 2, or 3
  final List<DateTime> dates;

  const MriScatterChartWidget({
    super.key,
    required this.values,
    required this.dates,
  });

  Color _getColorForLevel(int level) {
    switch (level) {
      case 0:
        return Colors.green; // No Impairment
      case 1:
        return Colors.yellow; // Very Mild
      case 2:
        return Colors.orange; // Mild
      case 3:
        return Colors.red; // Moderate
      default:
        return AppColors.grey;
    }
  }

  String _getLabelForLevel(int level) {
    switch (level) {
      case 0:
        return 'None';
      case 1:
        return 'Very Mild';
      case 2:
        return 'Mild';
      case 3:
        return 'Moderate';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty || dates.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final scatterSpots = List.generate(
      values.length,
      (index) => ScatterSpot(
        index.toDouble() + 1,
        values[index],
        dotPainter: FlDotCirclePainter(
          radius: 8.r,
          color: _getColorForLevel(values[index].toInt()),
          strokeWidth: 2,
          strokeColor: Colors.white,
        ),
      ),
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
            'MRI Progression',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 24.h),
          SizedBox(
            height: 250.h,
            child: ScatterChart(
              ScatterChartData(
                scatterSpots: scatterSpots,
                minX: 0.5,
                maxX: 7.5,
                minY: -0.5,
                maxY: 3.5,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.grey.withValues(alpha: 0.2),
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: AppColors.grey.withValues(alpha: 0.1),
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
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value < 1 || value > 7) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            value.toInt().toString(),
                            style: GoogleFonts.poppins(
                              color: AppColors.grey,
                              fontSize: 12.sp,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 70,
                      getTitlesWidget: (value, meta) {
                        if (value < 0 || value > 3) return const SizedBox.shrink();
                        return Text(
                          _getLabelForLevel(value.toInt()),
                          style: GoogleFonts.poppins(
                            color: AppColors.grey,
                            fontSize: 11.sp,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                scatterTouchData: ScatterTouchData(
                  enabled: true,
                  handleBuiltInTouches: true,
                  touchTooltipData: ScatterTouchTooltipData(
                    getTooltipColor: (ScatterSpot spot) => Colors.blueGrey,
                    getTooltipItems: (ScatterSpot touchedBarSpot) {
                      final int index = (touchedBarSpot.x - 1).toInt();
                      final date = dates[index];
                      final dateStr = DateFormat('MMM dd, yyyy').format(date);
                      final level = touchedBarSpot.y.toInt();
                      return ScatterTooltipItem(
                        '$dateStr\n${_getLabelForLevel(level)}',
                        textStyle: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      );
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
