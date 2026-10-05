import 'package:http/http.dart' as http;

import 'api_client.dart';

class GiphyService {
  GiphyService({http.Client? client, String? apiKey})
    : _api = ApiClient(client: client),
      _key = "wrngTv4WsNEQLCyMXwioqbxLgj9hBgJ5";
  final ApiClient _api;
  final String _key;

  Future<String?> buscarGif(String nome) async {
    if (_key.trim().isEmpty) {
      throw Exception(
        'GIF indisponível: a chave do Giphy não foi configurada.',
      );
    }
    final resposta = await _api.get(
      Uri.https('api.giphy.com', '/v1/gifs/search', {
        'api_key': _key,
        'q': '$nome dnd ilustration',
        'limit': '1',
        'offset': '0',
        'rating': 'g',
        'lang': 'en',
      }),
      'Giphy',
    );
    final dados = resposta['data'];
    if (dados is! List) {
      throw Exception('O Giphy retornou uma resposta inválida.');
    }
    if (dados.isEmpty) return null;
    final item = dados.first;
    if (item is! Map || item['images'] is! Map) {
      throw Exception('O Giphy retornou uma resposta inválida.');
    }
    final imagem = item['images']['fixed_height'];
    final url = imagem is Map ? imagem['url'] : null;
    final uri = url is String ? Uri.tryParse(url) : null;
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      throw Exception('O Giphy retornou uma imagem inválida.');
    }
    return url as String;
  }

  void dispose() => _api.close();
}
