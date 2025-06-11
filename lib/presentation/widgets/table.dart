import 'package:flutter/material.dart';

class TablaDeVisitas extends StatelessWidget {
  final List<dynamic> filteredItems;

  const TablaDeVisitas({Key? key, required this.filteredItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = filteredItems.take(17).toList(); // limitar a 17 filas como mencionaste

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // por si hay muchas columnas
      child: DataTable(
        columnSpacing: 24,
        headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
        columns: const [
          // DataColumn(label: Text('ID')),
          DataColumn(label: Text('Nombre')),
          DataColumn(label: Text('Visitas')),
          DataColumn(label: Text('General')),
          DataColumn(label: Text('Actividad')),
        ],
        rows: items.map((item) {
          final general = int.tryParse(item['visita_general'].toString()) ?? 0;
          final demo = int.tryParse(item['visita_demo'].toString()) ?? 0;
          final total = general + demo;

          return DataRow(cells: [
            // DataCell(Text(item['id'])),
            DataCell(Text(item['nombre'])),
            DataCell(Text(total.toString())),
            DataCell(Text(general.toString())),
            DataCell(Text(demo.toString())),
          ]);
        }).toList(),
      ),
    );
  }
}
