import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AllocationChart extends StatelessWidget {
  const AllocationChart({super.key, required this.allocation});

  final Map<String, int> allocation;

  @override
  Widget build(BuildContext context) {
    final total = allocation.values.fold<int>(0, (sum, value) => sum + value);
    if (total <= 0) return const Text('No allocation yet.');
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];
    final entries = allocation.entries.toList();
    return SizedBox(
      height: 180,
      child: PieChart(
        PieChartData(
          sections: [
            for (var i = 0; i < entries.length; i++)
              PieChartSectionData(
                color: colors[i % colors.length],
                value: entries[i].value.toDouble(),
                title:
                    '${(entries[i].value / total * 100).toStringAsFixed(0)}%',
                radius: 60,
              ),
          ],
        ),
      ),
    );
  }
}
