# Chef de Bolso - Aplicativo de Receitas

Aplicativo mobile desenvolvido em Flutter para descoberta, pesquisa, visualização de detalhes e gerenciamento de receitas favoritas utilizando a API pública **DummyJSON Recipes**.

## Funcionalidades Implementadas

- **Listagem Inicial (RF01 e RF02):** Carregamento automático das receitas na abertura do aplicativo, exibindo imagem com alternativa visual em caso de falha, nome, tempo total de preparo e avaliação.
- **Pesquisa Remota (RF03):** Busca por nome diretamente no endpoint `/recipes/search?q=`, com remoção de espaços externos (`.trim()`), recusa de consultas vazias e botão explícito para limpar o filtro e voltar à listagem.
- **Detalhes da Receita (RF04):** Exibição completa com rolagem contendo imagem, tempos de preparo e cozimento, porções, avaliação, tipos de refeição, lista de ingredientes e modo de preparo numerado.
- **Favoritos em Sessão (RF05):** Adição e remoção de receitas sem duplicatas (validação pelo `id`), utilizando estado compartilhado em memória (`FavoritosStore`) como fonte única de verdade entre as telas.
- **Carregamento, Erros e Estados Vazios (RF06, RF07 e RF08):** Feedback visual de carregamento com bloqueio contra cliques concorrentes, tratamento de tempo limite, status HTTP e JSON inválido com opção de nova tentativa, além de distinção entre busca sem resultados, falha de rede e favoritos vazios.
- **Navegação Previsível (RF09):** Fluxo entre listagem, detalhes e favoritos preservando o contexto da pesquisa ao retornar.

## Decisão de Integração da API

Para a tela de detalhes, optou-se por **reaproveitar o objeto `Receita` completo** já recebido e validado na listagem ou pesquisa (`/recipes` e `/recipes/search`), pois a API DummyJSON já retorna todos os campos necessários (`ingredients`, `instructions`, `prepTimeMinutes`, `cookTimeMinutes`, `servings`, `rating` e `mealType`) na resposta principal, evitando requisições HTTP redundantes.

## Tecnologias, SDK e Dependências

- **SDK:** Flutter 3.50.0 / Dart
- **Dependências:** `http: ^1.6.0`
- **API Externa:** [DummyJSON Recipes](https://dummyjson.com/docs/recipes)

## Como Executar o Projeto

1. Instale as dependências:
   ```bash
   flutter pub get
   ```
2. Execute o aplicativo no navegador:
   ```bash
   flutter run -d chrome
   ```