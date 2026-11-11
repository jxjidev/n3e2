import 'package:flutter/material.dart';

import '../models/jogo.dart';
import 'status_badge.dart';

class JogoCard extends StatelessWidget {
  const JogoCard({
    super.key,
    required this.jogo,
    required this.onEditar,
    required this.onExcluir,
  });

  final Jogo jogo;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final detalhes = [
      jogo.categoria,
      if (jogo.plataforma.isNotEmpty) jogo.plataforma,
    ].join(' · ');

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onEditar,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(jogo.nome, style: tema.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      detalhes,
                      style: tema.textTheme.bodySmall
                          ?.copyWith(color: tema.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      jogo.descricao,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: tema.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    StatusBadge(jogo.status),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Ações',
                onSelected: (acao) =>
                    acao == 'editar' ? onEditar() : onExcluir(),
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'editar',
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Editar'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'excluir',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline),
                      title: Text('Excluir'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
