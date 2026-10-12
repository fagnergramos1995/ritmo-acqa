import 'package:flutter_test/flutter_test.dart';
import 'package:ritmo/modelos/tarefa.dart';
import 'package:ritmo/util/datas.dart';

Tarefa _t(String titulo, {bool feita = false}) => Tarefa(
      id: titulo,
      titulo: titulo,
      dia: '2026-10-12',
      criadaEm: DateTime(2026, 10, 12),
      concluida: feita,
    );

void main() {
  test('pendentes primeiro, depois concluídas, ambas em ordem alfabética', () {
    final ordenadas = ordenarTarefas([
      _t('Mercado', feita: true),
      _t('estudar'),
      _t('Água das plantas', feita: true),
      _t('Banco'),
      _t('Academia'),
    ]);

    expect(
      ordenadas.map((t) => t.titulo).toList(),
      ['Academia', 'Banco', 'estudar', 'Água das plantas', 'Mercado'],
    );
  });

  test('tarefa nova nasce como não concluída', () {
    expect(_t('Qualquer').concluida, isFalse);
  });

  test('tarefa sobrevive à conversão para JSON e de volta', () {
    final original = _t('Ler', feita: true);
    final copia = Tarefa.fromJson(original.toJson());
    expect(copia.titulo, 'Ler');
    expect(copia.concluida, isTrue);
    expect(copia.dia, original.dia);
  });

  test('datas em português', () {
    expect(chaveData(DateTime(2026, 1, 5)), '2026-01-05');
    expect(dataPorExtenso(DateTime(2026, 10, 12)), 'Segunda-feira, 12 de outubro');
  });
}
