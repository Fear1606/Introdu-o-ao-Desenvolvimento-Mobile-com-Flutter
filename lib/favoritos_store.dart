import 'package:flutter/material.dart';
import 'receita_model.dart';

// fonte unica de verdade para os favoritos da sessao
class FavoritosStore extends ChangeNotifier {
  final List<Receita> _itens = [];

  List<Receita> get itens => List.unmodifiable(_itens);

  // verifica se a receita ja esta salva pelo id
  bool ehFavorito(int id) {
    return _itens.any((item) => item.id == id);
  }

  // adiciona sem duplicar ou remove se ja existir
  void alternarFavorito(Receita receita) {
    final indice = _itens.indexWhere((item) => item.id == receita.id);
    if (indice >= 0) {
      _itens.removeAt(indice);
    } else {
      _itens.add(receita);
    }
    notifyListeners();
  }
}

// instancia global usada pelas telas
final favoritosStore = FavoritosStore();