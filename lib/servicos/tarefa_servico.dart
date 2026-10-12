import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../modelos/tarefa.dart';
import '../util/datas.dart';

/// Guarda as tarefas de cada usuário no aparelho (shared_preferences).
class TarefaServico {
  final String email;

  TarefaServico(this.email);

  String get _chave => 'ritmo_tarefas_$email';

  Future<List<Tarefa>> _todas() async {
    final prefs = await SharedPreferences.getInstance();
    final bruto = prefs.getString(_chave);
    if (bruto == null) return [];
    final lista = jsonDecode(bruto) as List<dynamic>;
    return lista
        .map((item) => Tarefa.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> _salvar(List<Tarefa> tarefas) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _chave,
      jsonEncode(tarefas.map((t) => t.toJson()).toList()),
    );
  }

  /// Tarefas de um dia, já ordenadas (pendentes primeiro, depois concluídas).
  Future<List<Tarefa>> doDia(DateTime dia) async {
    final chave = chaveData(dia);
    final todas = await _todas();
    return ordenarTarefas(todas.where((t) => t.dia == chave));
  }

  /// Quantidade de pendentes e concluídas por dia, para o calendário.
  Future<Map<String, ResumoDia>> resumoPorDia() async {
    final resumo = <String, ResumoDia>{};
    for (final t in await _todas()) {
      final atual = resumo[t.dia] ?? const ResumoDia();
      resumo[t.dia] = ResumoDia(
        pendentes: atual.pendentes + (t.concluida ? 0 : 1),
        concluidas: atual.concluidas + (t.concluida ? 1 : 0),
      );
    }
    return resumo;
  }

  /// Adiciona uma tarefa ao dia, sempre como NÃO concluída.
  Future<Tarefa> adicionar(DateTime dia, String titulo) async {
    final agora = DateTime.now();
    final nova = Tarefa(
      id: '${agora.microsecondsSinceEpoch}',
      titulo: titulo.trim(),
      dia: chaveData(dia),
      criadaEm: agora,
    );
    final todas = await _todas();
    todas.add(nova);
    await _salvar(todas);
    return nova;
  }

  Future<void> remover(String id) async {
    final todas = await _todas();
    todas.removeWhere((t) => t.id == id);
    await _salvar(todas);
  }

  /// Devolve uma tarefa removida (botão "Desfazer").
  Future<void> restaurar(Tarefa tarefa) async {
    final todas = await _todas();
    if (todas.every((t) => t.id != tarefa.id)) {
      todas.add(tarefa);
      await _salvar(todas);
    }
  }

  /// Marca como concluída ou volta para pendente.
  Future<void> alternarConclusao(String id) async {
    final todas = await _todas();
    final atualizadas = todas
        .map((t) => t.id == id ? t.copyWith(concluida: !t.concluida) : t)
        .toList();
    await _salvar(atualizadas);
  }
}
