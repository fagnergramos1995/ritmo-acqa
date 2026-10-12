import '../util/datas.dart';

/// Uma tarefa do dia. Toda tarefa nasce como não concluída.
class Tarefa {
  final String id;
  final String titulo;

  /// Dia da tarefa no formato "aaaa-mm-dd" (ver [chaveData]).
  final String dia;
  final bool concluida;
  final DateTime criadaEm;

  const Tarefa({
    required this.id,
    required this.titulo,
    required this.dia,
    required this.criadaEm,
    this.concluida = false,
  });

  Tarefa copyWith({String? titulo, bool? concluida}) => Tarefa(
        id: id,
        titulo: titulo ?? this.titulo,
        dia: dia,
        criadaEm: criadaEm,
        concluida: concluida ?? this.concluida,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'dia': dia,
        'concluida': concluida,
        'criadaEm': criadaEm.toIso8601String(),
      };

  factory Tarefa.fromJson(Map<String, dynamic> json) => Tarefa(
        id: json['id'] as String,
        titulo: json['titulo'] as String,
        dia: json['dia'] as String,
        concluida: json['concluida'] as bool? ?? false,
        criadaEm: DateTime.parse(json['criadaEm'] as String),
      );
}

/// Regra pedida no enunciado: primeiro as pendentes, depois as concluídas,
/// e dentro de cada grupo em ordem alfabética (ignorando maiúsculas e acentos).
List<Tarefa> ordenarTarefas(Iterable<Tarefa> tarefas) {
  final lista = tarefas.toList();
  lista.sort((a, b) {
    if (a.concluida != b.concluida) {
      return a.concluida ? 1 : -1;
    }
    final porNome = normalizar(a.titulo).compareTo(normalizar(b.titulo));
    if (porNome != 0) return porNome;
    return a.criadaEm.compareTo(b.criadaEm);
  });
  return lista;
}

/// Contagem de tarefas de um dia, usada nos pontinhos do calendário.
class ResumoDia {
  final int pendentes;
  final int concluidas;

  const ResumoDia({this.pendentes = 0, this.concluidas = 0});

  int get total => pendentes + concluidas;
  double get progresso => total == 0 ? 0 : concluidas / total;
}
