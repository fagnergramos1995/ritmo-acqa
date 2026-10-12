import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Usuário cadastrado no aparelho.
class Usuario {
  final String nome;
  final String email;

  const Usuario({required this.nome, required this.email});

  String get primeiroNome => nome.trim().split(' ').first;
}

/// Erro de cadastro/login com mensagem pronta para exibir na tela.
class AuthErro implements Exception {
  final String mensagem;
  const AuthErro(this.mensagem);

  @override
  String toString() => mensagem;
}

/// Cadastro e login guardados localmente com shared_preferences.
///
/// O enunciado dispensa o Firebase; esta classe faz o papel que o
/// Firebase Authentication faria, e poderia ser trocada por ele sem
/// mudar as telas.
class AuthServico {
  static const _chaveUsuarios = 'ritmo_usuarios';
  static const _chaveSessao = 'ritmo_sessao';

  Future<Map<String, dynamic>> _lerUsuarios(SharedPreferences prefs) async {
    final bruto = prefs.getString(_chaveUsuarios);
    if (bruto == null) return {};
    return Map<String, dynamic>.from(jsonDecode(bruto) as Map);
  }

  /// Resumo simples da senha (FNV-1a de 32 bits), para não gravá-la em
  /// texto puro. Serve para fins didáticos; em produção usaríamos o
  /// Firebase Auth ou um algoritmo próprio para senhas.
  String _resumoSenha(String email, String senha) {
    var hash = 0x811c9dc5;
    for (final byte in utf8.encode('$email::$senha')) {
      hash ^= byte;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16);
  }

  Future<Usuario> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final usuarios = await _lerUsuarios(prefs);
    final chave = email.trim().toLowerCase();

    if (usuarios.containsKey(chave)) {
      throw const AuthErro('Já existe uma conta com este e-mail.');
    }

    usuarios[chave] = {
      'nome': nome.trim(),
      'senha': _resumoSenha(chave, senha),
    };
    await prefs.setString(_chaveUsuarios, jsonEncode(usuarios));
    await prefs.setString(_chaveSessao, chave);
    return Usuario(nome: nome.trim(), email: chave);
  }

  Future<Usuario> entrar({required String email, required String senha}) async {
    final prefs = await SharedPreferences.getInstance();
    final usuarios = await _lerUsuarios(prefs);
    final chave = email.trim().toLowerCase();
    final dados = usuarios[chave];

    if (dados == null) {
      throw const AuthErro('Não encontramos uma conta com este e-mail.');
    }
    final mapa = Map<String, dynamic>.from(dados as Map);
    if (mapa['senha'] != _resumoSenha(chave, senha)) {
      throw const AuthErro('Senha incorreta. Tente novamente.');
    }

    await prefs.setString(_chaveSessao, chave);
    return Usuario(nome: mapa['nome'] as String, email: chave);
  }

  /// Usuário que já estava logado ao abrir o app (ou null).
  Future<Usuario?> usuarioLogado() async {
    final prefs = await SharedPreferences.getInstance();
    final chave = prefs.getString(_chaveSessao);
    if (chave == null) return null;
    final usuarios = await _lerUsuarios(prefs);
    final dados = usuarios[chave];
    if (dados == null) return null;
    final mapa = Map<String, dynamic>.from(dados as Map);
    return Usuario(nome: mapa['nome'] as String, email: chave);
  }

  Future<void> sair() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chaveSessao);
  }
}
