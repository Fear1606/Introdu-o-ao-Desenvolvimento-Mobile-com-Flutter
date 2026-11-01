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
      home: const HomePage(),
    );
  }
}

// --- TELA INICIAL ---
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chef de Bolso - Receitas'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Lanches Práticos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ReceitaItem(
              titulo: 'Vitamina Reforçada de Banana',
              tempoPreparo: '5 min',
              icone: Icons.blender,
            ),
            ReceitaItem(
              titulo: 'Suco de Uva Integral Rápido',
              tempoPreparo: '2 min',
              icone: Icons.local_drink,
            ),
            ReceitaItem(
              titulo: 'Tapioca Simples',
              tempoPreparo: '10 min',
              icone: Icons.breakfast_dining,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navega para a tela de formulário quando o botão é clicado
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormularioReceitaPage()),
          );
        },
        tooltip: 'Cadastrar Receita',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Widget da lista (mantido igual)
class ReceitaItem extends StatelessWidget {
  final String titulo;
  final String tempoPreparo;
  final IconData icone;

  const ReceitaItem({
    super.key,
    required this.titulo,
    required this.tempoPreparo,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icone, size: 40, color: Colors.orange),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.timer, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    tempoPreparo,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//aula 03
// precisa ser StatefulWidget pois a tela muda (mostra/esconde erros) enquanto o usuário digita
class FormularioReceitaPage extends StatefulWidget {
  const FormularioReceitaPage({super.key});

  @override
  State<FormularioReceitaPage> createState() => _FormularioReceitaPageState();
}

class _FormularioReceitaPageState extends State<FormularioReceitaPage> {
  // controlador para capturar o texto digitado
  final nomeReceitaController = TextEditingController();
  String? mensagemErro;

  void validarNome(String valor) {

    setState(() {
      if (nomeReceitaController.text.trim().isEmpty) {
        mensagemErro = "Informe o nome da receita!";
      } else if (valor.trim().length < 3) {
        mensagemErro = "O nome deve ter ao menos 3 caracteres";
      } else {
        mensagemErro = null;
      }
    });
  }

  void salvarReceita() {
    validarNome(nomeReceitaController.text);

    // se houver erro, para a execução aqui e não salva
    if (mensagemErro != null) return;

    final texto = nomeReceitaController.text.trim();

    // Mostra a notificação (SnackBar) na tela
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Receita salva com sucesso: $texto"),
        backgroundColor: Colors.green,
      ),
    );

    nomeReceitaController.clear();

  }

  @override
  void dispose() {
    // é essencial descartar o controller para liberar memória quando a tela for fechada
    //"sair da sala e desligar tudo enquanto estiver fora"
    nomeReceitaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nova Receita"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: nomeReceitaController,
              decoration: InputDecoration(
                labelText: "Nome da Receita",
                border: const OutlineInputBorder(),

                errorText: mensagemErro,
              ),
              onChanged: validarNome,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: salvarReceita,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50), // faz o botão ocupar a largura toda
              ),
              child: const Text("Salvar Receita"),
            )
          ],
        ),
      ),
    );
  }
}