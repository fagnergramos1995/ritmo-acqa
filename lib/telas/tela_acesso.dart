import 'package:flutter/material.dart';

import '../componentes/botao_gradiente.dart';
import '../componentes/cartao_vidro.dart';
import '../componentes/fundo_aurora.dart';
import '../servicos/auth_servico.dart';
import '../tema/cores.dart';
import 'tela_calendario.dart';

class TelaAcesso extends StatefulWidget {
  const TelaAcesso({super.key});

  @override
  State<TelaAcesso> createState() => _TelaAcessoState();
}

class _TelaAcessoState extends State<TelaAcesso> {
  final _formulario = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  final _confirmacao = TextEditingController();
  final _auth = AuthServico();

  bool _modoCadastro = false;
  bool _senhaVisivel = false;
  bool _carregando = false;

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _senha.dispose();
    _confirmacao.dispose();
    super.dispose();
  }

  void _trocarModo(bool cadastro) {
    if (cadastro == _modoCadastro) return;
    setState(() => _modoCadastro = cadastro);
  }

  Future<void> _enviar() async {
    FocusScope.of(context).unfocus();
    if (!(_formulario.currentState?.validate() ?? false)) return;

    setState(() => _carregando = true);
    try {
      final usuario = _modoCadastro
          ? await _auth.cadastrar(
              nome: _nome.text,
              email: _email.text,
              senha: _senha.text,
            )
          : await _auth.entrar(email: _email.text, senha: _senha.text);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => TelaCalendario(usuario: usuario)),
      );
    } on AuthErro catch (erro) {
      _mostrarErro(erro.mensagem);
    } catch (_) {
      _mostrarErro('Algo deu errado. Tente novamente.');
    }
  }

  void _mostrarErro(String mensagem) {
    if (!mounted) return;
    setState(() => _carregando = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Cores.perigo,
        content: Text(mensagem, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  String? _validarNome(String? valor) {
    if (valor == null || valor.trim().length < 2) return 'Informe seu nome.';
    return null;
  }

  String? _validarEmail(String? valor) {
    final email = valor?.trim() ?? '';
    final padrao = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!padrao.hasMatch(email)) return 'Digite um e-mail válido.';
    return null;
  }

  String? _validarSenha(String? valor) {
    if (valor == null || valor.length < 6) return 'A senha precisa de 6 caracteres ou mais.';
    return null;
  }

  String? _validarConfirmacao(String? valor) {
    if (valor != _senha.text) return 'As senhas não conferem.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FundoAurora(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _marca(),
                    const SizedBox(height: 32),
                    CartaoVidro(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                      child: Form(
                        key: _formulario,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _seletorModo(),
                            const SizedBox(height: 24),
                            AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              child: _modoCadastro
                                  ? Padding(
                                      padding: const EdgeInsets.only(bottom: 14),
                                      child: TextFormField(
                                        controller: _nome,
                                        textCapitalization: TextCapitalization.words,
                                        textInputAction: TextInputAction.next,
                                        style: const TextStyle(color: Cores.texto),
                                        decoration: decoracaoCampo('Nome', Icons.person_outline_rounded),
                                        validator: _validarNome,
                                      ),
                                    )
                                  : const SizedBox(width: double.infinity),
                            ),
                            TextFormField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autocorrect: false,
                              style: const TextStyle(color: Cores.texto),
                              decoration: decoracaoCampo('E-mail', Icons.alternate_email_rounded),
                              validator: _validarEmail,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _senha,
                              obscureText: !_senhaVisivel,
                              textInputAction:
                                  _modoCadastro ? TextInputAction.next : TextInputAction.done,
                              onFieldSubmitted: (_) {
                                if (!_modoCadastro) _enviar();
                              },
                              style: const TextStyle(color: Cores.texto),
                              decoration: decoracaoCampo(
                                'Senha',
                                Icons.lock_outline_rounded,
                                sufixo: IconButton(
                                  tooltip: _senhaVisivel ? 'Ocultar senha' : 'Mostrar senha',
                                  onPressed: () => setState(() => _senhaVisivel = !_senhaVisivel),
                                  icon: Icon(
                                    _senhaVisivel
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                    color: Cores.textoSuave,
                                  ),
                                ),
                              ),
                              validator: _validarSenha,
                            ),
                            AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              child: _modoCadastro
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 14),
                                      child: TextFormField(
                                        controller: _confirmacao,
                                        obscureText: !_senhaVisivel,
                                        textInputAction: TextInputAction.done,
                                        onFieldSubmitted: (_) => _enviar(),
                                        style: const TextStyle(color: Cores.texto),
                                        decoration: decoracaoCampo(
                                          'Confirmar senha',
                                          Icons.verified_user_outlined,
                                        ),
                                        validator: _validarConfirmacao,
                                      ),
                                    )
                                  : const SizedBox(width: double.infinity),
                            ),
                            const SizedBox(height: 26),
                            BotaoGradiente(
                              rotulo: _modoCadastro ? 'Criar minha conta' : 'Entrar',
                              icone: _modoCadastro
                                  ? Icons.rocket_launch_rounded
                                  : Icons.arrow_forward_rounded,
                              carregando: _carregando,
                              onPressed: _enviar,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextButton(
                      onPressed: () => _trocarModo(!_modoCadastro),
                      child: Text(
                        _modoCadastro
                            ? 'Já tenho conta. Quero entrar'
                            : 'Primeira vez aqui? Crie sua conta',
                        style: const TextStyle(color: Cores.ciano, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _marca() {
    return Column(
      children: [
        Transform.rotate(
          angle: -0.18,
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              gradient: Cores.quente,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(color: Cores.magenta.withAlpha(130), blurRadius: 34, offset: const Offset(0, 12)),
              ],
            ),
            child: const Icon(Icons.graphic_eq_rounded, size: 48, color: Colors.white),
          ),
        ),
        const SizedBox(height: 22),
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (limites) => Cores.frio.createShader(limites),
          child: const Text(
            'ritmo',
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: 2, height: 1),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'seu dia, no seu compasso',
          style: TextStyle(color: Cores.textoSuave, fontSize: 15, letterSpacing: 1.2),
        ),
      ],
    );
  }

  Widget _seletorModo() {
    return Container(
      height: 54,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0x26000000),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            alignment: _modoCadastro ? Alignment.centerRight : Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: Cores.quente,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          Row(
            children: [
              _aba('Entrar', !_modoCadastro, () => _trocarModo(false)),
              _aba('Criar conta', _modoCadastro, () => _trocarModo(true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _aba(String rotulo, bool ativa, VoidCallback aoTocar) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: aoTocar,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: TextStyle(
              color: ativa ? Colors.white : Cores.textoSuave,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
            child: Text(rotulo),
          ),
        ),
      ),
    );
  }
}