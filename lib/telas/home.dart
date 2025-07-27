import 'package:flutter/material.dart';
import 'package:projeto_flutter/telas/objetivo.dart';
import 'package:provider/provider.dart';
import 'package:projeto_flutter/services/authentication.service.dart';
import 'package:projeto_flutter/telas/cartao.dart';
import 'package:projeto_flutter/telas/grafico.dart';
import 'package:projeto_flutter/telas/movimentacoes.dart';
import 'package:projeto_flutter/telas/usuario.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showLastMovements = false;
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    String? userName =
        Provider.of<SharedPreferences>(context).getString('userName');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "💵 Olá, $userName!",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              // Limpa todos os dados
              await Provider.of<MovimentacoesProvider>(context, listen: false)
                  .clearAllData();
              // Mostra uma mensagem de sucesso
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Dados resetados com sucesso!")),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.green,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    "Menu",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (userName != null && userName.isNotEmpty)
                    Text(
                      "Olá, $userName!",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.green),
              title: const Text("Usuário"),
              onTap: () {
                _navigateWithLoading(context, const UsuarioScreen());
              },
            ),
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.green),
              title: const Text("Home"),
              onTap: () {
                _navigateWithLoading(context, const HomeScreen());
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.attach_money_sharp, color: Colors.green),
              title: const Text("Movimentações"),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const MovimentacoesScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.credit_card, color: Colors.green),
              title: const Text("Conta Bancaria"),
              onTap: () {
                _navigateWithLoading(context, const CartaoScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_graph, color: Colors.green),
              title: const Text("Gráficos"),
              onTap: () {
                _navigateWithLoading(context, const GraficoScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.task_alt, color: Colors.green),
              title: const Text("Objetivos"),
              onTap: () {
                _navigateWithLoading(context, const ObjetivoScreen());
              },
            ),
            const Divider(color: Colors.grey),
            ListTile(
              iconColor: Colors.red,
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () {
                AuthenticationService().logout();
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer<MovimentacoesProvider>(
              builder: (context, movimentacoesProvider, child) {
                return Column(
                  children: [
                    if (userName != null && userName.isNotEmpty)
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.only(top: 10.0, left: 10.0),
                        ),
                      ),
                    // Gráfico de Pizza (dentro de um Card)
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const GraficoScreen(),
                        ));
                      },
                      child: Card(
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Movimentações financeiras",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                "${_getStartOfMonth()} - ${_getEndOfMonth()}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 35),
                              SizedBox(
                                height: 150,
                                child: PieChart(
                                  PieChartData(
                                    sections: _getPieChartSections(
                                        movimentacoesProvider),
                                    centerSpaceRadius: 30,
                                    sectionsSpace: 0,
                                    pieTouchData: PieTouchData(
                                      touchCallback: (FlTouchEvent event,
                                          pieTouchResponse) {
                                        setState(() {
                                          if (!event
                                                  .isInterestedForInteractions ||
                                              pieTouchResponse == null ||
                                              pieTouchResponse.touchedSection ==
                                                  null) {
                                            _touchedIndex = -1;
                                            return;
                                          }
                                          _touchedIndex = pieTouchResponse
                                              .touchedSection!
                                              .touchedSectionIndex;
                                        });
                                      },
                                      enabled: true,
                                      mouseCursorResolver: (event, response) {
                                        return SystemMouseCursors.click;
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 35),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 15,
                                        height: 15,
                                        color: Colors.green,
                                      ),
                                      const SizedBox(width: 5),
                                      const Text("Receita",
                                          style: TextStyle(fontSize: 14)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width: 15,
                                        height: 15,
                                        color: Colors.red,
                                      ),
                                      const SizedBox(width: 5),
                                      const Text("Despesa",
                                          style: TextStyle(fontSize: 14)),
                                    ],
                                  ),
                                ],
                              ),
                              if (_touchedIndex != null && _touchedIndex != -1)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: Text(
                                    _touchedIndex == 0
                                        ? "Receita: R\$ ${NumberFormat.currency(locale: 'pt_BR', symbol: '').format(_calculateReceitas(movimentacoesProvider) + _calculateSaldoCartao(movimentacoesProvider))}"
                                        : "Despesa: R\$ ${NumberFormat.currency(locale: 'pt_BR', symbol: '').format(_calculateDespesas(movimentacoesProvider))}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: _touchedIndex == 0
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Saldo",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  "${_getStartOfMonth()} - ${_getEndOfMonth()}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Text(
                                  "R\$ ${NumberFormat.currency(locale: 'pt_BR', symbol: '').format(_calculateBalance(movimentacoesProvider))}",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: _calculateBalance(
                                                movimentacoesProvider) >=
                                            0
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Icon(
                                  _calculateBalance(movimentacoesProvider) >= 0
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  color: _calculateBalance(
                                              movimentacoesProvider) >=
                                          0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Última Movimentação (dentro de um Card)
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const MovimentacoesScreen(),
                        ));
                      },
                      child: Card(
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Última Movimentação",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Consumer<MovimentacoesProvider>(
                                builder:
                                    (context, movimentacoesProvider, child) {
                                  final lastMovement =
                                      _getLastMovement(movimentacoesProvider);
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (lastMovement != null) ...[
                                        Text(
                                          "${lastMovement['tipo']}: ${lastMovement['nome']}",
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Valor: ${lastMovement['valor']}",
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Data: ${lastMovement['data']}",
                                          style: const TextStyle(
                                              fontSize: 14, color: Colors.grey),
                                        ),
                                      ] else
                                        const Text(
                                          "Nenhuma movimentação recente.",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                    ],
                                  );
                                },
                              ),
                              ExpansionTile(
                                initiallyExpanded: _showLastMovements,
                                onExpansionChanged: (expanded) {
                                  setState(() {
                                    _showLastMovements = expanded;
                                  });
                                },
                                title: const Text(
                                  "Ver últimas movimentações",
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.green),
                                ),
                                trailing: Icon(
                                  _showLastMovements
                                      ? Icons.arrow_drop_up
                                      : Icons.arrow_drop_down,
                                  color: Colors.green,
                                ),
                                children: [
                                  Consumer<MovimentacoesProvider>(
                                    builder: (context, movimentacoesProvider,
                                        child) {
                                      final lastMovements =
                                          _getLastThreeMovements(
                                              movimentacoesProvider);
                                      if (lastMovements.isNotEmpty) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          height: 150,
                                          child: ListView(
                                            children:
                                                lastMovements.map((movement) {
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "${movement['tipo']}: ${movement['nome']}",
                                                    style: const TextStyle(
                                                        fontSize: 16),
                                                  ),
                                                  Text(
                                                    "Valor: ${movement['valor']}",
                                                    style: const TextStyle(
                                                        fontSize: 16),
                                                  ),
                                                  Text(
                                                    "Data: ${movement['data']}",
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey),
                                                  ),
                                                  const SizedBox(height: 10),
                                                ],
                                              );
                                            }).toList(),
                                          ),
                                        );
                                      } else {
                                        return const Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: Text(
                                            "Nenhuma movimentação recente.",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  String _getStartOfMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    return DateFormat('dd/MM/yyyy').format(startOfMonth);
  }

  String _getEndOfMonth() {
    final now = DateTime.now();
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    return DateFormat('dd/MM/yyyy').format(endOfMonth);
  }

  List<PieChartSectionData> _getPieChartSections(
      MovimentacoesProvider provider) {
    final double receitas = _calculateReceitas(provider);
    final double despesas = _calculateDespesas(provider);
    final double saldoCartao = _calculateSaldoCartao(provider);
    final double total = receitas + despesas + saldoCartao;

    if (total == 0) {
      return [
        PieChartSectionData(
          color: Colors.grey[400],
          value: 1,
          title: '0%',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ];
    }

    return [
      PieChartSectionData(
        color: Colors.green,
        value: receitas + saldoCartao,
        title:
            '${(((receitas + saldoCartao) / total) * 100).toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.red,
        value: despesas,
        title: '${((despesas / total) * 100).toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  void _navigateWithLoading(BuildContext context, Widget screen) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).pop();
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => screen));
    });
  }

  double _calculateBalance(MovimentacoesProvider provider) {
    final double receitas = _calculateReceitas(provider);
    final double despesas = _calculateDespesas(provider);
    final double saldoCartao = _calculateSaldoCartao(provider);
    return (receitas + saldoCartao) - despesas;
  }

  double _calculateReceitas(MovimentacoesProvider provider) {
    return provider.movimentacoes
        .where((mov) => mov['tipo'] == 'Receita')
        .map((mov) => double.parse(
            mov["valor"]!.replaceAll("R\$", "").replaceAll(",", ".")))
        .fold(0, (prev, amount) => prev + amount);
  }

  double _calculateDespesas(MovimentacoesProvider provider) {
    return provider.movimentacoes
        .where((mov) => mov['tipo'] == 'Despesa')
        .map((mov) => double.parse(
            mov["valor"]!.replaceAll("R\$", "").replaceAll(",", ".")))
        .fold(0, (prev, amount) => prev + amount);
  }

  double _calculateSaldoCartao(MovimentacoesProvider provider) {
    return provider.transacoesCartao
        .map((transacao) => double.parse(transacao["valor"]
            .toString()
            .replaceAll("R\$", "")
            .replaceAll(",", ".")))
        .fold(0, (prev, amount) => prev + amount);
  }

  Map<String, dynamic>? _getLastMovement(MovimentacoesProvider provider) {
    if (provider.movimentacoes.isEmpty) return null;
    return provider.movimentacoes.last;
  }

  List<Map<String, dynamic>> _getLastThreeMovements(
      MovimentacoesProvider provider) {
    if (provider.movimentacoes.isEmpty) return [];
    return provider.movimentacoes.reversed.take(3).toList();
  }
}