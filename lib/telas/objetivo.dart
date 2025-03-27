import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:provider/provider.dart';

class Objetivo {
  String nome;
  double meta;
  double valorAtual;
  bool prioridade;

  Objetivo({
    required this.nome,
    required this.meta,
    this.valorAtual = 0.0,
    this.prioridade = false,
  });

  String toJson() {
    return jsonEncode({
      'nome': nome,
      'meta': meta,
      'valorAtual': valorAtual,
      'prioridade': prioridade,
    });
  }

  factory Objetivo.fromJson(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return Objetivo(
      nome: json['nome'],
      meta: json['meta'].toDouble(),
      valorAtual: json['valorAtual'].toDouble(),
      prioridade: json['prioridade'],
    );
  }
}

class ObjetivoProvider with ChangeNotifier {
  List<Objetivo> _objetivos = [];
  List<Objetivo> _metasBatidas = [];

  List<Objetivo> get objetivos => _objetivos;
  List<Objetivo> get metasBatidas => _metasBatidas;
  List<Objetivo> get objetivosAtivos =>
      _objetivos.where((o) => o.valorAtual < o.meta).toList();

  Future<void> carregarObjetivos() async {
    final prefs = await SharedPreferences.getInstance();
    final objetivosJson = prefs.getStringList('objetivos') ?? [];
    final metasBatidasJson = prefs.getStringList('metas_batidas') ?? [];

    _objetivos = objetivosJson.map((json) => Objetivo.fromJson(json)).toList();
    _metasBatidas =
        metasBatidasJson.map((json) => Objetivo.fromJson(json)).toList();
    notifyListeners();
  }

  Future<void> salvarObjetivos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'objetivos',
      _objetivos.map((obj) => obj.toJson()).toList(),
    );
    await prefs.setStringList(
      'metas_batidas',
      _metasBatidas.map((obj) => obj.toJson()).toList(),
    );
  }

  void adicionarObjetivo(Objetivo objetivo) {
    _objetivos.add(objetivo);
    salvarObjetivos();
    notifyListeners();
  }

  void atualizarObjetivo(int index, Objetivo objetivo) {
    // Verifica se o objetivo foi concluído
    if (objetivo.valorAtual >= objetivo.meta) {
      _metasBatidas.add(objetivo);
      _objetivos.removeAt(index);
    } else {
      _objetivos[index] = objetivo;
    }
    salvarObjetivos();
    notifyListeners();
  }

  void removerObjetivo(int index) {
    _objetivos.removeAt(index);
    salvarObjetivos();
    notifyListeners();
  }

  void removerObjetivoConcluido(int index) {
    _metasBatidas.removeAt(index);
    salvarObjetivos();
    notifyListeners();
  }

  void concluirObjetivo(int index) {
    final objetivo = _objetivos[index];
    _metasBatidas.add(objetivo);
    _objetivos.removeAt(index);
    salvarObjetivos();
    notifyListeners();
  }
}

class ObjetivoScreen extends StatefulWidget {
  const ObjetivoScreen({super.key});

  @override
  State<ObjetivoScreen> createState() => _ObjetivoScreenState();
}

