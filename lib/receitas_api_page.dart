import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// modelo para validar os dados vindos da api
class ReceitaApi {
  final int id;
  final String titulo;

  ReceitaApi({required this.id, required this.titulo});

  // valida se id é inteiro e title é string antes de montar o objeto
  factory ReceitaApi.fromJson(Map<String, dynamic> json) {
    if (json['id'] is! int || json['title'] is! String) {
      throw const FormatException('erro de validação: id deve ser inteiro e title texto');
    }

    return ReceitaApi(
      id: json['id'] as int,
      titulo: json['title'] as String,
    );
  }
}

class ReceitasApiPage extends StatefulWidget {
  const ReceitasApiPage({super.key});

  @override
  State<ReceitasApiPage> createState() => _ReceitasApiPageState();
}

class _ReceitasApiPageState extends State<ReceitasApiPage> {
  bool carregando = true;
  String? mensagemErro;
  List<ReceitaApi> receitas = [];

  @override
  void initState() {
    super.initState();
    // inicia a busca assim que a tela abre
    buscarReceitas();
  }

  // função assíncrona que trava a execução no await até a api responder
  Future<void> buscarReceitas() async {
    // reseta o estado da página antes de tentar novamente
    setState(() {
      carregando = true;
      mensagemErro = null;
    });

    try {
      final url = Uri.https('jsonplaceholder.typicode.com', '/posts');
      final resposta = await http.get(url).timeout(const Duration(seconds: 10));

      // valida se a requisição teve sucesso
      if (resposta.statusCode != 200) {
        throw Exception('HTTP ${resposta.statusCode}');
      }

      // converte o texto da resposta em lista e valida cada item
      final List<dynamic> dadosJson = jsonDecode(resposta.body);
      final listaValidada = dadosJson
          .map((item) => ReceitaApi.fromJson(item as Map<String, dynamic>))
          .toList();

      setState(() {
        receitas = listaValidada;
        carregando = false;
      });
    } on TimeoutException {
      setState(() {
        mensagemErro = 'tempo limite esgotado (10s). verifique sua conexão.';
        carregando = false;
      });
    } on FormatException catch (e) {
      setState(() {
        mensagemErro = e.message;
        carregando = false;
      });
    } catch (e) {
      setState(() {
        mensagemErro = 'falha ao carregar receitas: $e';
        carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receitas da Comunidade'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // botão para recarregar a requisição manualmente
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: buscarReceitas,
            tooltip: 'Recarregar',
          ),
        ],
      ),
      body: _construirCorpo(),
    );
  }

  Widget _construirCorpo() {
    // estado 1: carregando
    if (carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    // estado 2: erro com opção de recarregar a página
    if (mensagemErro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                mensagemErro!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: buscarReceitas,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    // estado 3: sucesso - itera sobre os itens validados
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: receitas.length,
      itemBuilder: (context, index) {
        final receita = receitas[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange.shade100,
              child: Text(
                '${receita.id}',
                style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              receita.titulo,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('receita validada via api'),
          ),
        );
      },
    );
  }
}