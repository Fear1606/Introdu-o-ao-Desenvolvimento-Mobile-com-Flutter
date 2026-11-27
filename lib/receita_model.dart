// modelo da receita validando os campos da api
class Receita {
  final int id;
  final String name;
  final List<String> ingredients;
  final List<String> instructions;
  final String? image;
  final int? prepTimeMinutes;
  final int? cookTimeMinutes;
  final int? servings;
  final num? rating;
  final List<String> mealType;

  Receita({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.instructions,
    this.image,
    this.prepTimeMinutes,
    this.cookTimeMinutes,
    this.servings,
    this.rating,
    required this.mealType,
  });

  factory Receita.fromJson(Map<String, dynamic> json) {
    // valida se o id veio como inteiro
    if (json['id'] is! int) {
      throw const FormatException('id da receita invalido');
    }

    // trata nome ausente ou vazio
    final nomeBruto = json['name'];
    final nomeValidado = (nomeBruto is String && nomeBruto.trim().isNotEmpty)
        ? nomeBruto.trim()
        : 'Receita sem nome';

    // extrai listas garantindo que sao strings
    final ingredientesValidados = (json['ingredients'] is List)
        ? (json['ingredients'] as List).whereType<String>().toList()
        : <String>[];

    final instrucoesValidadas = (json['instructions'] is List)
        ? (json['instructions'] as List).whereType<String>().toList()
        : <String>[];

    // trata mealType como lista mesmo se vier string unica
    List<String> tiposRefeicao = [];
    if (json['mealType'] is List) {
      tiposRefeicao = (json['mealType'] as List).whereType<String>().toList();
    } else if (json['mealType'] is String) {
      tiposRefeicao = [json['mealType'] as String];
    }

    return Receita(
      id: json['id'] as int,
      name: nomeValidado,
      ingredients: ingredientesValidados,
      instructions: instrucoesValidadas,
      image: json['image'] is String ? json['image'] as String : null,
      prepTimeMinutes: json['prepTimeMinutes'] is num
          ? (json['prepTimeMinutes'] as num).toInt()
          : null,
      cookTimeMinutes: json['cookTimeMinutes'] is num
          ? (json['cookTimeMinutes'] as num).toInt()
          : null,
      servings: (json['servings'] is num && (json['servings'] as num) > 0)
          ? (json['servings'] as num).toInt()
          : null,
      rating: json['rating'] is num ? json['rating'] as num : null,
      mealType: tiposRefeicao,
    );
  }

  // soma os tempos apenas se algum existir
  String get tempoTotalTexto {
    if (prepTimeMinutes == null && cookTimeMinutes == null) {
      return 'tempo nao informado';
    }
    final total = (prepTimeMinutes ?? 0) + (cookTimeMinutes ?? 0);
    return '$total min';
  }
}