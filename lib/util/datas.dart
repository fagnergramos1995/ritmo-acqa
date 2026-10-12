// Funções de apoio para datas em português e comparação de textos.

const List<String> nomesMeses = [
  'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
  'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
];

/// Iniciais dos dias da semana, começando no domingo.
const List<String> iniciaisSemana = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];

/// Nomes dos dias na ordem de DateTime.weekday (1 = segunda ... 7 = domingo).
const List<String> nomesDiasSemana = [
  'Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira',
  'Sexta-feira', 'Sábado', 'Domingo',
];

String _doisDigitos(int n) => n.toString().padLeft(2, '0');

/// Chave usada para guardar as tarefas de cada dia: "2026-10-12".
String chaveData(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${_doisDigitos(d.month)}-${_doisDigitos(d.day)}';

/// Remove o horário, mantendo apenas o dia.
DateTime somenteData(DateTime d) => DateTime(d.year, d.month, d.day);

bool mesmoDia(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Ex.: "Segunda-feira, 12 de outubro".
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

/// Deixa o texto em minúsculas e sem acentos, para que a ordem
/// alfabética trate "Água" e "agenda" corretamente.
String normalizar(String texto) {
  final buffer = StringBuffer();
  for (final letra in texto.trim().toLowerCase().split('')) {
    buffer.write(_semAcento[letra] ?? letra);
  }
  return buffer.toString();
}
