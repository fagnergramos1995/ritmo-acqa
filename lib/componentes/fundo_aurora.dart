import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tema/cores.dart';

/// Fundo animado com "manchas" de luz que se movem devagar,
/// lembrando uma aurora. Usado em todas as telas.
class FundoAurora extends StatefulWidget {
  final Widget child;

  const FundoAurora({super.key, required this.child});

  @override
  State<FundoAurora> createState() => _FundoAuroraState();
}

class _FundoAuroraState extends State<FundoAurora>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controle = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controle,
      child: widget.child,
      builder: (context, filho) {
        final t = _controle.value * math.pi;
        return Stack(
          children: [
            const Positioned.fill(child: ColoredBox(color: Cores.noite)),
            _mancha(Alignment(-1.2 + 0.4 * math.sin(t), -1.0 + 0.2 * math.cos(t)), 360, Cores.magenta),
            _mancha(Alignment(1.3 - 0.3 * math.cos(t), -0.2 + 0.3 * math.sin(t)), 320, Cores.violeta),
            _mancha(Alignment(-0.6 + 0.5 * math.cos(t), 1.2 - 0.2 * math.sin(t)), 380, Cores.ciano),
            _mancha(Alignment(1.0 - 0.2 * math.sin(t), 1.1), 220, Cores.laranja),
            Positioned.fill(child: filho!),
          ],
        );
      },
    );
  }

  Widget _mancha(Alignment posicao, double tamanho, Color cor) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Align(
          alignment: posicao,
          child: Container(
            width: tamanho,
            height: tamanho,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [cor.withAlpha(105), cor.withAlpha(0)],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
