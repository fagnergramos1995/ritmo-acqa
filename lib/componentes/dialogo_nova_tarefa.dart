import 'package:flutter/material.dart';

import '../tema/cores.dart';
import '../util/datas.dart';
import 'botao_gradiente.dart';

Future<String?> mostrarDialogoNovaTarefa(BuildContext context, DateTime dia) {
  return showDialog<String>(
    context: context,
    barrierColor: const Color(0xB30F0B24),
    builder: (_) => DialogoNovaTarefa(dia: dia),
  );
}

class DialogoNovaTarefa extends StatefulWidget {
  final DateTime dia;

  const DialogoNovaTarefa({super.key, required this.dia});

  @override
  State<DialogoNovaTarefa> createState() => _DialogoNovaTarefaState();
}

class _DialogoNovaTarefaState extends State<DialogoNovaTarefa> {
  final _controle = TextEditingController();
  String? _erro;

  static const _sugestoes = ['Estudar Flutter', 'Academia', 'Ler 20 páginas', 'Beber água'];

  @override
  void dispose() {
    _controle.dispose();
    super.dispose();
  }

  void _confirmar() {
    final texto = _controle.text.trim();
    if (texto.isEmpty) {
      setState(() => _erro = 'Dê um nome para a tarefa.');
      return;
    }
    Navigator.of(context).pop(texto);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Cores.noiteClara,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: const BorderSide(color: Cores.vidroBorda),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: Cores.frio,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.bolt_rounded, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nova tarefa',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                      ),
                      Text(
                        dataPorExtenso(widget.dia),
                        style: const TextStyle(color: Cores.textoSuave),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controle,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _confirmar(),
              onChanged: (_) {
                if (_erro != null) setState(() => _erro = null);
              },
              style: const TextStyle(color: Cores.texto, fontSize: 16),
              cursorColor: Cores.ciano,
              decoration: decoracaoCampo('O que você vai fazer?', Icons.edit_note_rounded)
                  .copyWith(errorText: _erro),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in _sugestoes)
                  ActionChip(
                    label: Text(s),
                    labelStyle: const TextStyle(color: Cores.texto, fontSize: 13),
                    backgroundColor: const Color(0x14FFFFFF),
                    side: const BorderSide(color: Cores.vidroBorda),
                    shape: const StadiumBorder(),
                    onPressed: () {
                      _controle.text = s;
                      _controle.selection =
                          TextSelection.collapsed(offset: s.length);
                      setState(() => _erro = null);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'A tarefa entra como pendente. Você marca como concluída depois.',
              style: TextStyle(color: Cores.textoSuave, fontSize: 12.5),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: Cores.textoSuave,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: BotaoGradiente(
                    rotulo: 'Adicionar',
                    icone: Icons.add_rounded,
                    onPressed: _confirmar,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}