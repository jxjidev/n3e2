import 'package:flutter/material.dart';

import '../models/jogo.dart';
import '../services/jogo_repository.dart';
import '../widgets/status_badge.dart';

class JogoFormPage extends StatefulWidget {
  const JogoFormPage({super.key, this.jogo, required this.repository});

  final Jogo? jogo;
  final JogoRepository repository;

  @override
  State<JogoFormPage> createState() => _JogoFormPageState();
}

class _JogoFormPageState extends State<JogoFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final _nomeController = TextEditingController(text: widget.jogo?.nome);
  late final _plataformaController =
      TextEditingController(text: widget.jogo?.plataforma);
  late final _descricaoController =
      TextEditingController(text: widget.jogo?.descricao);
  late String? _categoria = widget.jogo?.categoria;
  late StatusJogo _status = widget.jogo?.status ?? StatusJogo.queroJogar;

  bool _salvando = false;

  bool get _editando => widget.jogo != null;

  @override
  void dispose() {
    _nomeController.dispose();
    _plataformaController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  String? _obrigatorio(String? valor, String campo) {
    if ((valor ?? '').trim().isEmpty) return 'Informe $campo';
    return null;
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    final dados = Jogo(
      id: widget.jogo?.id,
      nome: _nomeController.text.trim(),
      categoria: _categoria!,
      plataforma: _plataformaController.text.trim(),
      descricao: _descricaoController.text.trim(),
      status: _status,
      criadoEm: widget.jogo?.criadoEm ?? DateTime.now(),
    );

    try {
      if (_editando) {
        await widget.repository.atualizar(dados);
      } else {
        await widget.repository.inserir(dados);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on RepositorioException catch (e) {
      _mostrarErro(e.mensagem);
    } catch (_) {
      _mostrarErro('Erro inesperado ao salvar.');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  void _mostrarErro(String texto) {
    if (!mounted) return;
    final cores = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: cores.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar jogo' : 'Novo jogo'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _nomeController,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                maxLength: 80,
                decoration: const InputDecoration(
                  labelText: 'Nome *',
                  prefixIcon: Icon(Icons.videogame_asset_outlined),
                ),
                validator: (v) => _obrigatorio(v, 'o nome do jogo'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _categoria,
                decoration: const InputDecoration(
                  labelText: 'Categoria *',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: [
                  for (final c in categoriasJogo)
                    DropdownMenuItem(value: c, child: Text(c)),
                ],
                onChanged: (v) => setState(() => _categoria = v),
                validator: (v) => v == null ? 'Escolha uma categoria' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _plataformaController,
                textInputAction: TextInputAction.next,
                maxLength: 40,
                decoration: const InputDecoration(
                  labelText: 'Plataforma (opcional)',
                  hintText: 'PC, PlayStation 5, Switch…',
                  prefixIcon: Icon(Icons.devices_other),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descricaoController,
                textCapitalization: TextCapitalization.sentences,
                minLines: 3,
                maxLines: 6,
                maxLength: 500,
                decoration: const InputDecoration(
                  labelText: 'Descrição *',
                  alignLabelWithHint: true,
                ),
                validator: (v) => _obrigatorio(v, 'uma descrição'),
              ),
              const SizedBox(height: 16),
              Text('Status *', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<StatusJogo>(
                segments: [
                  for (final s in StatusJogo.values)
                    ButtonSegment(
                      value: s,
                      label: Text(s.rotulo),
                      icon: Icon(StatusBadge.icone(s)),
                    ),
                ],
                selected: {_status},
                showSelectedIcon: false,
                onSelectionChanged: (s) => setState(() => _status = s.first),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _salvando ? null : _salvar,
                icon: _salvando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_editando ? 'Salvar alterações' : 'Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
