import 'package:flutter/material.dart';

import '../modelos/tarefa.dart';
import '../tema/cores.dart';

/// Linha de uma tarefa: marcador de conclusão, título e botão de remover.
/// Também pode ser removida arrastando para a esquerda.
class ItemTarefa extends StatelessWidget {
  final Tarefa tarefa;
  final VoidCallback aoAlternar;
  final VoidCallback aoRemover;

  const ItemTarefa({
    super.key,
    required this.tarefa,
    required this.aoAlternar,
    required this.aoRemover,
  });

  @override
  Widget build(BuildContext context) {
    final feita = tarefa.concluida;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: ValueKey(tarefa.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => aoRemover(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0x00FF4D6D), Cores.perigo]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 28),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: feita ? const Color(0x0DFFFFFF) : const Color(0x1FFFFFFF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: feita ? Cores.lima.withAlpha(70) : Cores.vidroBorda,
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: aoAlternar,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: feita ? Cores.feito : null,
                    border: feita ? null : Border.all(color: Cores.magenta, width: 2.2),
                  ),
                  child: feita
                      ? const Icon(Icons.check_rounded, size: 20, color: Cores.noite)
                      : null,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: aoAlternar,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 260),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: feita ? FontWeight.w500 : FontWeight.w700,
                      color: feita ? Cores.textoSuave : Cores.texto,
                      decoration: feita ? TextDecoration.lineThrough : TextDecoration.none,
                      decorationColor: Cores.lima,
                      decorationThickness: 2,
                    ),
                    child: Text(tarefa.titulo),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Remover tarefa',
                onPressed: aoRemover,
                icon: const Icon(Icons.delete_outline_rounded, color: Cores.textoSuave),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
