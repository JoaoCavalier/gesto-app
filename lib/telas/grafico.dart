import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:projeto_flutter/providers/despesas_provider.dart';
import 'package:projeto_flutter/providers/receitas_provider.dart';
import 'package:provider/provider.dart';

class FinancialData {
  final String category;
  final double amount;

  FinancialData(this.category, this.amount);
}

class GraficoScreen extends StatefulWidget {
  const GraficoScreen({super.key});

  @override
  State<GraficoScreen> createState() => _GraficoScreenState();
}

class _GraficoScreenState extends State<GraficoScreen> {
  @override
  Widget build(BuildContext context) {
    final despesas = Provider.of<DespesasProvider>(context).despesas;
    final receitas = Provider.of<ReceitasProvider>(context).receitas;

    double totalDespesas = 0;
    double totalReceitas = 0;

    for (var despesa in despesas) {
      totalDespesas += double.parse(despesa['valor']!.replaceAll('R\$', '').replaceAll(',', '.'));
    }

    for (var receita in receitas) {
      totalReceitas += double.parse(receita['valor']!.replaceAll('R\$', '').replaceAll(',', '.'));
    }

    final data = [
      FinancialData('Despesas', totalDespesas),
      FinancialData('Receitas', totalReceitas),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gráficos"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40, // Ajuste o espaço reservado para os títulos do lado esquerdo
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40, // Ajuste o espaço reservado para os títulos na parte inferior
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: data.map((financialData) {
              return BarChartGroupData(
                x: data.indexOf(financialData),
                barRods: [
                  BarChartRodData(
                    toY: financialData.amount,
                    color: financialData.category == 'Despesas' ? Colors.red : Colors.green,
                    width: 30, // Ajuste a largura das barras
                  ),
                ],
              );
            }).toList(),
            gridData: FlGridData(show: false), // Desative a grade se não for necessária
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: Colors.blueAccent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
