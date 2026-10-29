import 'package:flutter/material.dart';

void main() {
  runApp(const GerenciadorColecaoApp());
}

class GerenciadorColecaoApp extends StatelessWidget {
  const GerenciadorColecaoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciador de Coleção',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

// Criação da Página Principal solicitada na atividade
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Biblioteca Nerd'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      // Definindo o layout da página com os textos escritos
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          Text(
            'Lidos Recentemente',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          ItemCard(
            titulo: 'Projeto Léo e Atena',
            autor: 'Roteiro Original',
            tipo: 'HQ Independente',
          ),
          ItemCard(
            titulo: 'Homem-Aranha: A Última Caçada de Kraven',
            autor: 'J.M. DeMatteis',
            tipo: 'HQ',
          ),
          ItemCard(
            titulo: 'Lanterna Verde: Renascimento',
            autor: 'Geoff Johns',
            tipo: 'HQ',
          ),
          ItemCard(
            titulo: 'O Pistoleiro (A Torre Negra)',
            autor: 'Stephen King',
            tipo: 'Livro',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Apenas visual por enquanto (placeholder para a tela de cadastro)
        },
        tooltip: 'Cadastrar nova obra',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Widget extraído para manter o código limpo e organizado
class ItemCard extends StatelessWidget {
  final String titulo;
  final String autor;
  final String tipo;

  const ItemCard({
    super.key,
    required this.titulo,
    required this.autor,
    required this.tipo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.menu_book, size: 36, color: Colors.deepPurple),
        title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(autor),
        trailing: Chip(
          label: Text(
            tipo,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }
}