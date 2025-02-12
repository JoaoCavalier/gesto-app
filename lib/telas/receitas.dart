import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:projeto_flutter/providers/receitas_provider.dart';
import 'package:projeto_flutter/telas/objetivo.dart';
import 'package:provider/provider.dart';
import 'package:projeto_flutter/services/authentication.service.dart';
import 'package:projeto_flutter/telas/cartao.dart';
import 'package:projeto_flutter/telas/despesas.dart';
import 'package:projeto_flutter/telas/grafico.dart';
import 'package:projeto_flutter/telas/home.dart';
import 'package:projeto_flutter/telas/usuario.dart';

class ReceitasScreen extends StatefulWidget {
  const ReceitasScreen({super.key});

  @override
  State<ReceitasScreen> createState() => _ReceitasScreenState();
}

class _ReceitasScreenState extends State<ReceitasScreen> {
  final TextEditingController _receitasNomeController = TextEditingController();
  final TextEditingController _receitasValorController =
      TextEditingController();
  final TextEditingController _receitasCategoriaController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isExpanded = false;
  String _selectedCategory = 'Categorias';

  String formatCurrency(String value) {
    final formatCurrency =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    value = value.replaceAll("R\$", "").replaceAll(",", ".");
    double parsedValue = double.parse(value);
    String formattedValue = formatCurrency.format(parsedValue);
    return formattedValue;
  }

  void _handleExpansion(bool isExpanded) {
    setState(() {
      _isExpanded = isExpanded;
    });
  }

  void _addValue() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        String currentDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

        Provider.of<ReceitasProvider>(context, listen: false).addReceita({
          'nome': _receitasNomeController.text,
          'valor': _receitasValorController.text,
          'categoria': _receitasCategoriaController.text,
          'data': currentDate, // Adiciona a data
        });
        _receitasNomeController.clear();
        _receitasValorController.clear();
        _receitasCategoriaController.clear();
        _selectedCategory = 'Categorias';
      });
    }
  }

  void _removeValue(int index) {
    Provider.of<ReceitasProvider>(context, listen: false).removeReceita(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Receitas",
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
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.green),
              title: const Text("Usuário"),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => UsuarioScreen()));
              },
            ),
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.green),
              title: const Text("Home"),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => HomeScreen()));
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
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => CartaoScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_graph, color: Colors.green),
              title: const Text("Gráficos"),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => GraficoScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.task_alt, color: Colors.green),
              title: const Text("Objetivos"),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ObjetivoScreem()));
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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    // Campo de Nome
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Nome',
                        labelStyle: TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.black, width: 1),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                      controller: _receitasNomeController,
                      keyboardType: TextInputType.text,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira um nome.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Campo de Valor
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Valor',
                        labelStyle: TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.black, width: 1),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                      controller: _receitasValorController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          if (newValue.text.isEmpty) {
                            return newValue.copyWith(text: '');
                          }
                          final number =
                              int.tryParse(newValue.text.replaceAll('.', ''));
                          if (number == null) {
                            return oldValue;
                          }
                          final formattedNumber = NumberFormat.currency(
                                  locale: 'pt_BR', symbol: 'R\$')
                              .format(number / 100);
                          return newValue.copyWith(
                            text: formattedNumber,
                            selection: TextSelection.collapsed(
                                offset: formattedNumber.length),
                          );
                        }),
                      ],
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira um valor.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Campo de Categorias
                    SizedBox(
                      child: FormField<String>(
                        validator: (String? value) {
                          if (_selectedCategory == 'Categorias') {
                            return 'Por favor, selecione uma categoria.';
                          }
                          return null;
                        },
                        builder: (FormFieldState<String> state) {
                          return Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: _isExpanded
                                        ? Colors.black
                                        : Colors.transparent,
                                    width: 1,
                                  ),
                                ),
                                child: ExpansionPanelList(
                                  elevation: 0,
                                  expansionCallback:
                                      (int index, bool isExpanded) {
                                    _handleExpansion(isExpanded);
                                  },
                                  children: [
                                    ExpansionPanel(
                                      headerBuilder: (BuildContext context,
                                          bool isExpanded) {
                                        return ListTile(
                                          title: Text(
                                            _selectedCategory,
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                        );
                                      },
                                      body: Column(
                                        children: <Widget>[
                                          _buildCategoryItem("Investimento"),
                                          _buildCategoryItem("Salário"),
                                          _buildCategoryItem("Presente"),
                                          _buildCategoryItem("Prêmio"),
                                        ],
                                      ),
                                      isExpanded: _isExpanded,
                                    ),
                                  ],
                                ),
                              ),
                              if (state.hasError)
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Text(
                                    state.errorText!,
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.error,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Botão de Adicionar
                    ElevatedButton(
                      onPressed: _addValue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: Size(150, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Adicionar à Lista',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Lista de Receitas
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: List.generate(
                        Provider.of<ReceitasProvider>(context).receitas.length,
                        (index) {
                          return Card(
                            elevation: 2.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          Provider.of<ReceitasProvider>(context)
                                              .receitas[index]["nome"]!,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          Provider.of<ReceitasProvider>(context)
                                              .receitas[index]["valor"]!,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          Provider.of<ReceitasProvider>(context)
                                              .receitas[index]["data"]!,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          Provider.of<ReceitasProvider>(context)
                                              .receitas[index]["categoria"]!,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () {
                                      _removeValue(index);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String categoryName) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: const Border(
          top: BorderSide(width: 1.0, color: Colors.black),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        title: Text(categoryName),
        onTap: () {
          setState(() {
            _receitasCategoriaController.text = categoryName;
            _selectedCategory = categoryName;
            _handleExpansion(false); // Fecha o painel após a seleção
          });
        },
      ),
    );
  }
}
