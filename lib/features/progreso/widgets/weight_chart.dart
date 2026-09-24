import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_motion.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/database/app_database.dart';

class WeightChart extends StatelessWidget {
  const WeightChart({super.key, required this.logs});

  final List<BodyWeightLog> logs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (logs.isEmpty) {
      return Center(
        child: Text(
          'Registra tu peso para comenzar a ver tu progreso.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    final sorted = [...logs]..sort((a, b) => a.date.compareTo(b.date));
    final firstDay = sorted.first.date;
    final spots = [
      for (final log in sorted) FlSpot(daysBetween(firstDay, log.date).toDouble(), log.weightKg),
    ];
    final weights = sorted.map((l) => l.weightKg);
    final minY = (weights.reduce(math.min) - 1).floorToDouble();
    final maxY = (weights.reduce(math.max) + 1).ceilToDouble();
    final spanDays = math.max(spots.last.x, 1.0);
    final axisStyle = theme.textTheme.labelSmall;
    final color = theme.colorScheme.primary;

    return LineChart(
      duration: AppMotion.of(context, AppMotion.slow),
      LineChartData(
        minY: minY,
        maxY: maxY,
        minX: 0,
        maxX: spanDays,
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: math.max(1, ((maxY - minY) / 4).roundToDouble()),
          getDrawingHorizontalLine: (_) => FlLine(color: theme.colorScheme.outline, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              interval: math.max(1, ((maxY - minY) / 4).roundToDouble()),
              getTitlesWidget: (value, meta) => SideTitleWidget(
                meta: meta,
                child: Text(formatDecimal(value), style: axisStyle),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              interval: math.max(1, (spanDays / 3).roundToDouble()),
              getTitlesWidget: (value, meta) => SideTitleWidget(
                meta: meta,
                child: Text(
                  DateFormat('d MMM', 'es').format(addDays(firstDay, value.round())),
                  style: axisStyle,
                ),
              ),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => theme.colorScheme.surfaceContainerHighest,
            getTooltipItems: (touchedSpots) => [
              for (final spot in touchedSpots)
                LineTooltipItem(
                  '${formatKg(spot.y)}\n'
                  '${DateFormat('d MMM', 'es').format(addDays(firstDay, spot.x.round()))}',
                  theme.textTheme.bodySmall!.copyWith(color: theme.colorScheme.onSurface),
                ),
            ],
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: spots.length > 2,
            preventCurveOverShooting: true,
            color: color,
            barWidth: 3,
            dotData: FlDotData(show: spots.length <= 30),
            belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.10)),
          ),
        ],
      ),
    );
  }
}
