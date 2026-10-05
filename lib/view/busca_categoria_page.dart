import 'app_logo_title.dart';

import 'package:flutter/material.dart';

import '../service/dnd_service.dart';
import '../service/giphy_service.dart';
import '../service/busca_validator.dart';

typedef Consulta = Future<Map<String, dynamic>> Function(DndService, String);

class BuscaCategoriaPage extends StatefulWidget {
  const BuscaCategoriaPage({
    super.key,
    required this.titulo,
    required this.explicacao,
    required this.exemplos,
    required this.consultar,
    required this.formatar,
    this.dndService,
    this.giphyService,
  });
  final String titulo, explicacao, exemplos;
  final Consulta consultar;
  final String Function(Map<String, dynamic>) formatar;
  final DndService? dndService;
  final GiphyService? giphyService;

  @override
  State<BuscaCategoriaPage> createState() => _BuscaCategoriaPageState();
}

class _BuscaCategoriaPageState extends State<BuscaCategoriaPage> {
  final _controller = TextEditingController();
  final _form = GlobalKey<FormState>();
  late final _dnd = widget.dndService ?? DndService();
  late final _giphy = widget.giphyService ?? GiphyService();
  Future<Map<String, dynamic>>? _consulta;
  Future<String?>? _gif;
  bool _buscando = false;

  void _pesquisar() {
    if (_buscando || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _buscando = true;
      _gif = null;
      _consulta = _carregar(_controller.text.trim());
    });
  }

  Future<Map<String, dynamic>> _carregar(String termo) async {
    try {
      final dados = await widget.consultar(_dnd, termo);
      if (mounted) {
        // O Future é criado apenas na pesquisa, nunca durante o build.
        // A falha do GIF fica isolada do resultado principal.
        final gif = _giphy.buscarGif(dados['name'] as String);
        // Registra imediatamente um handler, mesmo antes do próximo frame.
        gif.ignore();
        setState(() {
          _gif = gif;
        });
      }
      return dados;
    } finally {
      if (mounted) setState(() => _buscando = false);
    }
  }

  void _explicar() => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Sobre ${widget.titulo}'),
      content: SingleChildScrollView(child: Text(widget.explicacao)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Entendi'),
        ),
      ],
    ),
  );

  @override
  void dispose() {
    _controller.dispose();
    if (widget.dndService == null) _dnd.dispose();
    if (widget.giphyService == null) _giphy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      title: AppLogoTitle(titulo: 'Busca de ${widget.titulo}'),
      centerTitle: true,
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OutlinedButton.icon(
              onPressed: _explicar,
              icon: const Icon(Icons.info_outline),
              label: Text('O que são ${widget.titulo.toLowerCase()}?'),
            ),
            const SizedBox(height: 16),
            Form(
              key: _form,
              child: TextFormField(
                controller: _controller,
                validator: validaBusca,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  labelText: 'Nome para pesquisar',
                  border: OutlineInputBorder(),
                  errorMaxLines: 3,
                ),
                onFieldSubmitted: (_) => _pesquisar(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Exemplos: ${widget.exemplos}.\nNomes em inglês e alguns nomes em português são aceitos.',
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _buscando ? null : _pesquisar,
              icon: const Icon(Icons.search),
              label: Text(_buscando ? 'Pesquisando…' : 'Pesquisar'),
            ),
            const SizedBox(height: 20),
            FutureBuilder<Map<String, dynamic>>(
              future: _consulta,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.none) {
                  return const Text(
                    'Pesquise um elemento para consultar o compêndio.',
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) return Text(_mensagem(snapshot.error));
                if (!snapshot.hasData) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SelectableText(
                      widget.formatar(snapshot.data!),
                      style: const TextStyle(fontSize: 18, height: 1.4),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'GIF relacionado a ${snapshot.data!['name']}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<String?>(
                      future: _gif,
                      builder: (context, gif) {
                        if (gif.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (gif.hasError) return Text(_mensagem(gif.error));
                        if (gif.data == null) {
                          return const Text(
                            'Nenhum GIF relacionado encontrado.',
                          );
                        }
                        return Image.network(
                          gif.data!,
                          height: 220,
                          fit: BoxFit.contain,
                          semanticLabel:
                              'GIF relacionado a ${snapshot.data!['name']}',
                          loadingBuilder: (context, child, progress) =>
                              progress == null
                              ? child
                              : const SizedBox(
                                  height: 220,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                          errorBuilder: (_, error, stack) => const Text(
                            'Não foi possível carregar o GIF. Tente pesquisar novamente.',
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    const Text('Powered by GIPHY • Imagem ilustrativa'),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    ),
  );

  String _mensagem(Object? erro) =>
      erro.toString().replaceFirst('Exception: ', '');
}
