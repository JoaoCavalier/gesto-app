import 'package:flutter/material.dart';

class ReceitasProvider with ChangeNotifier {
  List<Map<String, String>> _receitas = [];

  List<Map<String, String>> get receitas => _receitas;

  void addReceita(Map<String, String> receita) {
    _receitas.add(receita);
    notifyListeners();
  }

  void removeReceita(int index) {
    _receitas.removeAt(index);
    notifyListeners();
  }
}