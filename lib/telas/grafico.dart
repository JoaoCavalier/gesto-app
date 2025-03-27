import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:provider/provider.dart';
import 'package:projeto_flutter/telas/movimentacoes.dart';
import 'package:projeto_flutter/telas/objetivo.dart';

class GraficoScreen extends StatefulWidget {
  const GraficoScreen({super.key});

  @override
  State<GraficoScreen> createState() => _GraficoScreenState();
}

class _GraficoScreenState extends State<GraficoScreen> {
  int _selectedChartIndex = 0; // 0 para linha, 1 para gauge, 2 para coluna
  DateTime? _dataInicial;
  DateTime? _dataFinal;
  final PageController _pageController = PageController();

  void _switchChart() {
    setState(() {
      _selectedChartIndex = (_selectedChartIndex + 1) % 3;
      _pageController.animateToPage(
        _selectedChartIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _selecionarData(BuildContext context, bool isDataInicial) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isDataInicial) {
          _dataInicial = picked;
        } else {
          _dataFinal = picked;
        }
      });
    }
  }

  DateTime _parseData(String data) {
    try {
      final partes = data.split('/');
      if (partes.length == 3) {
        final dia = int.parse(partes[0]);
        final mes = int.parse(partes[1]);
        final ano = int.parse(partes[2]);
        return DateTime(ano, mes, dia);
      }
    } catch (e) {
      debugPrint("Erro ao converter data: $data");
    }
    throw FormatException("Formato de data inválido: $data");
  }

  List<Map<String, String>> _filtrarMovimentacoes(
      List<Map<String, String>> movimentacoes) {
    if (_dataInicial == null && _dataFinal == null) {
      return movimentacoes;
    }

    return movimentacoes.where((movimentacao) {
      final DateTime dataMovimentacao = _parseData(movimentacao["data"]!);
      bool dentroDoIntervalo = true;

      if (_dataInicial != null) {
        dentroDoIntervalo = dentroDoIntervalo &&
            (dataMovimentacao.isAfter(_dataInicial!) ||
                dataMovimentacao.isAtSameMomentAs(_dataInicial!));
      }
      if (_dataFinal != null) {
        dentroDoIntervalo = dentroDoIntervalo &&
            (dataMovimentacao.isBefore(_dataFinal!) ||
                dataMovimentacao.isAtSameMomentAs(_dataFinal!));
      }

      return dentroDoIntervalo;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final movimentacoesProvider = Provider.of<MovimentacoesProvider>(context);
    final movimentacoesFiltradas =
        _filtrarMovimentacoes(movimentacoesProvider.movimentacoes);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gráficos"),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 7,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedChartIndex == 0
                                ? "Saldo acumulado (R\$)"
                                : _selectedChartIndex == 1
                                    ? "Progresso dos Objetivos"
                                    : "Categorias mais utilizadas",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.swap_horiz),
                          onPressed: _switchChart,
                          tooltip: 'Alternar gráfico',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _selectedChartIndex = index;
                        });
                      },
                      children: [
                        _buildLineChart(movimentacoesFiltradas),
                        _buildGaugeChart(context),
                        _buildBarChart(movimentacoesFiltradas),
                      ],
                    ),
                  ),
                  if (_selectedChartIndex == 0) ...[
                    const SizedBox(height: 8),
                    _buildLegend(movimentacoesFiltradas),
                  ],
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: "Data Inicial",
                              labelStyle: const TextStyle(fontSize: 14),
                              suffixIcon:
                                  const Icon(Icons.calendar_today, size: 20),
                              isDense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                            controller: TextEditingController(
                              text: _dataInicial != null
                                  ? "${_dataInicial!.day}/${_dataInicial!.month}/${_dataInicial!.year}"
                                  : "",
                            ),
                            onTap: () => _selecionarData(context, true),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: "Data Final",
                              labelStyle: const TextStyle(fontSize: 14),
                              suffixIcon:
                                  const Icon(Icons.calendar_today, size: 20),
                              isDense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                            controller: TextEditingController(
                              text: _dataFinal != null
                                  ? "${_dataFinal!.day}/${_dataFinal!.month}/${_dataFinal!.year}"
                                  : "",
                            ),
                            onTap: () => _selecionarData(context, false),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 1,
            color: Colors.grey[300],
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                  child: Row(
                    children: [
                      const Text(
                        "Extrato",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "${movimentacoesFiltradas.length} itens",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildExtratoListMinimalista(movimentacoesFiltradas),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(List<Map<String, String>> movimentacoes) {
    List<FlSpot> saldoAcumulado = [];
    double saldo = 0;

    for (int i = 0; i < movimentacoes.length; i++) {
      final movimentacao = movimentacoes[i];
      final valor = double.parse(
          movimentacao["valor"]!.replaceAll("R\$", "").replaceAll(",", "."));
      if (movimentacao["tipo"] == "Receita") {
        saldo += valor;
      } else {
        saldo -= valor;
      }
      saldoAcumulado.add(FlSpot(i.toDouble(), saldo));
    }

    final Color lineColor = saldo >= 0 ? Colors.green : Colors.red;

    double minY = saldoAcumulado.isNotEmpty
        ? saldoAcumulado.map((spot) => spot.y).reduce((a, b) => a < b ? a : b) -
            100
        : -500;
    double maxY = saldoAcumulado.isNotEmpty
        ? saldoAcumulado.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) +
            100
        : 500;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 500,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[300],
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey[300],
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 500,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  "R\$ ${value.toInt()}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 20,
              interval: 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  "${value.toInt() + 1}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: Colors.grey[400]!,
            width: 1,
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: saldoAcumulado,
            isCurved: true,
            color: lineColor,
            barWidth: 3,
            belowBarData: BarAreaData(
              show: true,
              color: lineColor.withOpacity(0.2),
            ),
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: lineColor,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
          ),
        ],
        lineTouchData: LineTouchData(enabled: false),
        minY: minY,
        maxY: maxY,
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: 0,
              color: lineColor,
              strokeWidth: 2,
              dashArray: [5, 5],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGaugeChart(BuildContext context) {
    final objetivoProvider =
        Provider.of<ObjetivoProvider>(context, listen: true);
    final objetivos = objetivoProvider.objetivosAtivos;

    if (objetivos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flag, size: 50, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              "Nenhum objetivo ativo",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ObjetivoScreen()),
                );
              },
              child: const Text('Criar Objetivos'),
            ),
          ],
        ),
      );
    }

    double totalMeta = objetivos.fold(0, (sum, obj) => sum + obj.meta);
    double totalAtual = objetivos.fold(0, (sum, obj) => sum + obj.valorAtual);
    double progresso = (totalAtual / totalMeta) * 100;
    double restante = totalMeta - totalAtual;

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            "Progresso dos Objetivos",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                  minimum: 0,
                  maximum: 100,
                  showLabels: true,
                  showTicks: true,
                  radiusFactor: 0.8,
                  axisLineStyle: AxisLineStyle(
                    thickness: 0.2,
                    color: Colors.grey.withOpacity(0.2),
                    thicknessUnit: GaugeSizeUnit.factor,
                  ),
                  ranges: <GaugeRange>[
                    GaugeRange(
                      startValue: 0,
                      endValue: progresso,
                      color: Colors.green,
                      startWidth: 0.2,
                      endWidth: 0.2,
                    ),
                  ],
                  pointers: <GaugePointer>[
                    NeedlePointer(
                      value: progresso,
                      needleLength: 0.6,
                      needleStartWidth: 1,
                      needleEndWidth: 5,
                      knobStyle: KnobStyle(
                        knobRadius: 0.08,
                        color: Colors.green,
                      ),
                    ),
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      positionFactor: 0.5,
                      angle: 90,
                      widget: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${progresso.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Concluído',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Arrecadado',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'R\$ ${totalAtual.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Faltam',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'R\$ ${restante.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: progresso / 100,
                    backgroundColor: Colors.grey[200],
                    color: Colors.green,
                    minHeight: 8,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Meta Total',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        'R\$ ${totalMeta.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Objetivos Ativos',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${objetivos.length}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildBarChart(List<Map<String, String>> movimentacoes) {
    Map<String, double> receitasPorCategoria = {};
    Map<String, double> despesasPorCategoria = {};

    for (var movimentacao in movimentacoes) {
      final valor = double.parse(
          movimentacao["valor"]!.replaceAll("R\$", "").replaceAll(",", "."));
      final categoria = movimentacao["categoria"]!;
      final tipo = movimentacao["tipo"]!;

      if (tipo == "Receita") {
        receitasPorCategoria.update(
          categoria,
          (existing) => existing + valor,
          ifAbsent: () => valor,
        );
      } else {
        despesasPorCategoria.update(
          categoria,
          (existing) => existing + valor,
          ifAbsent: () => valor,
        );
      }
    }

    final todasCategorias =
        {...receitasPorCategoria.keys, ...despesasPorCategoria.keys}.toList();

    if (receitasPorCategoria.isEmpty && despesasPorCategoria.isEmpty) {
      return const Center(
        child: Text(
          "Nenhum dado disponível",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _calculateMaxY(receitasPorCategoria, despesasPorCategoria),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.grey[800],
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final categoria = todasCategorias[group.x.toInt()];
              final isReceita = rodIndex == 0;
              final valor = isReceita
                  ? receitasPorCategoria[categoria] ?? 0
                  : despesasPorCategoria[categoria] ?? 0;

              return BarTooltipItem(
                '$categoria\n${isReceita ? 'Receita' : 'Despesa'}: R\$ ${valor.toStringAsFixed(2)}',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: _calculateInterval(
                  receitasPorCategoria, despesasPorCategoria),
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  "R\$ ${value.toInt()}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (double value, TitleMeta meta) {
                final index = value.toInt();
                if (index >= 0 && index < todasCategorias.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      todasCategorias[index],
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: Colors.grey[400]!,
            width: 1,
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval:
              _calculateInterval(receitasPorCategoria, despesasPorCategoria),
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[300],
              strokeWidth: 1,
            );
          },
        ),
        barGroups: _buildBarGroups(
            receitasPorCategoria, despesasPorCategoria, todasCategorias),
      ),
    );
  }

  double _calculateMaxY(
      Map<String, double> receitas, Map<String, double> despesas) {
    final maxReceita = receitas.values.isNotEmpty
        ? receitas.values.reduce((a, b) => a > b ? a : b)
        : 0;
    final maxDespesa = despesas.values.isNotEmpty
        ? despesas.values.reduce((a, b) => a > b ? a : b)
        : 0;
    final maxValue = maxReceita > maxDespesa ? maxReceita : maxDespesa;
    return (maxValue * 1.2).ceilToDouble();
  }

  double _calculateInterval(
      Map<String, double> receitas, Map<String, double> despesas) {
    final maxY = _calculateMaxY(receitas, despesas);
    if (maxY <= 500) return 100;
    if (maxY <= 1000) return 200;
    if (maxY <= 5000) return 500;
    return 1000;
  }

  List<BarChartGroupData> _buildBarGroups(Map<String, double> receitas,
      Map<String, double> despesas, List<String> todasCategorias) {
    return List.generate(todasCategorias.length, (index) {
      final categoria = todasCategorias[index];
      final receita = receitas[categoria] ?? 0;
      final despesa = despesas[categoria] ?? 0;

      return BarChartGroupData(
        x: index,
        groupVertically: true,
        barRods: [
          BarChartRodData(
            toY: receita,
            color: Colors.green,
            width: 12,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(2),
              topRight: Radius.circular(2),
            ),
          ),
          BarChartRodData(
            toY: despesa,
            color: Colors.red,
            width: 12,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(2),
              topRight: Radius.circular(2),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildLegend(List<Map<String, String>> movimentacoes) {
    double saldo = 0;

    for (var movimentacao in movimentacoes) {
      final valor = double.parse(
          movimentacao["valor"]!.replaceAll("R\$", "").replaceAll(",", "."));
      if (movimentacao["tipo"] == "Receita") {
        saldo += valor;
      } else {
        saldo -= valor;
      }
    }

    final Color lineColor = saldo >= 0 ? Colors.green : Colors.red;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 15,
          height: 15,
          decoration: BoxDecoration(
            color: lineColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          saldo >= 0 ? "Saldo Positivo" : "Saldo Negativo",
          style: TextStyle(
            fontSize: 14,
            color: lineColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildExtratoListMinimalista(
      List<Map<String, String>> movimentacoesFiltradas) {
    if (movimentacoesFiltradas.isEmpty) {
      return const Center(
        child: Text(
          "Nenhuma movimentação no período",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: movimentacoesFiltradas.length,
      itemBuilder: (context, index) {
        final movimentacao = movimentacoesFiltradas[index];
        final valor = movimentacao["valor"]!;
        final tipo = movimentacao["tipo"]!;
        final nome = movimentacao["nome"]!;
        final data = movimentacao["data"]!;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: tipo == "Receita"
                    ? Colors.green.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                tipo == "Receita" ? Icons.arrow_upward : Icons.arrow_downward,
                size: 18,
                color: tipo == "Receita" ? Colors.green : Colors.red,
              ),
            ),
            title: Text(
              nome,
              style: const TextStyle(fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              data,
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Text(
              valor,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: tipo == "Receita" ? Colors.green : Colors.red,
              ),
            ),
            dense: true,
          ),
        );
      },
    );
  }
}
