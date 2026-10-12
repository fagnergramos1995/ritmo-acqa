import 'package:flutter/material.dart';

import 'componentes/fundo_aurora.dart';
import 'servicos/auth_servico.dart';
import 'tema/cores.dart';
import 'telas/tela_acesso.dart';
import 'telas/tela_calendario.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RitmoApp());
}

class RitmoApp extends StatelessWidget {
  const RitmoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ritmo',
      debugShowCheckedModeBanner: false,
      theme: temaAurora(),
      home: const Abertura(),
    );
  }
}

/// Decide a primeira tela: se já existe sessão salva, vai direto ao
/// calendário; senão, abre a tela de login/cadastro.
class Abertura extends StatefulWidget {
  const Abertura({super.key});

  @override
  State<Abertura> createState() => _AberturaState();
}

class _AberturaState extends State<Abertura> {
  late final Future<Usuario?> _sessao = AuthServico().usuarioLogado();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Usuario?>(
      future: _sessao,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: FundoAurora(
              child: Center(child: CircularProgressIndicator(color: Cores.ciano)),
            ),
          );
        }
        final usuario = snapshot.data;
        return usuario == null
            ? const TelaAcesso()
            : TelaCalendario(usuario: usuario);
      },
    );
  }
}
