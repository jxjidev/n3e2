import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  DatabaseService._({DatabaseFactory? factory, String? path})
      : _factory = factory,
        _path = path;

  static final DatabaseService instance = DatabaseService._();

  factory DatabaseService.paraTeste({
    required DatabaseFactory factory,
    required String path,
  }) {
    return DatabaseService._(factory: factory, path: path);
  }

  static const _nomeArquivo = 'minha_colecao.db';
  static const _versao = 1;

  final DatabaseFactory? _factory;
  final String? _path;
  Future<Database>? _abrindo;

  Future<Database> get database => _abrindo ??= _abrir();

  Future<Database> _abrir() async {
    final factory = _factory ?? databaseFactory;
    final caminho =
        _path ?? p.join(await factory.getDatabasesPath(), _nomeArquivo);

    return factory.openDatabase(
      caminho,
      options: OpenDatabaseOptions(
        version: _versao,
        onCreate: _criarEstrutura,
      ),
    );
  }

  Future<void> _criarEstrutura(Database db, int versao) async {
    await db.execute('''
      CREATE TABLE jogos (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        nome        TEXT NOT NULL CHECK (length(trim(nome)) > 0),
        categoria   TEXT NOT NULL CHECK (length(trim(categoria)) > 0),
        plataforma  TEXT NOT NULL DEFAULT '',
        descricao   TEXT NOT NULL CHECK (length(trim(descricao)) > 0),
        status      TEXT NOT NULL
                    CHECK (status IN ('quero_jogar', 'jogando', 'zerado')),
        criado_em   TEXT NOT NULL
      )
    ''');

    await db.execute('CREATE INDEX idx_jogos_status ON jogos (status)');
    await db.execute('CREATE INDEX idx_jogos_categoria ON jogos (categoria)');
  }

  Future<void> fechar() async {
    final aberto = _abrindo;
    _abrindo = null;
    if (aberto != null) await (await aberto).close();
  }
}
