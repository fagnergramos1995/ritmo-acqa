import 'package:flutter/material.dart';

import '../modelos/tarefa.dart';
import '../tema/cores.dart';
import '../util/datas.dart';
import 'cartao_vidro.dart';

class CalendarioMes extends StatelessWidget {
  final DateTime mes;
  final DateTime selecionado;
  final Map<String, ResumoDia> resumo;
  final ValueChanged<DateTime> aoSelecionar;
  final ValueChanged<int> aoMudarMes;

  const CalendarioMes({
    super.key,
    required this.mes,
    required this.selecionado,
    required this.resumo,
    required this.aoSelecionar,
    required this.aoMudarMes,
  });

  @override
  Widget build(BuildContext context) {
    final primeiroDia = DateTime(mes.year, mes.month, 1);
    final diasNoMes = DateTime(mes.year, mes.month + 1, 0).day;
    final deslocamento = primeiroDia.weekday % 7;
    final semanas = ((deslocamento + diasNoMes) / 7).ceil();
    final hoje = DateTime.now();

    return Column(
      children: [
        Row(
          children: [
            BotaoRedondo(
              icone: Icons.chevron_left_rounded,
              dica: 'Mês anterior',
              onPressed: () => aoMudarMes(-1),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    nomesMeses[mes.month - 1].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                    ),
                  ),
                  Text(
                    '${mes.year}',
                    style: const TextStyle(color: Cores.textoSuave, letterSpacing: 2),
                  ),
                ],
              ),
            ),
            BotaoRedondo(
              icone: Icons.chevron_right_rounded,
              dica: 'Próximo mês',
              onPressed: () => aoMudarMes(1),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: Center(
                  child: Text(
                    iniciaisSemana[i],
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: i == 0 ? Cores.magenta : Cores.textoSuave,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        for (var semana = 0; semana < semanas; semana++)
          Row(
            children: [
              for (var d = 0; d < 7; d++)
                Expanded(
                  child: _celula(
                    DateTime(mes.year, mes.month, 1 - deslocamento + semana * 7 + d),
                    hoje,
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _celula(DateTime dia, DateTime hoje) {
    final doMes = dia.month == mes.month;
    final ehSelecionado = mesmoDia(dia, selecionado);
    final ehHoje = mesmoDia(dia, hoje);
    final info = resumo[chaveData(dia)];

    Color corNumero;
    if (ehSelecionado) {
      corNumero = Colors.white;
    } else if (!doMes) {
      corNumero = Cores.textoSuave.withAlpha(90);
    } else {
      corNumero = Cores.texto;
    }

    return AspectRatio(
      aspectRatio: 1,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => aoSelecionar(dia),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            gradient: ehSelecionado ? Cores.quente : null,
            color: ehSelecionado
                ? null
                : (info != null && doMes ? const Color(0x12FFFFFF) : Colors.transparent),
            borderRadius: BorderRadius.circular(14),
            border: ehHoje && !ehSelecionado
                ? Border.all(color: Cores.lima, width: 1.6)
                : null,
            boxShadow: ehSelecionado
                ? [BoxShadow(color: Cores.magenta.withAlpha(110), blurRadius: 16)]
                : null,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${dia.day}',
                style: TextStyle(
                  color: corNumero,
                  fontSize: 15,
                  fontWeight: ehSelecionado || ehHoje ? FontWeight.w900 : FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              SizedBox(
                height: 6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (info != null && info.pendentes > 0)
                      _ponto(ehSelecionado ? Colors.white : Cores.magenta),
                    if (info != null && info.concluidas > 0)
                      _ponto(ehSelecionado ? Cores.noite : Cores.lima),
                  ],
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  Widget _ponto(Color cor) => Container(
        width: 6,
        height: 6,
        margin: const EdgeInsets.symmetric(horizontal: 1.5),
        decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
      );
}