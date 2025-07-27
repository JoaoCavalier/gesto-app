import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:projeto_flutter/telas/objetivo.dart';
import 'package:projeto_flutter/services/authentication.service.dart';
import 'package:projeto_flutter/telas/cartao.dart';
import 'package:projeto_flutter/telas/grafico.dart';
import 'package:projeto_flutter/telas/home.dart';
import 'package:projeto_flutter/telas/usuario.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Tela de Movimentações
class MovimentacoesScreen extends StatefulWidget {
  const MovimentacoesScreen({super.key});

  @override
  State<MovimentacoesScreen> createState() => _MovimentacoesScreenState();
}

class _MovimentacoesScreenState extends State<MovimentacoesScreen> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isExpanded = false;
  bool _isTypeExpanded = false; // Controla a expansão do painel de tipo
  String _selectedCategory = 'Categorias';
  String _selectedType = 'Receita'; // 'Receita' ou 'Despesa'

  final List<String> _receitasCategories = [
    'Salário',
    'Investimento',
    'Presente'
  ];
  final List<String> _despesasCategories = ['Casa', 'Educação', 'Lazer'];

  // Formata o valor monetário
  String formatCurrency(String value) {
    final formatCurrency =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    value = value.replaceAll("R\$", "").replaceAll(",", ".");
    double parsedValue = double.parse(value);
    String formattedValue = formatCurrency.format(parsedValue);
    return formattedValue;
  }

  // Controla a expansão do painel de categorias
  void _handleExpansion(bool isExpanded) {
    setState(() {
      _isExpanded = isExpanded;
    });
  }

  // Controla a expansão do painel de tipo
  void _handleTypeExpansion(bool isExpanded) {
    setState(() {
      _isTypeExpanded = isExpanded;
    });
  }

  // Adiciona uma nova movimentação
  void _addValue() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        String currentDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

        Provider.of<MovimentacoesProvider>(context, listen: false)
            .addMovimentacao({
          'tipo': _selectedType,
          'nome': _nomeController.text,
          'valor': _valorController.text,
          'categoria': _categoriaController.text,
          'data': currentDate,
        });
        _nomeController.clear();
        _valorController.clear();
        _categoriaController.clear();
        _selectedCategory = 'Categorias';
      });
    }
  }

  // Remove uma movimentação
  void _removeValue(int index) {
    Provider.of<MovimentacoesProvider>(context, listen: false)
        .removeMovimentacao(index);
  }

  // Navega para outra tela com um indicador de carregamento
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

  @override
  Widget build(BuildContext context) {
    String? userName =
        Provider.of<SharedPreferences>(context).getString('userName');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Movimentações",
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
      // Drawer com o menu de navegação
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
                    // Seletor de Tipo (Receita ou Despesa)
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _isTypeExpanded
                              ? Colors.black
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: ExpansionPanelList(
                        elevation: 0,
                        expansionCallback: (int index, bool isExpanded) {
                          _handleTypeExpansion(isExpanded);
                        },
                        children: [
                          ExpansionPanel(
                            headerBuilder:
                                (BuildContext context, bool isExpanded) {
                              return ListTile(
                                title: Text(
                                  _selectedType,
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              );
                            },
                            body: Column(
                              children: ['Receita', 'Despesa']
                                  .map((type) => ListTile(
                                        title: Text(type),
                                        onTap: () {
                                          setState(() {
                                            _selectedType = type;
                                            _selectedCategory = 'Categorias';
                                            _categoriaController.clear();
                                            _handleTypeExpansion(false);
                                          });
                                        },
                                      ))
                                  .toList(),
                            ),
                            isExpanded: _isTypeExpanded,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
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
                      controller: _nomeController,
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
                      controller: _valorController,
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
                                        children: _selectedType == 'Receita'
                                            ? _receitasCategories
                                                .map((category) =>
                                                    _buildCategoryItem(
                                                        category))
                                                .toList()
                                            : _despesasCategories
                                                .map((category) =>
                                                    _buildCategoryItem(
                                                        category))
                                                .toList(),
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
                        backgroundColor: _selectedType == 'Receita'
                            ? Colors.green
                            : Colors.red,
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
                    // Lista de Movimentações
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: List.generate(
                        Provider.of<MovimentacoesProvider>(context)
                            .movimentacoes
                            .length,
                        (index) {
                          final movimentacao =
                              Provider.of<MovimentacoesProvider>(context)
                                  .movimentacoes[index];
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
                                          movimentacao["nome"]!,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          movimentacao["valor"]!,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: movimentacao["tipo"] ==
                                                    'Receita'
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          movimentacao["data"]!,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          movimentacao["categoria"]!,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: movimentacao["tipo"] ==
                                                    'Receita'
                                                ? Colors.green
                                                : Colors.red,
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

  // Constrói um item de categoria
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
            _categoriaController.text = categoryName;
            _selectedCategory = categoryName;
            _handleExpansion(false); // Fecha o painel após a seleção
          });
        },
      ),
    );
  }
}

