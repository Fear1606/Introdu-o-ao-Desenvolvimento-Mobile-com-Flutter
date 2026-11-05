import 'package:flutter/material.dart';

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
      home: const TelaPesquisa(),
    );
  }
}

class TelaPesquisa extends StatefulWidget {
  const TelaPesquisa({super.key});

  @override
  State<TelaPesquisa> createState() => _TelaPesquisaState();
}

class _TelaPesquisaState extends State<TelaPesquisa> {
  final _controlePesquisa = TextEditingController();
  String? _mensagemErro;
  String? _termoValidoRecebido; // resultado provisório

  void _realizarPesquisa() {
    // trata consultas com espaços removendo os espaços em branco no início e no fim
    final textoPesquisa = _controlePesquisa.text.trim();

    setState(() {
      // recusa consulta vazia ou apenas com espaços
      if (textoPesquisa.isEmpty) {
        // mensagem de erro que indica como corrigir
        _mensagemErro = "A pesquisa não pode estar vazia. Digite o nome de uma receita.";
        _termoValidoRecebido = null;
      } else {
        // pesquisa válida
        _mensagemErro = null;
        _termoValidoRecebido = textoPesquisa;

        // esconde o teclado após a pesquisa
        FocusScope.of(context).unfocus();
      }
    });
  }

  @override
  void dispose() {
    _controlePesquisa.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chef de Bolso - Pesquisa"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // campo rotulado para pesquisar pelo nome da receita
            TextField(
              controller: _controlePesquisa,
              decoration: InputDecoration(
                labelText: "Qual receita você procura?",
                border: const OutlineInputBorder(),
                errorText: _mensagemErro,
                prefixIcon: const Icon(Icons.search),
              ),
              // permite pesquisar pressionando "Enter"
              onSubmitted: (_) => _realizarPesquisa(),
            ),

            const SizedBox(height: 16),

            // ação explícita de pesquisa
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _realizarPesquisa,
                style: FilledButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text("Pesquisar"),
              ),
            ),

            const SizedBox(height: 32),

            // mostrar o termo válido recebido (resultados provisórios)
            if (_termoValidoRecebido != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Resultados provisórios para:",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '"$_termoValidoRecebido"',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text("Aqui aparecerá a lista de receitas no futuro..."),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}