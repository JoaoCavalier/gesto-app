import 'package:flutter/material.dart';
import 'package:projeto_flutter/_common/my_colors.dart';
import 'package:projeto_flutter/services/authentication.service.dart';
import 'package:projeto_flutter/telas/cartao.dart';
import 'package:projeto_flutter/telas/despesas.dart';
import 'package:projeto_flutter/telas/grafico.dart';
import 'package:projeto_flutter/telas/home.dart';
import 'package:projeto_flutter/telas/receitas.dart';
import 'package:projeto_flutter/telas/usuario.dart';

class ObjetivoScreem extends StatefulWidget {
  const ObjetivoScreem({super.key});

  @override
  State<ObjetivoScreem> createState() => _ObjetivoScreemState();
}

class _ObjetivoScreemState extends State<ObjetivoScreem> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Objetivos"),
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
            ListTile(
              leading: const Icon(Icons.task_alt),
              title: const Text("Objetivos"),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ObjetivoScreem()));
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
    );
  }
}
