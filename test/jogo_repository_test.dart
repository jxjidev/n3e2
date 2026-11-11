import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:minha_colecao/models/jogo.dart';
import 'package:minha_colecao/services/database_service.dart';
import 'package:minha_colecao/services/jogo_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late DatabaseService banco;
  late JogoRepository repo;

  Jogo novo(String nome, {StatusJogo status = StatusJogo.queroJogar}) => Jogo(
        nome: nome,
        categoria: 'RPG',
        plataforma: 'PC',
        descricao: 'Descrição de $nome',
        status: status,
        criadoEm: DateTime.now(),
      );

  setUp(() {
    banco = DatabaseService.paraTeste(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    repo = JogoRepository(banco);
  });

  tearDown(() => banco.fechar());

  test('CREATE e READ', () async {
    final salvo = await repo.inserir(novo('Elden Ring'));
    expect(salvo.id, isNotNull);

    final lista = await repo.listar();
    expect(lista.map((j) => j.nome), ['Elden Ring']);
  });

  test('UPDATE altera e persiste', () async {
    final salvo = await repo.inserir(novo('Hades'));
    await repo.atualizar(salvo.copyWith(status: StatusJogo.zerado));

    final lista = await repo.listar();
    expect(lista.single.status, StatusJogo.zerado);
  });

  test('DELETE remove o registro', () async {
    final salvo = await repo.inserir(novo('Doom'));
    await repo.excluir(salvo.id!);

    expect(await repo.listar(), isEmpty);
  });

  test('pesquisa por nome, filtro por status e ordenação', () async {
    await repo.inserir(novo('Zelda', status: StatusJogo.zerado));
    await repo.inserir(novo('Celeste', status: StatusJogo.jogando));
    await repo.inserir(novo('Cuphead', status: StatusJogo.zerado));

    final busca = await repo.listar(busca: 'ce');
    expect(busca.map((j) => j.nome), ['Celeste']);

    final zerados =
        await repo.listar(status: StatusJogo.zerado, ordem: OrdemJogos.nomeAZ);
    expect(zerados.map((j) => j.nome), ['Cuphead', 'Zelda']);

    final contagem = await repo.contarPorStatus();
    expect(contagem[StatusJogo.zerado], 2);
    expect(contagem[StatusJogo.jogando], 1);
  });

  test('banco recusa campo obrigatório vazio', () async {
    expect(() => repo.inserir(novo('   ')), throwsA(isA<RepositorioException>()));
  });

  test('dados continuam após fechar e reabrir o banco (persistência)',
      () async {
    final pasta = await Directory.systemTemp.createTemp('minha_colecao');
    final caminho = '${pasta.path}/teste.db';

    final primeiroBanco =
        DatabaseService.paraTeste(factory: databaseFactoryFfi, path: caminho);
    final primeiro = JogoRepository(primeiroBanco);
    await primeiro.inserir(novo('Stardew Valley'));
    await primeiro.inserir(novo('Terraria'));
    await primeiro.inserir(novo('Minecraft'));
    await primeiroBanco.fechar();

    final segundoBanco =
        DatabaseService.paraTeste(factory: databaseFactoryFfi, path: caminho);
    final segundo = JogoRepository(segundoBanco);
    final lista = await segundo.listar(ordem: OrdemJogos.nomeAZ);

    expect(lista.map((j) => j.nome), ['Minecraft', 'Stardew Valley', 'Terraria']);

    await segundoBanco.fechar();
    await pasta.delete(recursive: true);
  });
}
