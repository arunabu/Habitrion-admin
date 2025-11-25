import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/day_model.dart';
import 'dart:math';

class ChartsPanel extends StatelessWidget {
  final List<Task> tasks;

  const ChartsPanel({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const Center(
        child: Text(
          'No data available for charts.',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    final categoryData = _preparePieData(tasks.map((t) => t.category).toSet(), tasks, (task) => task.category);
    final subCategoryData = _preparePieData(tasks.map((t) => t.subcategory).toSet(), tasks, (task) => task.subcategory);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChartCard(
            title: 'Category Breakdown',
            chart: PieChart(_buildPieChartData(categoryData)),
            legend: _buildLegend(categoryData),
          ),
          const SizedBox(height: 24),
          _buildChartCard(
            title: 'Subcategory Breakdown',
            chart: PieChart(_buildPieChartData(subCategoryData)),
            legend: _buildLegend(subCategoryData),
          ),
          const SizedBox(height: 24),
          _buildChartCard(
            title: 'Activity Progress',
            chart: SizedBox(
              height: 300,
              child: BarChart(_buildActivityBarChart()),
            ),
            legend: _buildBarChartLegend(),
          ),
        ],
      ),
    );
  }

  Map<String, double> _preparePieData(Set<String> keys, List<Task> tasks, String Function(Task) getKey) {
    Map<String, double> data = {};
    for (var key in keys) {
      data[key] = tasks.where((task) => getKey(task) == key).fold(0.0, (sum, task) => sum + task.actual);
    }
    return data;
  }

  Widget _buildChartCard({required String title, required Widget chart, required Widget legend}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: chart,
          ),
          const SizedBox(height: 16),
          legend,
        ],
      ),
    );
  }

  PieChartData _buildPieChartData(Map<String, double> data) {
    final total = data.values.fold(0.0, (a, b) => a + b);
    return PieChartData(
      pieTouchData: PieTouchData(touchCallback: (event, pieTouchResponse) {}),
      sections: data.entries.map((entry) {
        final percentage = total > 0 ? (entry.value / total * 100) : 0;
        return PieChartSectionData(
          color: _getColorForString(entry.key),
          value: entry.value,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 80,
          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        );
      }).toList(),
      centerSpaceRadius: 0,
      sectionsSpace: 2,
    );
  }

  Widget _buildLegend(Map<String, double> data) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: data.entries.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 12, height: 12, color: _getColorForString(entry.key)),
            const SizedBox(width: 6),
            Text(
              '${entry.key} (${entry.value.toStringAsFixed(1)}h)',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }

  BarChartData _buildActivityBarChart() {
    return BarChartData(
      barGroups: tasks.asMap().entries.map((entry) {
        final index = entry.key;
        final task = entry.value;
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: task.planned,
              color: Colors.blueAccent,
              width: 14,
              borderRadius: const BorderRadius.all(Radius.circular(4)),
            ),
            BarChartRodData(
              toY: task.actual,
              color: Colors.greenAccent,
              width: 14,
              borderRadius: const BorderRadius.all(Radius.circular(4)),
            ),
          ],
        );
      }).toList(),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: _leftTitleWidgets)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
            sideTitles: SideTitles(
          showTitles: true,

          getTitlesWidget: (double value, TitleMeta meta) {
            final index = value.toInt();
            if (index >= 0 && index < tasks.length) {
            return SideTitleWidget(axisSide: meta.axisSide, child: Text(tasks[index].activity, style: const TextStyle(color: Colors.white70, fontSize: 10)));
            }
            return Container();
            
          },
        ),),
      ),
      borderData: FlBorderData(show: false),
      gridData: const FlGridData(
        show: true,
        drawVerticalLine: false,
      ),
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final task = tasks[group.x.toInt()];
            final rodName = rodIndex == 0 ? 'Planned' : 'Actual';
            return BarTooltipItem(
              '$rodName: ${rod.toY.toStringAsFixed(1)}h',
               const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              children: [
                TextSpan(text: '\n${task.activity}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.normal)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    if (value % 2 != 0 && value > 0) return Container(); // Show labels for even numbers
    return SideTitleWidget(axisSide: meta.axisSide, child: Text('${value.toInt()}h', style: const TextStyle(color: Colors.white70, fontSize: 10), textAlign: TextAlign.left));
  }

  Widget _buildBarChartLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.square, color: Colors.blueAccent, size: 16),
            const SizedBox(width: 6),
            const Text('Planned', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        const SizedBox(width: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.square, color: Colors.greenAccent, size: 16),
            const SizedBox(width: 6),
            const Text('Actual', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Color _getColorForString(String input) {
    final hash = input.hashCode;
    final random = Random(hash);
    return Color.fromRGBO(
      random.nextInt(156) + 100, // Brighter colors
      random.nextInt(156) + 100,
      random.nextInt(156) + 100,
      1,
    );
  }
}
