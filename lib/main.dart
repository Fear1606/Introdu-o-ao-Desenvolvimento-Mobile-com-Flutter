import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'receita_model.dart';
import 'favoritos_store.dart';
import 'receita_detalhes_page.dart';
import 'favoritos_page.dart';

void main() {
  runApp(const ChefDeBolsoApp());
}

class ChefDeBolsoApp extends StatelessWidget {
  const ChefDeBolsoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chef de Bolso',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final buscaController = TextEditingController();
  List<Receita> receitas = [];
  bool carregando = false;
  String? erroRede;
  String? erroCampoBusca;
  String termoPesquisado = '';

  @override
  void initState() {
    super.initState();
    // inicia o carregamento das receitas na primeira abertura
    buscarReceitas();
  }

  // busca listagem geral ou pesquisa remota na dummyjson
  Future<void> buscarReceitas({String consulta = ''}) async {
    // evita requisicoes concorrentes se ja estiver carregando
    if (carregando) return;

    setState(() {
      carregando = true;
      erroRede = null;
      termoPesquisado = consulta;
    });

    try {
      final Uri url;
      if (consulta.isEmpty) {
        url = Uri.https('dummyjson.com', '/recipes');
      } else {
        url = Uri.https('dummyjson.com', '/recipes/search', {'q': consulta});
      }

      final resposta = await http.get(url).timeout(const Duration(seconds: 10));

      if (resposta.statusCode != 200) {
        throw Exception('HTTP ${resposta.statusCode}');
      }

      final dados = jsonDecode(resposta.body);

      // valida se o corpo veio no formato esperado
      if (dados is! Map<String, dynamic> || dados['recipes'] is! List) {
        throw const FormatException('formato de resposta invalido');
      }

      final listaBruta = dados['recipes'] as List;
      final listaValidada = listaBruta
          .map((item) => Receita.fromJson(item as Map<String, dynamic>))
          .toList();

      setState(() {
        receitas = listaValidada;
        carregando = false;
      });
    } on TimeoutException {
      setState(() {
        erroRede = 'tempo limite esgotado. tente novamente.';
        carregando = false;
      });
    } on FormatException catch (e) {
      setState(() {
        erroRede = e.message;
        carregando = false;
      });
    } catch (_) {
      setState(() {
        erroRede = 'falha de conexao ao buscar receitas.';
        carregando = false;
      });
    }
  }

  // valida o campo antes de disparar a pesquisa remota
  void executarPesquisa() {
    final texto = buscaController.text.trim();

    if (texto.isEmpty) {
      setState(() {
        erroCampoBusca = 'digite o nome de uma receita';
      });
      return;
    }

    setState(() {
      erroCampoBusca = null;
    });
    FocusScope.of(context).unfocus();
    buscarReceitas(consulta: texto);
  }

  // limpa o filtro e volta para a listagem inicial
  void limparPesquisa() {
    buscaController.clear();
    setState(() {
      erroCampoBusca = null;
    });
    FocusScope.of(context).unfocus();
    buscarReceitas();
  }

  @override
  void dispose() {
    buscaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chef de Bolso'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // acesso aos favoritos mostrando a quantidade salva
          ListenableBuilder(
            listenable: favoritosStore,
            builder: (context, _) {
              final qtd = favoritosStore.itens.length;
              return IconButton(
                icon: Badge(
                  isLabelVisible: qtd > 0,
                  label: Text('$qtd'),
                  child: const Icon(Icons.favorite),
                ),
                tooltip: 'Favoritos',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FavoritosPage()),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // area de pesquisa remota
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: buscaController,
                  enabled: !carregando,
                  decoration: InputDecoration(
                    labelText: 'Pesquisar receita por nome',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.search),
                    errorText: erroCampoBusca,
                    suffixIcon: (buscaController.text.isNotEmpty ||
                        termoPesquisado.isNotEmpty)
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: 'Limpar busca',
                      onPressed: carregando ? null : limparPesquisa,
                    )
                        : null,
                  ),
                  onSubmitted: (_) => executarPesquisa(),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: carregando ? null : executarPesquisa,
                        child: const Text('Pesquisar'),
                      ),
                    ),
                    if (termoPesquisado.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: carregando ? null : limparPesquisa,
                        child: const Text('Voltar a listagem'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // area principal de exibicao
          Expanded(child: _construirConteudo()),
        ],
      ),
    );
  }

  Widget _construirConteudo() {
    // feedback visual de carregamento
    if (carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    // estado de erro com opcao de nova tentativa
    if (erroRede != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                erroRede!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => buscarReceitas(consulta: termoPesquisado),
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    // distingue busca sem correspondencia de erro de rede
    if (receitas.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                termoPesquisado.isNotEmpty
                    ? 'nenhuma receita encontrada para "$termoPesquisado"'
                    : 'nenhuma receita disponivel no momento',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              if (termoPesquisado.isNotEmpty) ...[
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: limparPesquisa,
                  child: const Text('Mostrar todas as receitas'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    // listagem com rolagem
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: receitas.length,
      itemBuilder: (context, index) {
        final receita = receitas[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              // abre detalhes mantendo o contexto da pesquisa ao voltar
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReceitaDetalhesPage(receita: receita),
                ),
              );
            },
            child: Row(
              children: [
                // miniatura com fallback se a imagem falhar
                SizedBox(
                  width: 95,
                  height: 95,
                  child: (receita.image != null && receita.image!.isNotEmpty)
                      ? Image.network(
                    receita.image!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _miniFallback(),
                  )
                      : _miniFallback(),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          receita.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.timer, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              receita.tempoTotalTexto,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            if (receita.rating != null) ...[
                              const SizedBox(width: 12),
                              const Icon(Icons.star, size: 14, color: Colors.amber),
                              const SizedBox(width: 2),
                              Text(
                                receita.rating!.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // botao rapido de favoritar sincronizado
                ListenableBuilder(
                  listenable: favoritosStore,
                  builder: (context, _) {
                    final salvo = favoritosStore.ehFavorito(receita.id);
                    return IconButton(
                      icon: Icon(
                        salvo ? Icons.favorite : Icons.favorite_border,
                        color: salvo ? Colors.red : Colors.grey,
                      ),
                      onPressed: () => favoritosStore.alternarFavorito(receita),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _miniFallback() {
    return Container(
      color: Colors.orange.shade50,
      child: const Icon(Icons.restaurant_menu, color: Colors.orange),
    );
  }
}