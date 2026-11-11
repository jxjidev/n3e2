import 'package:flutter/material.dart';

class EstadoMensagem extends StatelessWidget {
  const EstadoMensagem({
    super.key,
    required this.icone,
    required this.titulo,
    required this.mensagem,
    this.textoBotao,
    this.onBotao,
  });

  final IconData icone;
  final String titulo;
  final String mensagem;
  final String? textoBotao;
  final VoidCallback? onBotao;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 56, color: tema.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              titulo,
              style: tema.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              mensagem,
              style: tema.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (textoBotao != null && onBotao != null) ...[
              const SizedBox(height: 20),
              FilledButton.tonal(onPressed: onBotao, child: Text(textoBotao!)),
            ],
          ],
        ),
      ),
    );
  }
}
