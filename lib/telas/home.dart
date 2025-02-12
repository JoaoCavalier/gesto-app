import 'package:flutter/material.dart';
import 'package:projeto_flutter/providers/despesas_provider.dart';
import 'package:projeto_flutter/providers/receitas_provider.dart';
import 'package:projeto_flutter/telas/objetivo.dart';
import 'package:provider/provider.dart';
import 'package:projeto_flutter/services/authentication.service.dart';
import 'package:projeto_flutter/telas/cartao.dart';
import 'package:projeto_flutter/telas/despesas.dart';
import 'package:projeto_flutter/telas/grafico.dart';
import 'package:projeto_flutter/telas/receitas.dart';
import 'package:projeto_flutter/telas/usuario.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showLastMovements = false; // Controla a exibição da gaveta

  @override
  Widget build(BuildContext context) {
    String? userName =
        Provider.of<SharedPreferences>(context).getString('userName');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tela Principal",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green, // AppBar verde
        elevation: 0, // Remove a sombra da AppBar
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.green, // Fundo verde
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
                _navigateWithLoading(context, UsuarioScreen());
              },
            ),
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.green),
              title: const Text("Home"),
              onTap: () {
                _navigateWithLoading(context, HomeScreen());
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.attach_money_sharp, color: Colors.green),
              title: const Text("Receitas"),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ReceitasScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.money_off, color: Colors.green),
              title: const Text("Despesas"),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => DespesasScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.credit_card, color: Colors.green),
              title: const Text("Cartão"),
              onTap: () {
                _navigateWithLoading(context, CartaoScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_graph, color: Colors.green),
              title: const Text("Gráficos"),
              onTap: () {
                _navigateWithLoading(context, GraficoScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.task_alt, color: Colors.green),
              title: const Text("Objetivos"),
              onTap: () {
                _navigateWithLoading(context, ObjetivoScreem());
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
      body: Container(
        color: Colors.white, // Fundo branco
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Mensagem de boas-vindas no canto superior esquerdo
              if (userName != null && userName.isNotEmpty)
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0, left: 10.0),
                    child: Text(
                      "💵 Olá, $userName!",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              // Card de Saldo (ocupa a tela inteira)
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
                      const Text(
                        "Saldo",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            "R\$ ${NumberFormat.currency(locale: 'pt_BR', symbol: '').format(_calculateBalance())}",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _calculateBalance() >= 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            _calculateBalance() >= 0
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: _calculateBalance() >= 0
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
              // Card de Receitas e Despesas (dividido em duas colunas)
              Card(
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Receitas
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Receitas",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "R\$ ${NumberFormat.currency(locale: 'pt_BR', symbol: '').format(Provider.of<ReceitasProvider>(context).receitas.isEmpty ? 0 : Provider.of<ReceitasProvider>(context).receitas.map((e) => double.parse(e["valor"]!.replaceAll("R\$", "").replaceAll(",", "."))).reduce((value, element) => value + element))}",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Despesas
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              "Despesas",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "R\$ ${NumberFormat.currency(locale: 'pt_BR', symbol: '').format(Provider.of<DespesasProvider>(context).despesas.isEmpty ? 0 : Provider.of<DespesasProvider>(context).despesas.map((e) => double.parse(e["valor"]!.replaceAll("R\$", "").replaceAll(",", "."))).reduce((value, element) => value + element))}",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Card de Última Movimentação (tamanho fixo)
              Card(
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Container(
                  width: double.infinity, // Ocupa a largura da tela
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
                      Consumer2<ReceitasProvider, DespesasProvider>(
                        builder: (context, receitasProvider, despesasProvider,
                            child) {
                          final lastMovement = _getLastMovement(
                              receitasProvider, despesasProvider);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                      // Gaveta de últimas movimentações
                      ExpansionTile(
                        initiallyExpanded: _showLastMovements,
                        onExpansionChanged: (expanded) {
                          setState(() {
                            _showLastMovements = expanded;
                          });
                        },
                        title: const Text(
                          "Ver últimas movimentações",
                          style: TextStyle(fontSize: 14, color: Colors.green),
                        ),
                        trailing: Icon(
                          _showLastMovements
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          color: Colors.green,
                        ),
                        children: [
                          Consumer2<ReceitasProvider, DespesasProvider>(
                            builder: (context, receitasProvider,
                                despesasProvider, child) {
                              final lastMovements = _getLastThreeMovements(
                                  receitasProvider, despesasProvider);
                              if (lastMovements.isNotEmpty) {
                                return Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  height: 150, // Altura fixa para a gaveta
                                  child: ListView(
                                    children: lastMovements.map((movement) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${movement['tipo']}: ${movement['nome']}",
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                          Text(
                                            "Valor: ${movement['valor']}",
                                            style:
                                                const TextStyle(fontSize: 16),
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
                                  padding: EdgeInsets.symmetric(vertical: 10),
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
            ],
          ),
        ),
      ),
    );
  }

  void _navigateWithLoading(BuildContext context, Widget screen) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).pop(); // Remove o loading
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => screen));
    });
  }

  double _calculateBalance() {
    double totalReceitas =
        Provider.of<ReceitasProvider>(context).receitas.isEmpty
            ? 0
            : Provider.of<ReceitasProvider>(context)
                .receitas
                .map((e) => double.parse(
                    e["valor"]!.replaceAll("R\$", "").replaceAll(",", ".")))
                .reduce((value, element) => value + element);

    double totalDespesas =
        Provider.of<DespesasProvider>(context).despesas.isEmpty
            ? 0
            : Provider.of<DespesasProvider>(context)
                .despesas
                .map((e) => double.parse(
                    e["valor"]!.replaceAll("R\$", "").replaceAll(",", ".")))
                .reduce((value, element) => value + element);

    return totalReceitas - totalDespesas;
  }

  Map<String, dynamic>? _getLastMovement(
      ReceitasProvider receitasProvider, DespesasProvider despesasProvider) {
    List<Map<String, dynamic>> allMovements = [];

    // Adiciona todas as receitas
    for (var receita in receitasProvider.receitas) {
      allMovements.add({
        'tipo': 'Receita',
        'nome': receita['nome'],
        'valor': receita['valor'],
        'data': receita['data'],
      });
    }

    // Adiciona todas as despesas
    for (var despesa in despesasProvider.despesas) {
      allMovements.add({
        'tipo': 'Despesa',
        'nome': despesa['nome'],
        'valor': despesa['valor'],
        'data': despesa['data'],
      });
    }

    // Ordena as movimentações pela data
    allMovements.sort((a, b) => DateFormat('dd/MM/yyyy')
        .parse(b['data'])
        .compareTo(DateFormat('dd/MM/yyyy').parse(a['data'])));

    // Retorna a última movimentação ou null se não houver
    return allMovements.isNotEmpty ? allMovements.last : null;
  }

  List<Map<String, dynamic>> _getLastThreeMovements(
      ReceitasProvider receitasProvider, DespesasProvider despesasProvider) {
    List<Map<String, dynamic>> allMovements = [];

    // Adiciona todas as receitas
    for (var receita in receitasProvider.receitas) {
      allMovements.add({
        'tipo': 'Receita',
        'nome': receita['nome'],
        'valor': receita['valor'],
        'data': receita['data'],
      });
    }

    // Adiciona todas as despesas
    for (var despesa in despesasProvider.despesas) {
      allMovements.add({
        'tipo': 'Despesa',
        'nome': despesa['nome'],
        'valor': despesa['valor'],
        'data': despesa['data'],
      });
    }

    // Ordena as movimentações pela data
    allMovements.sort((a, b) => DateFormat('dd/MM/yyyy')
        .parse(b['data'])
        .compareTo(DateFormat('dd/MM/yyyy').parse(a['data'])));

    // Retorna as últimas 3 movimentações
    return allMovements.take(3).toList();
  }
}
