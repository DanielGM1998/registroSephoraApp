import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GraficaDeBarras extends StatelessWidget {
  final List<dynamic> filteredItems;

  const GraficaDeBarras({Key? key, required this.filteredItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final items = filteredItems.toList();

    return AspectRatio(
      aspectRatio: 1.5,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceBetween,
          maxY: _calcularMaximo(items),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              //tooltipBgColor: Colors.black87,
              tooltipPadding: const EdgeInsets.all(8),
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final index = group.x.toInt();
                if (index < filteredItems.length) {
                  final item = filteredItems[index];
                  final nombre = item['nombre'];
                  final totalVisitas = rod.toY.toInt();
                  return BarTooltipItem(
                    '$nombre\n$totalVisitas visitas',
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
                return null;
              },
            ),
            ),
            
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < items.length) {
                    return Transform.translate(
                      offset: const Offset(-18, 22), // mueve el texto hacia abajo
                      child: Transform.rotate(
                        angle: -0.7, // -0.7 radianes ≈ -40 grados
                        child: Text(
                          items[index]['nombre'],
                          style: const TextStyle(fontSize: 7),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 38),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: true),
          borderData: FlBorderData(show: false),
          barGroups: _crearBarGroups(items),
        ),
      ),
    );
  }

  double _calcularMaximo(List items) {
    double max = 0;
    for (var item in items) {
      double general = double.tryParse(item['visita_general'].toString()) ?? 0;
      double demo = double.tryParse(item['visita_demo'].toString()) ?? 0;
      if ((general + demo) > max) {
        max = general + demo;
      }
    }
    return max;
  }

  List<BarChartGroupData> _crearBarGroups(List items) {
    return List.generate(items.length, (index) {
      final item = items[index];
      double visitaGeneral = double.tryParse(item['visita_general'].toString()) ?? 0;
      double visitaDemo = double.tryParse(item['visita_demo'].toString()) ?? 0;
      double totalVisitas = visitaGeneral + visitaDemo;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: totalVisitas,
            color: Colors.black54,
            width: 14,
            borderRadius: BorderRadius.circular(4),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _calcularMaximo(items),
              color: Colors.grey[300],
            ),
          ),
        ],
      );
    });
  }
}
