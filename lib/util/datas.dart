const List<String> nomesMeses = [
  'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
  'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
];

const List<String> iniciaisSemana = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];

const List<String> nomesDiasSemana = [
  'Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira',
  'Sexta-feira', 'Sábado', 'Domingo',
];

String _doisDigitos(int n) => n.toString().padLeft(2, '0');

String chaveData(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${_doisDigitos(d.month)}-${_doisDigitos(d.day)}';

DateTime somenteData(DateTime d) => DateTime(d.year, d.month, d.day);

bool mesmoDia(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String dataPorExtenso(DateTime d) =>
    '${nomesDiasSemana[d.weekday - 1]}, ${d.day} de ${nomesMeses[d.month - 1].toLowerCase()}';

const Map<String, String> _semAcento = {
  'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a',
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
  'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
  'ó': 'o', 'ò': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
  'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
  'ç': 'c', 'ñ': 'n',
};

String normalizar(String texto) {
  final buffer = StringBuffer();
  for (final letra in texto.trim().toLowerCase().split('')) {
    buffer.write(_semAcento[letra] ?? letra);
  }
  return buffer.toString();
}