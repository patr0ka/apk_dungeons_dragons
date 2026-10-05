import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  Future<Map<String, dynamic>> get(Uri uri, String fonte) async {
    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Acesso ao $fonte recusado. Verifique a chave da API.');
      }
      if (response.statusCode == 429) {
        throw Exception(
          'Limite de consultas do $fonte atingido. Tente novamente mais tarde.',
        );
      }
      if (response.statusCode == 404) {
        throw Exception('Resultado não encontrado no $fonte.');
      }
      if (response.statusCode != 200) {
        throw Exception(
          '$fonte indisponível (erro ${response.statusCode}). Tente novamente.',
        );
      }
      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic>) throw const FormatException();
      return data;
    } on TimeoutException {
      throw Exception('$fonte demorou para responder. Tente novamente.');
    } on http.ClientException {
      throw Exception('Falha de conexão com $fonte. Verifique sua internet.');
    } on FormatException {
      throw Exception('$fonte retornou uma resposta inválida.');
    }
  }

  void close() => _client.close();
}
