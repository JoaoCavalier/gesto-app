import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projeto_flutter/services/authentication.service.dart';
import 'package:projeto_flutter/services/inter_http_client.dart';
import 'package:projeto_flutter/services/inter_service.dart';
import 'package:projeto_flutter/telas/grafico.dart';
import 'package:projeto_flutter/telas/home.dart';
import 'package:projeto_flutter/telas/movimentacoes.dart';
import 'package:projeto_flutter/telas/objetivo.dart';
import 'package:projeto_flutter/telas/usuario.dart';
import 'package:provider/provider.dart';

class CartaoScreen extends StatefulWidget {
  const CartaoScreen({super.key});

  @override
  State<CartaoScreen> createState() => _CartaoScreenState();
}

class _CartaoScreenState extends State<CartaoScreen> {
  final InterHttpClient httpClientWithCert = InterHttpClient();
  final InterService interService = InterService(InterHttpClient());
  List<dynamic> transacoes = [];
  bool _isLoading = false;
  String _errorMessage = '';

  final NumberFormat currencyFormat =
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _carregarTransacoes();
  }

  Future<void> _carregarTransacoes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await interService.obterBoletos();
      final jsonResponse = json.decode(response.body);
      print('Resposta da API: $jsonResponse');

      if (jsonResponse.containsKey('transacoes') &&
          jsonResponse['transacoes'] is List) {
        setState(() {
          transacoes = jsonResponse['transacoes'];
        });

        // Adiciona as transações ao MovimentacoesProvider
        final movimentacoesProvider =
            Provider.of<MovimentacoesProvider>(context, listen: false);

        // Verifica se as transações já foram adicionadas
        if (movimentacoesProvider.transacoesCartao.isEmpty) {
          for (var transacao in transacoes) {
            // Todas as transações do cartão são receitas
            movimentacoesProvider.addTransacaoCartao({
              ...transacao,
              'tipo': 'Receita', // Define o tipo como Receita
            });
          }
        }
      } else {
        setState(() {
          _errorMessage = 'Nenhuma transação encontrada ou formato inválido.';
        });
      }
    } catch (e) {
      print('Erro ao carregar transações: $e');
      setState(() {
        _errorMessage = 'Erro ao carregar transações. Tente novamente.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Conta Bancaria",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange, // Cor laranja para o AppBar
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green, // Cor laranja para o DrawerHeader
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Menu",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Tela de Cartão",
                    style: TextStyle(
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
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const UsuarioScreen()));
              },
            ),
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.green),
              title: const Text("Home"),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const HomeScreen()));
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
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const CartaoScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_graph, color: Colors.green),
              title: const Text("Gráficos"),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const GraficoScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.task_alt, color: Colors.green),
              title: const Text("Objetivos"),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const ObjetivoScreen()));
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
        color: Colors.white,
        child: Column(
          children: [
            // Card estilizado com informações do banco
            Container(
              width: double.infinity, // Ocupa a largura total da tela
              margin: const EdgeInsets.all(0), // Remove a margem
              decoration: BoxDecoration(
                color: Colors.orange, // Cor laranja
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Banco Inter",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Agência: 0001",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Conta: 123456-7",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Número do Banco: 077",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.orange, // Cor laranja para o loading
                      ),
                    )
                  : _errorMessage.isNotEmpty
                      ? Center(
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black87,
                            ),
                          ),
                        )
                      : transacoes.isEmpty
                          ? const Center(
                              child: Text(
                                "Nenhuma transação encontrada.",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16.0),
                              itemCount: transacoes.length,
                              itemBuilder: (context, index) {
                                final transacao = transacoes[index];
                                return Card(
                                  elevation: 2.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  margin: const EdgeInsets.only(bottom: 16.0),
                                  child: ListTile(
                                    title: Text(
                                      transacao['titulo'] ?? 'Sem Título',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 8),
                                        Text(
                                          'Data de Entrada: ${dateFormat.format(DateTime.parse(transacao['dataEntrada'] ?? DateTime.now().toString()))}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Tipo de Transação: ${transacao['tipoTransacao'] ?? 'N/A'}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Valor: ${currencyFormat.format(double.tryParse(transacao['valor'].toString()) ?? 0)}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}