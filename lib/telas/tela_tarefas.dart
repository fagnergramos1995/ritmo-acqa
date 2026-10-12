import 'package:flutter/material.dart';

import '../componentes/botao_gradiente.dart';
import '../componentes/cartao_vidro.dart';
import '../componentes/dialogo_nova_tarefa.dart';
import '../componentes/fundo_aurora.dart';
import '../componentes/item_tarefa.dart';
import '../modelos/tarefa.dart';
import '../servicos/tarefa_servico.dart';
import '../tema/cores.dart';
import '../util/datas.dart';

/// Lista de tarefas de um dia: adicionar, remover e marcar como concluída.
class TelaTarefas extends StatefulWidget {
  final DateTime dia;
  final TarefaServico servico;

  const TelaTarefas({super.key, required this.dia, required this.servico});

  @override
  State<TelaTarefas> createState() => _TelaTarefasState();
}

class _TelaTarefasState extends State<TelaTarefas> {
  List<Tarefa> _tarefas = [];
  bool _carregando = true;
  ScaffoldMessengerState? _mensageiro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    // Ao voltar para o calendário, some o aviso de "removida".
    _mensageiro?.hideCurrentSnackBar();
    super.dispose();
  }

  Future<void> _carregar() async {
    final tarefas = await widget.servico.doDia(widget.dia);
    if (!mounted) return;
    setState(() {
      _tarefas = tarefas;
      _carregando = false;
    });
  }

  Future<void> _adicionar() async {
    final titulo = await mostrarDialogoNovaTarefa(context, widget.dia);
    if (titulo == null || titulo.trim().isEmpty) return;
    await widget.servico.adicionar(widget.dia, titulo);
    await _carregar();
  }

  Future<void> _alternar(Tarefa tarefa) async {
    // Atualiza a tela na hora e reordena; depois grava no aparelho.
    setState(() {
      _tarefas = ordenarTarefas(
        _tarefas.map((t) => t.id == tarefa.id ? t.copyWith(concluida: !t.concluida) : t),
      );
    });
    await widget.servico.alternarConclusao(tarefa.id);
  }

  Future<void> _remover(Tarefa tarefa) async {
    // Tira da lista imediatamente (exigência do Dismissible).
    setState(() => _tarefas.removeWhere((t) => t.id == tarefa.id));
    await widget.servico.remover(tarefa.id);
    if (!mounted) return;

    final mensageiro = ScaffoldMessenger.of(context);
    _mensageiro = mensageiro;
    mensageiro.hideCurrentSnackBar();
    final aviso = mensageiro.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Cores.noiteClara,
        content: Text('"${tarefa.titulo}" removida', style: const TextStyle(color: Cores.texto)),
        action: SnackBarAction(
          label: 'DESFAZER',
          textColor: Cores.lima,
          onPressed: () async {
            await widget.servico.restaurar(tarefa);
            await _carregar();
          },
        ),
      ),
    );
    // Fecha o aviso sozinho após 4 s (nas versões novas do Flutter,
    // avisos com botão de ação não somem automaticamente).
    Future.delayed(const Duration(seconds: 4), aviso.close);
  }

  @override
  Widget build(BuildContext context) {
    final pendentes = _tarefas.where((t) => !t.concluida).toList();
    final concluidas = _tarefas.where((t) => t.concluida).toList();

    return Scaffold(
      floatingActionButton: BotaoGradiente(
        rotulo: 'Nova tarefa',
        icone: Icons.add_rounded,
        expandir: false,
        onPressed: _adicionar,
      ),
      body: FundoAurora(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _cabecalho(pendentes.length, concluidas.length),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _carregando
                    ? const Center(child: CircularProgressIndicator(color: Cores.ciano))
                    : _tarefas.isEmpty
                        ? _vazio()
                        : ListView(
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
                            children: [
                              if (pendentes.isNotEmpty) ...[
                                _tituloSecao('Pendentes', pendentes.length, Cores.magenta),
                                for (final t in pendentes) _item(t),
                              ],
                              if (concluidas.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                _tituloSecao('Concluídas', concluidas.length, Cores.lima),
                                for (final t in concluidas) _item(t),
                              ],
                            ],
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(Tarefa t) => ItemTarefa(
        key: ValueKey('item-${t.id}'),
        tarefa: t,
        aoAlternar: () => _alternar(t),
        aoRemover: () => _remover(t),
      );

  Widget _cabecalho(int pendentes, int concluidas) {
    final total = pendentes + concluidas;
    final progresso = total == 0 ? 0.0 : concluidas / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            BotaoRedondo(
              icone: Icons.arrow_back_rounded,
              dica: 'Voltar ao calendário',
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Lista do dia',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        CartaoVidro(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              SizedBox(
                width: 74,
                height: 74,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: progresso,
                      strokeWidth: 8,
                      backgroundColor: const Color(0x26FFFFFF),
                      valueColor: const AlwaysStoppedAnimation<Color>(Cores.lima),
                    ),
                    Center(
                      child: Text(
                        '${(progresso * 100).round()}%',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nomesDiasSemana[widget.dia.weekday - 1].toUpperCase(),
                      style: const TextStyle(
                        color: Cores.ciano,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.6,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.dia.day} de ${nomesMeses[widget.dia.month - 1].toLowerCase()}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      total == 0
                          ? 'Nada planejado ainda'
                          : '$concluidas de $total concluída${total == 1 ? '' : 's'}',
                      style: const TextStyle(color: Cores.textoSuave),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tituloSecao(String titulo, int quantidade, Color cor) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            titulo.toUpperCase(),
            style: TextStyle(color: cor, fontWeight: FontWeight.w900, letterSpacing: 1.6),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: cor.withAlpha(40),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$quantidade',
              style: TextStyle(color: cor, fontWeight: FontWeight.w800, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _vazio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(gradient: Cores.frio, shape: BoxShape.circle),
              child: const Icon(Icons.wb_sunny_rounded, size: 46, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              'Dia livre por enquanto',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Toque em "Nova tarefa" para dar o primeiro passo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Cores.textoSuave),
            ),
          ],
        ),
      ),
    );
  }
}
