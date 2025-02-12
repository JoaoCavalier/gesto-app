import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projeto_flutter/services/authentication.service.dart';
import 'package:projeto_flutter/services/inter_http_client.dart';
import 'package:projeto_flutter/services/inter_service.dart';
import 'package:projeto_flutter/telas/despesas.dart';
import 'package:projeto_flutter/telas/grafico.dart';
import 'package:projeto_flutter/telas/home.dart';
import 'package:projeto_flutter/telas/objetivo.dart';
import 'package:projeto_flutter/telas/receitas.dart';
import 'package:projeto_flutter/telas/usuario.dart';

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

  final NumberFormat currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
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
      print('Resposta da API: $jsonResponse'); // Depuração: exibe a resposta completa

      // Verifique se a resposta contém a chave 'transacoes'
      if (jsonResponse.containsKey('transacoes') && jsonResponse['transacoes'] is List) {
        setState(() {
          transacoes = jsonResponse['transacoes'];
        });
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
          "Cartão",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        elevation: 0,
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
                  const SizedBox(height: 8),
                  const Text(
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
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => UsuarioScreen()));
              },
            ),
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.green),
              title: const Text("Home"),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomeScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money_sharp, color: Colors.green),
              title: const Text("Receitas"),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => ReceitasScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.money_off, color: Colors.green),
              title: const Text("Despesas"),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => DespesasScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.credit_card, color: Colors.green),
              title: const Text("Cartão"),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => CartaoScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_graph, color: Colors.green),
              title: const Text("Gráficos"),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => GraficoScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.task_alt, color: Colors.green),
              title: const Text("Objetivos"),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => ObjetivoScreem()));
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
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.green,
                ),
              )
            : _errorMessage.isNotEmpty
                ? Center(
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(
                        fontSize: 16,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
    );
  }
}