class MovimentacoesProvider with ChangeNotifier {
  final List<Map<String, String>> _movimentacoes = [];
  final List<Map<String, dynamic>> _transacoesCartao = [];

  List<Map<String, String>> get movimentacoes => _movimentacoes;
  List<Map<String, dynamic>> get transacoesCartao => _transacoesCartao;

  // Chaves para salvar no SharedPreferences
  static const String _movimentacoesKey = 'movimentacoes';
  static const String _transacoesCartaoKey = 'transacoesCartao';

  MovimentacoesProvider() {
    _loadMovimentacoes();
    _loadTransacoesCartao();
  }

  // Carrega as movimentações salvas
  Future<void> _loadMovimentacoes() async {
    final prefs = await SharedPreferences.getInstance();
    final movimentacoesJson = prefs.getStringList(_movimentacoesKey);
    if (movimentacoesJson != null) {
      _movimentacoes.addAll(
        movimentacoesJson
            .map((json) => Map<String, String>.from(jsonDecode(json)))
            .toList(),
      );
      notifyListeners();
    }
  }

  // Carrega as transações do cartão salvas
  Future<void> _loadTransacoesCartao() async {
    final prefs = await SharedPreferences.getInstance();
    final transacoesJson = prefs.getStringList(_transacoesCartaoKey);
    if (transacoesJson != null) {
      _transacoesCartao.addAll(
        transacoesJson
            .map((json) => Map<String, dynamic>.from(jsonDecode(json)))
            .toList(),
      );
      notifyListeners();
    }
  }

  // Salva as movimentações no SharedPreferences
  Future<void> _saveMovimentacoes() async {
    final prefs = await SharedPreferences.getInstance();
    final movimentacoesJson =
        _movimentacoes.map((mov) => jsonEncode(mov)).toList();
    await prefs.setStringList(_movimentacoesKey, movimentacoesJson);
  }

  // Salva as transações do cartão no SharedPreferences
  Future<void> _saveTransacoesCartao() async {
    final prefs = await SharedPreferences.getInstance();
    final transacoesJson =
        _transacoesCartao.map((trans) => jsonEncode(trans)).toList();
    await prefs.setStringList(_transacoesCartaoKey, transacoesJson);
  }

  // Adiciona uma movimentação e salva no SharedPreferences
  void addMovimentacao(Map<String, String> movimentacao) {
    _movimentacoes.add(movimentacao);
    _saveMovimentacoes();
    notifyListeners();
  }

  // Remove uma movimentação e salva no SharedPreferences
  void removeMovimentacao(int index) {
    _movimentacoes.removeAt(index);
    _saveMovimentacoes();
    notifyListeners();
  }

  // Adiciona uma transação do cartão e salva no SharedPreferences
  void addTransacaoCartao(Map<String, dynamic> transacao) {
    _transacoesCartao.add(transacao);
    _saveTransacoesCartao();
    notifyListeners();
  }

  // Remove uma transação do cartão e salva no SharedPreferences
  void removeTransacaoCartao(int index) {
    _transacoesCartao.removeAt(index);
    _saveTransacoesCartao();
    notifyListeners();
  }

  // Método para limpar todas as movimentações e transações do cartão
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_movimentacoesKey); // Remove as movimentações salvas
    await prefs
        .remove(_transacoesCartaoKey); // Remove as transações do cartão salvas
    _movimentacoes.clear(); // Limpa a lista de movimentações em memória
    _transacoesCartao
        .clear(); // Limpa a lista de transações do cartão em memória
    notifyListeners(); // Notifica os ouvintes para atualizar a UI
  }
}