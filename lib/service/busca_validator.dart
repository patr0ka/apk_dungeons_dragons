String? validaBusca(String? valor) {
  final texto = valor?.trim() ?? '';
  if (texto.isEmpty) return 'Digite um nome para pesquisar.';
  if (texto.length < 2) return 'Digite pelo menos 2 caracteres.';
  if (texto.length > 80) return 'Use no máximo 80 caracteres.';
  if (!RegExp(r'[a-zA-ZÀ-ÿ]').hasMatch(texto)) {
    return 'O nome deve conter letras.';
  }
  if (!RegExp(r"^[a-zA-ZÀ-ÿ0-9\s'\-]+$").hasMatch(texto)) {
    return 'Use letras, números, espaços, hífen ou apóstrofo.';
  }
  return null;
}
