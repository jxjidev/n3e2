import 'package:flutter_test/flutter_test.dart';
import 'package:minha_colecao/models/jogo.dart';

void main() {
  final criadoEm = DateTime(2026, 11, 11, 19, 30);

  test('toMap converte o objeto nas colunas da tabela', () {
    final jogo = Jogo(
      nome: 'Hollow Knight',
      categoria: 'Plataforma',
      plataforma: 'Switch',
      descricao: 'Metroidvania',
      status: StatusJogo.jogando,
      criadoEm: criadoEm,
    );

    final map = jogo.toMap();

    expect(map.containsKey('id'), isFalse);
    expect(map['nome'], 'Hollow Knight');
    expect(map['status'], 'jogando');
    expect(map['criado_em'], criadoEm.toIso8601String());
  });

  test('fromMap reconstrói o objeto a partir da linha do banco', () {
    final jogo = Jogo.fromMap({
      'id': 7,
      'nome': 'Celeste',
      'categoria': 'Plataforma',
      'plataforma': 'PC',
      'descricao': 'Escalada',
      'status': 'zerado',
      'criado_em': criadoEm.toIso8601String(),
    });

    expect(jogo.id, 7);
    expect(jogo.status, StatusJogo.zerado);
    expect(jogo.criadoEm, criadoEm);
  });

  test('status desconhecido no banco cai em "Quero jogar"', () {
    expect(StatusJogo.daChave('inexistente'), StatusJogo.queroJogar);
  });
}
