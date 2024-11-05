import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:projeto_flutter/services/authentication.service.dart';
import 'package:projeto_flutter/telas/despesas.dart';
import 'package:projeto_flutter/services/inter_http_client.dart';
import 'package:projeto_flutter/services/inter_service.dart';
import 'package:projeto_flutter/telas/grafico.dart';
import 'package:projeto_flutter/telas/home.dart';
import 'package:projeto_flutter/telas/receitas.dart';
import 'package:projeto_flutter/_common/my_colors.dart';
import 'package:projeto_flutter/telas/usuario.dart';

class CartaoScreen extends StatefulWidget {
  const CartaoScreen({super.key});

  @override
  State<CartaoScreen> createState() => _CartaoScreenState();
}

class _CartaoScreenState extends State<CartaoScreen> {
  final InterHttpClient httpClientWithCert = InterHttpClient();
  final InterService interService = InterService(InterHttpClient());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cartão"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                MyColors.greenBottomGradient,
                MyColors.blackTopGradient
              ],
            ),
          ),
        ),
      ),
      // body: new charts.LineChart(seriesList()),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Usuário"),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => UsuarioScreen()));
              },
            ),
            const Divider(color: MyColors.blackTopGradient),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => HomeScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money_sharp),
              title: const Text("Receitas"),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ReceitasScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.money_off),
              title: const Text("Despesas"),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => DespesasScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text("Cartão"),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => CartaoScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_graph),
              title: const Text("Gráficos"),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => GraficoScreen()));
              },
            ),
            const Divider(color: MyColors.blackTopGradient),
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
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              final response = await interService.obterBoletos();
              print(response.body);
            } catch (e) {
              print('Error: $e');
            }
          },
          child: Text('Obter Boletos'),
        ),
      ),
    );
  }
}
