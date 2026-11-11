import '../models/jogo.dart';
import 'database_service.dart';

enum OrdemJogos {
  maisRecentes('Mais recentes', 'criado_em DESC'),
  maisAntigos('Mais antigos', 'criado_em ASC'),
  nomeAZ('Nome (A–Z)', 'nome COLLATE NOCASE ASC'),
  nomeZA('Nome (Z–A)', 'nome COLLATE NOCASE DESC');

  const OrdemJogos(this.rotulo, this.sql);

  final String rotulo;
  final String sql;
}

class RepositorioException implements Exception {
  const RepositorioException(this.mensagem, [this.causa]);

  final String mensagem;
  final Object? causa;

  @override
  String toString() => 'RepositorioException: $mensagem ($causa)';
}

class JogoRepository {
  JogoRepository([DatabaseService? database])
      : _database = database ?? DatabaseService.instance;

  final DatabaseService _database;

  static const _tabela = 'jogos';

  Future<Jogo> inserir(Jogo jogo) async {
    try {
      final db = await _database.database;
      final id = await db.insert(_tabela, jogo.toMap());
      return jogo.copyWith(id: id);
    } catch (error) {
      throw RepositorioException('Não foi possível salvar o jogo.', error);
    }
  }

  Future<List<Jogo>> listar({
    String busca = '',
    StatusJogo? status,
    String? categoria,
    OrdemJogos ordem = OrdemJogos.maisRecentes,
  }) async {
    try {
      final condicoes = <String>[];
      final argumentos = <Object?>[];

      final termo = busca.trim();
      if (termo.isNotEmpty) {
        condicoes.add('nome LIKE ?');
        argumentos.add('%$termo%');
      }
      if (status != null) {
        condicoes.add('status = ?');
        argumentos.add(status.chave);
      }
      if (categoria != null) {
        condicoes.add('categoria = ?');
        argumentos.add(categoria);
      }

      final db = await _database.database;
      final linhas = await db.query(
        _tabela,
        where: condicoes.isEmpty ? null : condicoes.join(' AND '),
        whereArgs: argumentos.isEmpty ? null : argumentos,
        orderBy: ordem.sql,
      );
      return linhas.map(Jogo.fromMap).toList();
    } catch (error) {
      throw RepositorioException('Não foi possível carregar a coleção.', error);
    }
  }

  Future<Map<StatusJogo, int>> contarPorStatus() async {
    try {
      final db = await _database.database;
      final linhas = await db.rawQuery(
        'SELECT status, COUNT(*) AS total FROM $_tabela GROUP BY status',
      );
      return {
        for (final linha in linhas)
          StatusJogo.daChave(linha['status'] as String): linha['total'] as int,
      };
    } catch (error) {
      throw RepositorioException('Não foi possível contar os jogos.', error);
    }
  }

  Future<void> atualizar(Jogo jogo) async {
    if (jogo.id == null) {
      throw const RepositorioException('Jogo sem identificador.');
    }
    try {
      final db = await _database.database;
      final alteradas = await db.update(
        _tabela,
        jogo.toMap(),
        where: 'id = ?',
        whereArgs: [jogo.id],
      );
      if (alteradas == 0) {
        throw const RepositorioException('O jogo não existe mais.');
      }
    } on RepositorioException {
      rethrow;
    } catch (error) {
      throw RepositorioException('Não foi possível salvar as alterações.', error);
    }
  }

  Future<void> excluir(int id) async {
    try {
      final db = await _database.database;
      await db.delete(_tabela, where: 'id = ?', whereArgs: [id]);
    } catch (error) {
      throw RepositorioException('Não foi possível excluir o jogo.', error);
    }
  }
}
