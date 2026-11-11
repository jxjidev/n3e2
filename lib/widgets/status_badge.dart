import 'package:flutter/material.dart';

import '../models/jogo.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key});

  final StatusJogo status;

  static IconData icone(StatusJogo status) => switch (status) {
        StatusJogo.queroJogar => Icons.bookmark_border,
        StatusJogo.jogando => Icons.sports_esports,
        StatusJogo.zerado => Icons.emoji_events_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final (fundo, texto) = switch (status) {
      StatusJogo.queroJogar => (cores.surfaceContainerHighest, cores.onSurfaceVariant),
      StatusJogo.jogando => (cores.tertiaryContainer, cores.onTertiaryContainer),
      StatusJogo.zerado => (cores.primaryContainer, cores.onPrimaryContainer),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone(status), size: 14, color: texto),
          const SizedBox(width: 4),
          Text(
            status.rotulo,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: texto, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
