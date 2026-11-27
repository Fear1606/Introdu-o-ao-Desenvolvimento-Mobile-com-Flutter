import 'package:flutter/material.dart';
import 'receita_model.dart';
import 'favoritos_store.dart';

// reaproveita o objeto completo da listagem para evitar requisicao extra
class ReceitaDetalhesPage extends StatelessWidget {
  final Receita receita;

  const ReceitaDetalhesPage({super.key, required this.receita});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(receita.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // atualiza o icone de favorito em tempo real
          ListenableBuilder(
            listenable: favoritosStore,
            builder: (context, _) {
              final salvo = favoritosStore.ehFavorito(receita.id);
              return IconButton(
                icon: Icon(
                  salvo ? Icons.favorite : Icons.favorite_border,
                  color: salvo ? Colors.red : null,
                ),
                tooltip: salvo ? 'Remover favorito' : 'Favoritar',
                onPressed: () => favoritosStore.alternarFavorito(receita),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // imagem com alternativa visual se falhar ou vier nula
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: (receita.image != null && receita.image!.isNotEmpty)
                  ? Image.network(
                receita.image!,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _imagemAlternativa(),
              )
                  : _imagemAlternativa(),
            ),
            const SizedBox(height: 16),

            // titulo completo da receita
            Text(
              receita.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // informacoes extras disponiveis
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: const Icon(Icons.timer, size: 18),
                  label: Text('Total: ${receita.tempoTotalTexto}'),
                ),
                if (receita.prepTimeMinutes != null)
                  Chip(label: Text('Preparo: ${receita.prepTimeMinutes} min')),
                if (receita.cookTimeMinutes != null)
                  Chip(label: Text('Cozimento: ${receita.cookTimeMinutes} min')),
                if (receita.servings != null)
                  Chip(
                    avatar: const Icon(Icons.people, size: 18),
                    label: Text('${receita.servings} porcoes'),
                  ),
                if (receita.rating != null)
                  Chip(
                    avatar: const Icon(Icons.star, size: 18, color: Colors.amber),
                    label: Text(receita.rating!.toStringAsFixed(1)),
                  ),
                ...receita.mealType.map((tipo) => Chip(label: Text(tipo))),
              ],
            ),
            const SizedBox(height: 24),

            // secao de ingredientes
            const Text(
              'Ingredientes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (receita.ingredients.isEmpty)
              const Text('nenhum ingrediente informado')
            else
              ...receita.ingredients.map(
                    (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(child: Text(item)),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // secao de modo de preparo em ordem
            const Text(
              'Modo de Preparo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (receita.instructions.isEmpty)
              const Text('nenhuma instrucao informada')
            else
              ...receita.instructions.asMap().entries.map(
                    (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.orange.shade100,
                        child: Text(
                          '${entry.key + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(entry.value)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _imagemAlternativa() {
    return Container(
      height: 220,
      width: double.infinity,
      color: Colors.orange.shade50,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, size: 48, color: Colors.orange),
          SizedBox(height: 8),
          Text('imagem indisponivel'),
        ],
      ),
    );
  }
}