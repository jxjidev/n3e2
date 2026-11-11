import 'dart:async';

import 'package:flutter/material.dart';

import '../models/jogo.dart';
import '../services/jogo_repository.dart';
import '../widgets/estado_mensagem.dart';
import '../widgets/jogo_card.dart';
import 'jogo_form_page.dart';

class ColecaoPage extends StatefulWidget {
  const ColecaoPage({super.key, this.repository});

  final JogoRepository? repository;

  @override
  State<ColecaoPage> createState() => _ColecaoPageState();
}

class _ColecaoPageState extends State<ColecaoPage> {
  late final JogoRepository _repo = widget.repository ?? JogoRepository();
  final _buscaController = TextEditingController();
  Timer? _atrasoBusca;

  List<Jogo> _jogos = [];
  Map<StatusJogo, int> _contagem = {};
  bool _carregando = true;
  String? _erro;

  StatusJogo? _status;
  String? _categoria;
  OrdemJogos _ordem = OrdemJogos.maisRecentes;

  bool get _temFiltro =>
      _buscaController.text.trim().isNotEmpty ||
      _status != null ||
      _categoria != null;

  int get _total => _contagem.values.fold(0, (a, b) => a + b);

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _atrasoBusca?.cancel();
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final resultados = await Future.wait([
        _repo.listar(
          busca: _buscaController.text,
          status: _status,
          categoria: _categoria,
          ordem: _ordem,
        ),
        _repo.contarPorStatus(),
      ]);
      if (!mounted) return;
      setState(() {
        _jogos = resultados[0] as List<Jogo>;
        _contagem = resultados[1] as Map<StatusJogo, int>;
      });
    } on RepositorioException catch (e) {
      if (!mounted) return;
      setState(() => _erro = e.mensagem);
    } catch (_) {
      if (!mounted) return;
      setState(() => _erro = 'Erro inesperado ao acessar o banco local.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _aoDigitarBusca(String _) {
    setState(() {});
    _atrasoBusca?.cancel();
    _atrasoBusca = Timer(const Duration(milliseconds: 300), _carregar);
  }

  void _limparFiltros() {
    _buscaController.clear();
    setState(() {
      _status = null;
      _categoria = null;
    });
    _carregar();
  }

  Future<void> _abrirFormulario([Jogo? jogo]) async {
    final salvou = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => JogoFormPage(jogo: jogo, repository: _repo),
      ),
    );
    if (salvou == true) {
      _mostrarMensagem(jogo == null ? 'Jogo cadastrado' : 'Alterações salvas');
      await _carregar();
    }
  }

  Future<void> _confirmarExclusao(Jogo jogo) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.delete_outline),
        title: const Text('Excluir jogo?'),
        content: Text(
          '"${jogo.nome}" será removido da sua coleção. '
          'Essa ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmou != true) return;

    try {
      await _repo.excluir(jogo.id!);
      _mostrarMensagem('"${jogo.nome}" excluído');
      await _carregar();
    } on RepositorioException catch (e) {
      _mostrarMensagem(e.mensagem, erro: true);
    }
  }

  void _mostrarMensagem(String texto, {bool erro = false}) {
    if (!mounted) return;
    final cores = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(texto),
          backgroundColor: erro ? cores.error : null,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Coleção'),
        actions: [
          PopupMenuButton<OrdemJogos>(
            tooltip: 'Ordenar',
            icon: const Icon(Icons.sort),
            initialValue: _ordem,
            onSelected: (ordem) {
              setState(() => _ordem = ordem);
              _carregar();
            },
            itemBuilder: (context) => [
              for (final ordem in OrdemJogos.values)
                CheckedPopupMenuItem(
                  value: ordem,
                  checked: ordem == _ordem,
                  child: Text(ordem.rotulo),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFiltros(),
          if (_carregando && _jogos.isNotEmpty)
            const LinearProgressIndicator(minHeight: 2),
          Expanded(child: _buildConteudo()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Novo jogo'),
      ),
    );
  }

  Widget _buildFiltros() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _buscaController,
            onChanged: _aoDigitarBusca,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Pesquisar por nome',
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              suffixIcon: _buscaController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Limpar pesquisa',
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _buscaController.clear();
                        _aoDigitarBusca('');
                      },
                    ),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: Text('Todos ($_total)'),
                  selected: _status == null,
                  onSelected: (_) {
                    setState(() => _status = null);
                    _carregar();
                  },
                ),
                for (final status in StatusJogo.values) ...[
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text('${status.rotulo} (${_contagem[status] ?? 0})'),
                    selected: _status == status,
                    onSelected: (selecionado) {
                      setState(() => _status = selecionado ? status : null);
                      _carregar();
                    },
                  ),
                ],
                const SizedBox(width: 8),
                _buildFiltroCategoria(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltroCategoria() {
    return PopupMenuButton<String>(
      tooltip: 'Filtrar por categoria',
      onSelected: (valor) {
        setState(() => _categoria = valor.isEmpty ? null : valor);
        _carregar();
      },
      itemBuilder: (context) => [
        CheckedPopupMenuItem(
          value: '',
          checked: _categoria == null,
          child: const Text('Todas as categorias'),
        ),
        for (final categoria in categoriasJogo)
          CheckedPopupMenuItem(
            value: categoria,
            checked: categoria == _categoria,
            child: Text(categoria),
          ),
      ],
      child: IgnorePointer(
        child: FilterChip(
          avatar: const Icon(Icons.category_outlined, size: 18),
          label: Text(_categoria ?? 'Categoria'),
          selected: _categoria != null,
          onSelected: (_) {},
        ),
      ),
    );
  }

  Widget _buildConteudo() {
    if (_carregando && _jogos.isEmpty && _erro == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_erro != null) {
      return EstadoMensagem(
        icone: Icons.error_outline,
        titulo: 'Algo deu errado',
        mensagem: _erro!,
        textoBotao: 'Tentar novamente',
        onBotao: _carregar,
      );
    }

    if (_jogos.isEmpty) {
      return _temFiltro
          ? EstadoMensagem(
              icone: Icons.search_off,
              titulo: 'Nenhum jogo encontrado',
              mensagem: 'Nenhum jogo corresponde à pesquisa ou aos filtros.',
              textoBotao: 'Limpar filtros',
              onBotao: _limparFiltros,
            )
          : const EstadoMensagem(
              icone: Icons.videogame_asset_outlined,
              titulo: 'Sua coleção está vazia',
              mensagem: 'Toque em "Novo jogo" para cadastrar o primeiro.',
            );
    }

    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
        itemCount: _jogos.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final jogo = _jogos[index];
          return JogoCard(
            jogo: jogo,
            onEditar: () => _abrirFormulario(jogo),
            onExcluir: () => _confirmarExclusao(jogo),
          );
        },
      ),
    );
  }
}
