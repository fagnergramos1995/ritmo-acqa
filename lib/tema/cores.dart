import 'package:flutter/material.dart';

/// Paleta "Aurora": fundo noturno com cores neon vibrantes.
class Cores {
  Cores._();

  static const Color noite = Color(0xFF0F0B24);
  static const Color noiteClara = Color(0xFF1B1540);
  static const Color magenta = Color(0xFFFF3D9A);
  static const Color laranja = Color(0xFFFF8A3D);
  static const Color lima = Color(0xFFC6FF3D);
  static const Color ciano = Color(0xFF3DE0FF);
  static const Color violeta = Color(0xFF8B5CFF);

  static const Color texto = Color(0xFFF5F3FF);
  static const Color textoSuave = Color(0xFFADA6D6);
  static const Color vidro = Color(0x1AFFFFFF);
  static const Color vidroBorda = Color(0x33FFFFFF);
  static const Color perigo = Color(0xFFFF4D6D);

  /// Gradiente quente: botões principais e dia selecionado.
  static const LinearGradient quente = LinearGradient(
    colors: [magenta, laranja],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente frio: cabeçalhos e destaques secundários.
  static const LinearGradient frio = LinearGradient(
    colors: [violeta, ciano],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente de conclusão: tarefas feitas.
  static const LinearGradient feito = LinearGradient(
    colors: [lima, ciano],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Tema global do aplicativo.
ThemeData temaAurora() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Cores.magenta,
      brightness: Brightness.dark,
    ),
  );
  return base.copyWith(
    scaffoldBackgroundColor: Cores.noite,
    textTheme: base.textTheme.apply(
      bodyColor: Cores.texto,
      displayColor: Cores.texto,
    ),
  );
}

/// Decoração padrão dos campos de texto (estilo "vidro").
InputDecoration decoracaoCampo(String rotulo, IconData icone, {Widget? sufixo}) {
  OutlineInputBorder borda(Color cor, [double largura = 1.2]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: cor, width: largura),
      );

  return InputDecoration(
    labelText: rotulo,
    labelStyle: const TextStyle(color: Cores.textoSuave),
    floatingLabelStyle: const TextStyle(color: Cores.ciano, fontWeight: FontWeight.w600),
    prefixIcon: Icon(icone, color: Cores.textoSuave),
    suffixIcon: sufixo,
    filled: true,
    fillColor: const Color(0x14FFFFFF),
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    enabledBorder: borda(Cores.vidroBorda),
    focusedBorder: borda(Cores.ciano, 2),
    errorBorder: borda(Cores.perigo),
    focusedErrorBorder: borda(Cores.perigo, 2),
    errorStyle: const TextStyle(color: Cores.perigo),
  );
}
