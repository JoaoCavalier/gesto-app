import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:provider/provider.dart';
import 'package:projeto_flutter/telas/movimentacoes.dart';
import 'package:projeto_flutter/telas/objetivo.dart';
import 'package:intl/intl.dart';

class GraficoScreen extends StatefulWidget {
  const GraficoScreen({super.key});

  @override
  State<GraficoScreen> createState() => _GraficoScreenState();
}

class _GraficoScreenState extends State<GraficoScreen> {
  int _selectedChartIndex = 0;
  DateTime? _dataInicial;
  DateTime? _dataFinal;
  final PageController _pageController = PageController();
  final NumberFormat _formatoReal = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  // Paleta de cores para Receitas (tons de verde)
  final List<Color> _coresReceitas = [
    const Color(0xFF2E7D32),
    const Color(0xFF4CAF50),
    const Color(0xFF81C784),

  ];

  // Paleta de cores para Despesas (tons de vermelho)
  final List<Color> _coresDespesas = [
    const Color(0xFFC62828),
    const Color(0xFFF44336),
    const Color(0xFFE57373),
  ];

  @override
  void initState() {
    super.initState();
    Provider.of<ObjetivoProvider>(context, listen: false).carregarObjetivos();
  }

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

  Widget _buildInfoItem(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatoReal.format(value),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  double _calculateInterval(double range) {
    if (range <= 500) return 100;
    if (range <= 1000) return 200;
    if (range <= 5000) return 500;
    return 1000;
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
    List<String> datas = [];
    double saldo = 0;
    double saldoMaximo = 0;
    double saldoMinimo = 0;
    List<Map<String, dynamic>> tooltipData = [];

    for (int i = 0; i < movimentacoes.length; i++) {
      final movimentacao = movimentacoes[i];
      final valor = double.parse(
          movimentacao["valor"]!.replaceAll("R\$", "").replaceAll(",", "."));
      if (movimentacao["tipo"] == "Receita") {
        saldo += valor;
      } else {
        saldo -= valor;
      }

      if (saldo > saldoMaximo) saldoMaximo = saldo;
      if (saldo < saldoMinimo) saldoMinimo = saldo;

      saldoAcumulado.add(FlSpot(i.toDouble(), saldo));
      datas.add(movimentacao["data"]!);

      tooltipData.add({
        'data': movimentacao["data"]!,
        'valor': movimentacao["valor"]!,
        'tipo': movimentacao["tipo"]!,
        'nome': movimentacao["nome"]!,
        'saldo': saldo,
      });
    }

    final Color lineColor = saldo >= 0 ? Colors.green : Colors.red;
    final double saldoAtual =
        saldoAcumulado.isNotEmpty ? saldoAcumulado.last.y.toDouble() : 0.0;

    double minY =
        saldoAcumulado.isNotEmpty ? (saldoMinimo * 1.1).roundToDouble() : -500;
    double maxY =
        saldoAcumulado.isNotEmpty ? (saldoMaximo * 1.1).roundToDouble() : 500;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem("Saldo Atual", saldoAtual, lineColor),
              _buildInfoItem("Máximo", saldoMaximo, Colors.blue),
              _buildInfoItem("Mínimo", saldoMinimo, Colors.orange),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _calculateInterval(maxY - minY),
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300]!,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: (movimentacoes.length / 5).ceilToDouble(),
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < datas.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              datas[index],
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black54,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: _calculateInterval(maxY - minY),
                      reservedSize: 40,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          _formatoReal.format(value),
                          style: const TextStyle(
                            fontSize: 10,
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
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Colors.grey[800]!,
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((spot) {
                        final index = spot.spotIndex;
                        final data = tooltipData[index];
                        return LineTooltipItem(
                          '${data['data']}\n'
                          '${data['tipo']}: ${data['valor']}\n'
                          'Saldo: ${_formatoReal.format(data['saldo'])}',
                          const TextStyle(color: Colors.white),
                        );
                      }).toList();
                    },
                  ),
                ),
                minY: minY,
                maxY: maxY,
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: 0,
                      color: Colors.grey,
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    ),
                    if (saldoMaximo != 0)
                      HorizontalLine(
                        y: saldoMaximo,
                        color: Colors.blue.withOpacity(0.3),
                        strokeWidth: 1,
                        dashArray: [5, 5],
                        label: HorizontalLineLabel(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 8),
                          labelResolver: (value) =>
                              'Máximo: ${_formatoReal.format(value)}',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    if (saldoMinimo != 0)
                      HorizontalLine(
                        y: saldoMinimo,
                        color: Colors.orange.withOpacity(0.3),
                        strokeWidth: 1,
                        dashArray: [5, 5],
                        label: HorizontalLineLabel(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 8),
                          labelResolver: (value) =>
                              'Mínimo: ${_formatoReal.format(value)}',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGaugeChart(BuildContext context) {
    return Consumer<ObjetivoProvider>(
      builder: (context, objetivoProvider, child) {
        final objetivosAtivos = objetivoProvider.objetivosAtivos;
        final metasBatidas = objetivoProvider.metasBatidas;

        final double totalMetas =
            (objetivosAtivos.fold<double>(0.0, (sum, obj) => sum + obj.meta)) +
                (metasBatidas.fold<double>(0.0, (sum, obj) => sum + obj.meta));

        final double totalAtual = (objetivosAtivos.fold<double>(
                0.0, (sum, obj) => sum + obj.valorAtual)) +
            (metasBatidas.fold<double>(0.0, (sum, obj) => sum + obj.meta));

        final double progresso =
            totalMetas > 0 ? (totalAtual / totalMetas) * 100 : 0.0;
        final double restante = totalMetas - totalAtual;

        Color progressColor = progresso >= 75
            ? Colors.green
            : progresso >= 50
                ? Colors.lightGreen
                : progresso >= 25
                    ? Colors.orange
                    : Colors.red;

        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Progresso Geral",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: progressColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${progresso.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: progressColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 180,
                child: SfRadialGauge(
                  axes: <RadialAxis>[
                    RadialAxis(
                      minimum: 0,
                      maximum: 100,
                      showLabels: false,
                      showTicks: false,
                      radiusFactor: 0.8,
                      axisLineStyle: AxisLineStyle(
                        thickness: 0.2,
                        color: Colors.grey.withOpacity(0.2),
                        thicknessUnit: GaugeSizeUnit.factor,
                        cornerStyle: CornerStyle.bothCurve,
                      ),
                      ranges: <GaugeRange>[
                        GaugeRange(
                          startValue: 0,
                          endValue: progresso,
                          color: progressColor,
                          startWidth: 0.2,
                          endWidth: 0.2,
                        ),
                      ],
                      pointers: <GaugePointer>[
                        NeedlePointer(
                          value: progresso,
                          needleLength: 0.6,
                          needleStartWidth: 1,
                          needleEndWidth: 8,
                          knobStyle: KnobStyle(
                            knobRadius: 0.08,
                            color: progressColor,
                            borderWidth: 0.05,
                            borderColor: progressColor.withOpacity(0.5),
                          ),
                        ),
                      ],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                          positionFactor: 0.1,
                          angle: 90,
                          widget: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${progresso.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: progressColor,
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
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildValueIndicator(
                      "Arrecadado",
                      totalAtual,
                      Colors.green,
                      Icons.arrow_upward,
                    ),
                    _buildValueIndicator(
                      "Restante",
                      restante,
                      Colors.red,
                      Icons.arrow_downward,
                    ),
                    _buildValueIndicator(
                      "Meta Total",
                      totalMetas,
                      Colors.blue,
                      Icons.flag,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (objetivosAtivos.isNotEmpty || metasBatidas.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (objetivosAtivos.isNotEmpty) ...[
                        const Text(
                          "Objetivos Ativos",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...objetivosAtivos
                            .map((obj) => _buildObjectiveItem(obj))
                            .toList(),
                      ],
                      if (metasBatidas.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          "Metas Concluídas",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...metasBatidas
                            .map((obj) =>
                                _buildObjectiveItem(obj, isConcluido: true))
                            .toList(),
                      ],
                    ],
                  ),
                ),
              ] else ...[
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.flag, size: 50, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text(
                        "Nenhum objetivo cadastrado",
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
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildValueIndicator(
      String label, double value, Color color, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatoReal.format(value),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildObjectiveItem(Objetivo objetivo, {bool isConcluido = false}) {
    final double progresso =
        isConcluido ? 100.0 : (objetivo.valorAtual / objetivo.meta) * 100.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  objetivo.nome,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    decoration: isConcluido ? TextDecoration.lineThrough : null,
                    color: isConcluido ? Colors.green : Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (objetivo.prioridade && !isConcluido)
                const Icon(Icons.star, size: 16, color: Colors.amber),
              if (isConcluido)
                const Icon(Icons.check_circle, size: 16, color: Colors.green),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progresso / 100,
            backgroundColor: Colors.grey[200],
            color: isConcluido
                ? Colors.green
                : progresso >= 75
                    ? Colors.green
                    : progresso >= 50
                        ? Colors.lightGreen
                        : progresso >= 25
                            ? Colors.orange
                            : Colors.red,
            minHeight: 6,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isConcluido
                    ? _formatoReal.format(objetivo.meta)
                    : _formatoReal.format(objetivo.valorAtual),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                _formatoReal.format(objetivo.meta),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
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

    if (receitasPorCategoria.isEmpty && despesasPorCategoria.isEmpty) {
      return const Center(
        child: Text(
          "Nenhum dado disponível",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    final totalReceitas =
        receitasPorCategoria.values.fold(0.0, (sum, value) => sum + value);
    final totalDespesas =
        despesasPorCategoria.values.fold(0.0, (sum, value) => sum + value);
    final maxY =
        (totalReceitas > totalDespesas ? totalReceitas : totalDespesas) * 1.2;

    return Column(
      children: [
        Expanded(
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              minY: 0,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Colors.grey[800],
                  tooltipMargin: 8, // Margem adicional para o tooltip
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final isReceita = group.x.toInt() == 0;
                    final categorias = isReceita
                        ? receitasPorCategoria.keys.toList()
                        : despesasPorCategoria.keys.toList();
                    final valores = isReceita
                        ? receitasPorCategoria.values.toList()
                        : despesasPorCategoria.values.toList();

                    if (rodIndex < categorias.length) {
                      return BarTooltipItem(
                        '${categorias[rodIndex]}\n${_formatoReal.format(valores[rodIndex])}',
                        const TextStyle(color: Colors.white),
                      );
                    }
                    return BarTooltipItem('', const TextStyle());
                  },
                  fitInsideVertically: true, // Ajusta verticalmente dentro do espaço disponível
                  fitInsideHorizontally: true, // Ajusta horizontalmente dentro do espaço disponível
                  direction: TooltipDirection.top, // Direção fixa para cima
                ),
              ),
              titlesData: FlTitlesData(show: false),
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: [
                // Coluna de Receitas
                BarChartGroupData(
                  x: 0,
                  groupVertically: true,
                  barRods: _buildStackedRods(receitasPorCategoria, true),
                  barsSpace: 0,
                ),
                // Coluna de Despesas
                BarChartGroupData(
                  x: 1,
                  groupVertically: true,
                  barRods: _buildStackedRods(despesasPorCategoria, false),
                  barsSpace: 0,
                ),
              ],
            ),
          ),
        ),
        // Legenda de cores
        _buildCategoryLegend(
          receitasPorCategoria,
          despesasPorCategoria,
        ),
      ],
    );
  }

  List<BarChartRodData> _buildStackedRods(
      Map<String, double> dados, bool isReceita) {
    final List<BarChartRodData> rods = [];
    double acumulado = 0;
    int colorIndex = 0;

    final sortedEntries = dados.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (var entry in sortedEntries) {
      rods.add(
        BarChartRodData(
          fromY: acumulado,
          toY: acumulado + entry.value,
          color: isReceita
              ? _coresReceitas[colorIndex % _coresReceitas.length]
              : _coresDespesas[colorIndex % _coresDespesas.length],
          width: 30,
          borderRadius: BorderRadius.zero,
        ),
      );
      acumulado += entry.value;
      colorIndex++;
    }

    return rods;
  }

  Widget _buildCategoryLegend(
      Map<String, double> receitas, Map<String, double> despesas) {
    final allCategories = {...receitas.keys, ...despesas.keys}.toList();

    return Container(
      padding: const EdgeInsets.all(8),
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: allCategories.length,
        itemBuilder: (context, index) {
          final categoria = allCategories[index];
          final isReceita = receitas.containsKey(categoria);
          final color = isReceita
              ? _coresReceitas[index % _coresReceitas.length]
              : _coresDespesas[index % _coresDespesas.length];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  color: color,
                ),
                const SizedBox(width: 4),
                Text(
                  categoria,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
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