class _ObjetivoScreenState extends State<ObjetivoScreen> {
  final NumberFormat _formatoReal = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarObjetivos();
  }

  Future<void> _carregarObjetivos() async {
    await Provider.of<ObjetivoProvider>(context, listen: false)
        .carregarObjetivos();
    setState(() {
      _carregando = false;
    });
  }

  double _calcularTotalMetas() {
    return Provider.of<ObjetivoProvider>(context)
        .objetivos
        .fold(0.0, (sum, objetivo) => sum + objetivo.meta);
  }

  double _calcularTotalEconomizado() {
    return Provider.of<ObjetivoProvider>(context)
        .objetivos
        .fold(0.0, (sum, objetivo) => sum + objetivo.valorAtual);
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final objetivoProvider = Provider.of<ObjetivoProvider>(context);
    final objetivos = objetivoProvider.objetivosAtivos;
    final metasBatidas = objetivoProvider.metasBatidas;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Objetivos", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildResumoCard(),
            const SizedBox(height: 20),
            if (objetivos.isNotEmpty) _buildSecaoObjetivosAtivos(),
            if (metasBatidas.isNotEmpty) _buildSecaoMetasConcluidas(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoCriarObjetivo(context),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildResumoCard() {
    final totalMetas = _calcularTotalMetas();
    final totalEconomizado = _calcularTotalEconomizado();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(
                    "Total em Objetivos", _formatoReal.format(totalMetas)),
                _buildInfoItem(
                    "Economizado", _formatoReal.format(totalEconomizado)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSecaoObjetivosAtivos() {
    final objetivos = Provider.of<ObjetivoProvider>(context).objetivosAtivos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Objetivos Ativos",
          style: TextStyle(
              fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...objetivos.map((obj) => _buildObjetivoCard(obj, false)).toList(),
      ],
    );
  }

  Widget _buildSecaoMetasConcluidas() {
    final metasBatidas = Provider.of<ObjetivoProvider>(context).metasBatidas;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 12),
        const Text(
          "Metas Concluídas",
          style: TextStyle(
              fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...metasBatidas.map((obj) => _buildObjetivoCard(obj, true)).toList(),
      ],
    );
  }

  Widget _buildObjetivoCard(Objetivo objetivo, bool isConcluido) {
    final progresso = objetivo.valorAtual / objetivo.meta;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: objetivo.prioridade ? Colors.amber : Colors.grey.shade200,
          width: 1,
        ),
      ),
      color: isConcluido
          ? Colors.green[50]
          : objetivo.prioridade
              ? Colors.amber[50]
              : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _mostrarDetalhesObjetivo(context, objetivo, isConcluido),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      objetivo.nome,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration:
                            isConcluido ? TextDecoration.lineThrough : null,
                        color: isConcluido ? Colors.green : Colors.black87,
                      ),
                    ),
                  ),
                  if (objetivo.prioridade && !isConcluido)
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progresso,
                backgroundColor: Colors.grey[200],
                color: isConcluido ? Colors.green : Colors.greenAccent,
                minHeight: 6,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatoReal.format(objetivo.valorAtual),
                    style: TextStyle(
                      color: isConcluido ? Colors.green : Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _formatoReal.format(objetivo.meta),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDetalhesObjetivo(
      BuildContext context, Objetivo objetivo, bool isConcluido) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  objetivo.nome,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: objetivo.valorAtual / objetivo.meta,
                  backgroundColor: Colors.grey[200],
                  color: Colors.green,
                  minHeight: 8,
                ),
                const SizedBox(height: 8),
                Text(
                  "${_formatoReal.format(objetivo.valorAtual)} de ${_formatoReal.format(objetivo.meta)}",
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 24),
                if (!isConcluido) ...[
                  _buildActionButton(
                    icon: Icons.add,
                    label: "Adicionar Valor",
                    color: Colors.green,
                    onPressed: () {
                      Navigator.pop(context);
                      _mostrarDialogoAdicionarValor(
                          context,
                          Provider.of<ObjetivoProvider>(context, listen: false)
                              .objetivos
                              .indexOf(objetivo));
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.edit,
                    label: "Editar",
                    color: Colors.blue,
                    onPressed: () {
                      Navigator.pop(context);
                      _mostrarDialogoEditarObjetivo(
                          context,
                          Provider.of<ObjetivoProvider>(context, listen: false)
                              .objetivos
                              .indexOf(objetivo));
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.check_circle,
                    label: "Concluir Objetivo",
                    color: Colors.green,
                    onPressed: () {
                      Navigator.pop(context);
                      Provider.of<ObjetivoProvider>(context, listen: false)
                          .concluirObjetivo(Provider.of<ObjetivoProvider>(
                                  context,
                                  listen: false)
                              .objetivos
                              .indexOf(objetivo));
                    },
                  ),
                ],
                _buildActionButton(
                  icon: Icons.delete,
                  label: isConcluido ? "Excluir" : "Cancelar Objetivo",
                  color: Colors.red,
                  onPressed: () {
                    Navigator.pop(context);
                    final provider =
                        Provider.of<ObjetivoProvider>(context, listen: false);
                    if (isConcluido) {
                      final index = provider.metasBatidas.indexOf(objetivo);
                      provider.removerObjetivoConcluido(index);
                    } else {
                      final index = provider.objetivos.indexOf(objetivo);
                      provider.removerObjetivo(index);
                    }
                  },
                ),
                if (!isConcluido)
                  _buildActionButton(
                    icon: objetivo.prioridade ? Icons.star : Icons.star_outline,
                    label: objetivo.prioridade
                        ? "Remover Prioridade"
                        : "Tornar Prioritário",
                    color: Colors.amber,
                    onPressed: () {
                      Navigator.pop(context);
                      final index =
                          Provider.of<ObjetivoProvider>(context, listen: false)
                              .objetivos
                              .indexOf(objetivo);
                      final novoObjetivo = Objetivo(
                        nome: objetivo.nome,
                        meta: objetivo.meta,
                        valorAtual: objetivo.valorAtual,
                        prioridade: !objetivo.prioridade,
                      );
                      Provider.of<ObjetivoProvider>(context, listen: false)
                          .atualizarObjetivo(index, novoObjetivo);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label, style: TextStyle(color: color)),
        onTap: onPressed,
      ),
    );
  }

  void _mostrarDialogoCriarObjetivo(BuildContext context) {
    final TextEditingController nomeController = TextEditingController();
    final TextEditingController metaController = TextEditingController();
    bool prioridade = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Criar Novo Objetivo'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nomeController,
                    decoration:
                        const InputDecoration(labelText: 'Nome do Objetivo'),
                  ),
                  TextField(
                    controller: metaController,
                    decoration: const InputDecoration(labelText: 'Meta (R\$)'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\,?\d{0,2}')),
                    ],
                    onChanged: (value) {
                      metaController.value = metaController.value.copyWith(
                        text: value.replaceAll('.', '').replaceAll(',', '.'),
                        selection:
                            TextSelection.collapsed(offset: value.length),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Checkbox(
                        value: prioridade,
                        onChanged: (value) {
                          setState(() => prioridade = value ?? false);
                        },
                        activeColor: Colors.amber,
                      ),
                      const Text('Definir como prioridade'),
                      const Icon(Icons.star, color: Colors.amber),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    final nome = nomeController.text;
                    final meta = double.tryParse(metaController.text) ?? 0.0;
                    if (nome.isNotEmpty && meta > 0) {
                      Provider.of<ObjetivoProvider>(context, listen: false)
                          .adicionarObjetivo(
                        Objetivo(
                          nome: nome,
                          meta: meta,
                          prioridade: prioridade,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Criar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarDialogoEditarObjetivo(BuildContext context, int index) {
    final objetivo =
        Provider.of<ObjetivoProvider>(context, listen: false).objetivos[index];
    final TextEditingController nomeController =
        TextEditingController(text: objetivo.nome);
    final TextEditingController metaController = TextEditingController(
      text: _formatoReal.format(objetivo.meta),
    );
    bool prioridade = objetivo.prioridade;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Editar Objetivo'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nomeController,
                    decoration:
                        const InputDecoration(labelText: 'Nome do Objetivo'),
                  ),
                  TextField(
                    controller: metaController,
                    decoration: const InputDecoration(labelText: 'Meta (R\$)'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\,?\d{0,2}')),
                    ],
                    onChanged: (value) {
                      metaController.value = metaController.value.copyWith(
                        text: value.replaceAll('.', '').replaceAll(',', '.'),
                        selection:
                            TextSelection.collapsed(offset: value.length),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Checkbox(
                        value: prioridade,
                        onChanged: (value) {
                          setState(() => prioridade = value ?? false);
                        },
                        activeColor: Colors.amber,
                      ),
                      const Text('Definir como prioridade'),
                      const Icon(Icons.star, color: Colors.amber),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    final nome = nomeController.text;
                    final meta = double.tryParse(metaController.text) ?? 0.0;
                    if (nome.isNotEmpty && meta > 0) {
                      Provider.of<ObjetivoProvider>(context, listen: false)
                          .atualizarObjetivo(
                        index,
                        Objetivo(
                          nome: nome,
                          meta: meta,
                          valorAtual: objetivo.valorAtual,
                          prioridade: prioridade,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarDialogoAdicionarValor(BuildContext context, int index) {
    final objetivo =
        Provider.of<ObjetivoProvider>(context, listen: false).objetivos[index];
    final valorRestante = objetivo.meta - objetivo.valorAtual;
    final TextEditingController valorController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adicionar Valor'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Restante: ${_formatoReal.format(valorRestante)}',
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: valorController,
                decoration: const InputDecoration(
                  labelText: 'Valor (R\$)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\,?\d{0,2}')),
                ],
                onChanged: (value) {
                  valorController.value = valorController.value.copyWith(
                    text: value.replaceAll('.', '').replaceAll(',', '.'),
                    selection: TextSelection.collapsed(offset: value.length),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final valor = double.tryParse(valorController.text) ?? 0.0;
                if (valor <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Digite um valor válido!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else if (valor > valorRestante) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Valor máximo: ${_formatoReal.format(valorRestante)}',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  final novoObjetivo = Objetivo(
                    nome: objetivo.nome,
                    meta: objetivo.meta,
                    valorAtual: objetivo.valorAtual + valor,
                    prioridade: objetivo.prioridade,
                  );
                  Provider.of<ObjetivoProvider>(context, listen: false)
                      .atualizarObjetivo(index, novoObjetivo);
                  Navigator.pop(context);
                }
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }
}