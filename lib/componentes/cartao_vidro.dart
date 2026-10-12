import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../tema/cores.dart';

/// Cartão translúcido com desfoque do fundo (efeito "vidro fosco").
class CartaoVidro extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double raio;

  const CartaoVidro({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.raio = 28,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(raio),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Cores.vidro,
            borderRadius: BorderRadius.circular(raio),
            border: Border.all(color: Cores.vidroBorda),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Botão redondo translúcido (voltar, sair, setas do calendário).
class BotaoRedondo extends StatelessWidget {
  final IconData icone;
  final VoidCallback onPressed;
  final String dica;

  const BotaoRedondo({
    super.key,
    required this.icone,
    required this.onPressed,
    required this.dica,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: dica,
      child: Material(
        color: Cores.vidro,
        shape: const CircleBorder(side: BorderSide(color: Cores.vidroBorda)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icone, color: Cores.texto, size: 22),
          ),
        ),
      ),
    );
  }
}
