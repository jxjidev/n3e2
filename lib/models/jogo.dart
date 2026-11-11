enum StatusJogo {
  queroJogar('quero_jogar', 'Quero jogar'),
  jogando('jogando', 'Jogando'),
  zerado('zerado', 'Zerado');

  const StatusJogo(this.chave, this.rotulo);

  final String chave;
  final String rotulo;

  static StatusJogo daChave(String chave) {
    return StatusJogo.values.firstWhere(
      (s) => s.chave == chave,
      orElse: () => StatusJogo.queroJogar,
    );
  }
}

const categoriasJogo = [
  'Ação',
  'Aventura',
  'RPG',
  'Estratégia',
  'Esporte',
  'Corrida',
  'Luta',
  'Plataforma',
  'Puzzle',
  'Simulação',
  'Terror',
  'Outro',
];

class Jogo {
  const Jogo({
    this.id,
    required this.nome,
    required this.categoria,
    required this.plataforma,
    required this.descricao,
    required this.status,
    required this.criadoEm,
  });

  final int? id;
  final String nome;
  final String categoria;
  final String plataforma;
  final String descricao;
  final StatusJogo status;
  final DateTime criadoEm;

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'categoria': categoria,
      'plataforma': plataforma,
      'descricao': descricao,
      'status': status.chave,
      'criado_em': criadoEm.toIso8601String(),
    };
  }

  factory Jogo.fromMap(Map<String, Object?> map) {
    return Jogo(
      id: map['id'] as int,
      nome: map['nome'] as String,
      categoria: map['categoria'] as String,
      plataforma: (map['plataforma'] as String?) ?? '',
      descricao: map['descricao'] as String,
      status: StatusJogo.daChave(map['status'] as String),
      criadoEm: DateTime.parse(map['criado_em'] as String),
    );
  }

  Jogo copyWith({
    int? id,
    String? nome,
    String? categoria,
    String? plataforma,
    String? descricao,
    StatusJogo? status,
  }) {
    return Jogo(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      categoria: categoria ?? this.categoria,
      plataforma: plataforma ?? this.plataforma,
      descricao: descricao ?? this.descricao,
      status: status ?? this.status,
      criadoEm: criadoEm,
    );
  }
}
