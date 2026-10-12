import 'package:flutter/material.dart';

import '../tema/cores.dart';

class BotaoGradiente extends StatelessWidget {
  final String rotulo;
  final VoidCallback? onPressed;
  final IconData? icone;
  final bool carregando;
  final LinearGradient gradiente;
  final bool expandir;

  const BotaoGradiente({
    super.key,
    required this.rotulo,
    required this.onPressed,
    this.icone,
    this.carregando = false,
    this.gradiente = Cores.quente,
    this.expandir = true,
  });

  @override
  Widget build(BuildContext context) {
    final corBrilho = gradiente.colors.first;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradiente,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: corBrilho.withAlpha(100),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: carregando ? null : onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            child: Row(
              mainAxisSize: expandir ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (carregando)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                else ...[
                  if (icone != null) ...[
                    Icon(icone, color: Colors.white, size: 22),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    rotulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}