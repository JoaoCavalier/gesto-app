import 'package:flutter/material.dart';
import 'package:projeto_flutter/providers/despesas_provider.dart';
import 'package:projeto_flutter/providers/receitas_provider.dart';
import 'package:provider/provider.dart';
import 'package:projeto_flutter/_common/my_colors.dart';
import 'package:projeto_flutter/services/authentication.service.dart';
import 'package:projeto_flutter/telas/cartao.dart';
import 'package:projeto_flutter/telas/despesas.dart';
import 'package:projeto_flutter/telas/grafico.dart';
import 'package:projeto_flutter/telas/receitas.dart';
import 'package:projeto_flutter/telas/usuario.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tela Inicial"),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Saldo",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: double.infinity, // Add this line
                    child: Card(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      color: Color.fromARGB(200, 211, 211, 211),
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              "R\$ ${_calculateBalance().toStringAsFixed(2)}",
                              style: const TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
                height: 5), // Espaço entre o primeiro card e os dois abaixo

            Row(
              children: [
                // Card de Receitas
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Receitas",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: double.infinity,
                          child: Card(
                            elevation: 4.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            color: const Color.fromARGB(200, 76, 175, 79),
                            child: Padding(
                              padding: const EdgeInsets.all(30.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    " ${Provider.of<ReceitasProvider>(context).receitas.isEmpty ? 'R\$ 0,00' : Provider.of<ReceitasProvider>(context).receitas.map((e) => double.parse(e["valor"]!.replaceAll("R\$", "").replaceAll(",", "."))).reduce((value, element) => value + element).toStringAsFixed(2)}",
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10), // Espaço entre os dois cards

                // Card de Despesas
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Despesas",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: double.infinity,
                          child: Card(
                            elevation: 4.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            color: const Color.fromARGB(200, 244, 67, 54),
                            child: Padding(
                              padding: const EdgeInsets.all(30.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    " ${Provider.of<DespesasProvider>(context).despesas.isEmpty ? 'R\$ 0,00' : Provider.of<DespesasProvider>(context).despesas.map((e) => double.parse(e["valor"]!.replaceAll("R\$", "").replaceAll(",", "."))).reduce((value, element) => value + element).toStringAsFixed(2)}",
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Cartão",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    color: Color.fromARGB(199, 255, 197, 71),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: <Widget>[
                          // Imagem na lateral
                          Image.asset(
                            'assets/inter.png', // Substitua pelo caminho correto da imagem
                            width: 150, // Ajuste a largura conforme necessário
                            height: 100, // Ajuste a altura conforme necessário
                          ),
                          const SizedBox(
                              width:
                                  100), // Espaçamento entre a imagem e o próximo widget
                          // Outros widgets ao lado da imagem
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                IconButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const CartaoScreen()));
                                  },
                                  icon: const Icon(Icons.manage_search),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
}
