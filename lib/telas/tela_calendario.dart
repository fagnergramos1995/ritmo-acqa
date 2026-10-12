import 'package:flutter/material.dart';

import '../componentes/botao_gradiente.dart';
import '../componentes/calendario_mes.dart';
import '../componentes/cartao_vidro.dart';
import '../componentes/fundo_aurora.dart';
import '../modelos/tarefa.dart';
import '../servicos/auth_servico.dart';
import '../servicos/tarefa_servico.dart';
import '../tema/cores.dart';
import '../util/datas.dart';
import 'tela_acesso.dart';
import 'tela_tarefas.dart';

/// Tela do calendário: escolhe o dia e mostra um resumo das tarefas dele.
class TelaCalendario extends StatefulWidget {
  final Usuario usuario;

  const TelaCalendario({super.key, required this.usuario});

  @override
  State<TelaCalendario> createState() => _TelaCalendarioState();
}

class _TelaCalendarioState extends State<TelaCalendario> {
  late final TarefaServico _servico = TarefaServico(widget.usuario.email);

  DateTime _mes = DateTime.now();
  DateTime _selecionado = somenteData(DateTime.now());
  Map<String, ResumoDia> _resumo = {};

  @override
  void initState() {
    super.initState();
    _carregarResumo();
  }

  Future<void> _carregarResumo() async {
    final resumo = await _servico.resumoPorDia();
    if (!mounted) return;
    setState(() => _resumo = resumo);
  }

  void _mudarMes(int passo) {
    setState(() => _mes = DateTime(_mes.year, _mes.month + passo, 1));
  }

  void _selecionar(DateTime dia) {
    // Tocar de novo no dia já selecionado abre a lista direto.
    if (mesmoDia(dia, _selecionado)) {
      _abrirLista();
      return;
    }
    setState(() {
      _selecionado = somenteData(dia);
      _mes = DateTime(dia.year, dia.month, 1);
    });
  }

  void _irParaHoje() {
    final hoje = somenteData(DateTime.now());
    setState(() {
      _selecionado = hoje;
      _mes = DateTime(hoje.year, hoje.month, 1);
    });
  }

  Future<void> _abrirLista() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TelaTarefas(dia: _selecionado, servico: _servico),
      ),
    );
    // Ao voltar, atualiza os pontinhos do calendário.
    _carregarResumo();
  }

  Future<void> _sair() async {
    await AuthServico().sair();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const TelaAcesso()),
      (_) => false,
    );
  }

  String _saudacao() {
    final hora = DateTime.now().hour;
    if (hora < 12) return 'Bom dia';
    if (hora < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  @override
  Widget build(BuildContext context) {
    final resumoDia = _resumo[chaveData(_selecionado)] ?? const ResumoDia();

    return Scaffold(
      body: FundoAurora(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _cabecalho(),
                const SizedBox(height: 22),
                CartaoVidro(
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
                  child: CalendarioMes(
                    mes: _mes,
                    selecionado: _selecionado,
                    resumo: _resumo,
                    aoSelecionar: _selecionar,
                    aoMudarMes: _mudarMes,
                  ),
                ),
                const SizedBox(height: 12),
                _legenda(),
                const SizedBox(height: 20),
                _painelDoDia(resumoDia),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cabecalho() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_saudacao()}, ${widget.usuario.primeiroNome}!',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              const Text(
                'Qual dia vamos organizar?',
                style: TextStyle(color: Cores.textoSuave, fontSize: 15),
              ),
            ],
          ),
        ),
        BotaoRedondo(icone: Icons.today_rounded, dica: 'Ir para hoje', onPressed: _irParaHoje),
        const SizedBox(width: 8),
        BotaoRedondo(icone: Icons.logout_rounded, dica: 'Sair', onPressed: _sair),
      ],
    );
  }

  Widget _legenda() {
    Widget item(Color cor, String texto) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(texto, style: const TextStyle(color: Cores.textoSuave, fontSize: 12.5)),
          ],
        );

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 18,
      runSpacing: 6,
      children: [
        item(Cores.magenta, 'Pendentes'),
        item(Cores.lima, 'Concluídas'),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Cores.lima, width: 1.6),
              ),
            ),
            const SizedBox(width: 6),
            const Text('Hoje', style: TextStyle(color: Cores.textoSuave, fontSize: 12.5)),
          ],
        ),
      ],
    );
  }

  Widget _painelDoDia(ResumoDia resumo) {
    final String mensagem;
    if (resumo.total == 0) {
      mensagem = 'Nenhuma tarefa ainda. Que tal planejar este dia?';
    } else if (resumo.pendentes == 0) {
      mensagem = 'Tudo concluído. Dia vencido!';
    } else {
      mensagem = '${resumo.pendentes} pendente${resumo.pendentes == 1 ? '' : 's'}'
          ' · ${resumo.concluidas} concluída${resumo.concluidas == 1 ? '' : 's'}';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: Cores.frio,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Cores.violeta.withAlpha(110), blurRadius: 30, offset: const Offset(0, 14)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dataPorExtenso(_selecionado).toUpperCase(),
            style: const TextStyle(
              color: Color(0xCCFFFFFF),
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            mensagem,
            style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: resumo.progresso,
              minHeight: 10,
              backgroundColor: const Color(0x40FFFFFF),
              valueColor: const AlwaysStoppedAnimation<Color>(Cores.lima),
            ),
          ),
          const SizedBox(height: 18),
          BotaoGradiente(
            rotulo: 'Abrir tarefas do dia',
            icone: Icons.checklist_rounded,
            onPressed: _abrirLista,
          ),
        ],
      ),
    );
  }
}
