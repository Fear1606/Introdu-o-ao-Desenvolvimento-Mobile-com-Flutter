import 'package:flutter/material.dart';
import 'favoritos_store.dart';
import 'receita_detalhes_page.dart';

class FavoritosPage extends StatelessWidget {
  const FavoritosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receitas Favoritas'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListenableBuilder(
        listenable: favoritosStore,
        builder: (context, _) {
          final lista = favoritosStore.itens;

          // distingue favoritos vazios de erro de rede
          if (lista.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border, size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'voce ainda nao favoritou nenhuma receita',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lista.length,
            itemBuilder: (context, index) {
              final receita = lista[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.restaurant, color: Colors.orange),
                  title: Text(
                    receita.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(receita.tempoTotalTexto),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'Remover',
                    onPressed: () => favoritosStore.alternarFavorito(receita),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReceitaDetalhesPage(receita: receita),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}