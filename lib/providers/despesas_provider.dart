import 'package:flutter/material.dart';

class DespesasProvider with ChangeNotifier {
  List<Map<String, String>> _despesas = [];

  List<Map<String, String>> get despesas => _despesas;

  void addDespesa(Map<String, String> despesa) {
    _despesas.add(despesa);
    notifyListeners();
  }

  void removeDespesa(int index) {
    _despesas.removeAt(index);
    notifyListeners();
  }
}