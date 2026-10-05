import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:dnd/service/api_client.dart';
import 'package:dnd/service/dnd_service.dart';
import 'package:dnd/service/giphy_service.dart';
import 'package:dnd/service/busca_validator.dart';

void main() {
  for (final entrada in ['', '   ', 'a', '123', '---', '🔥', 'a' * 81]) {
    test(
      'Rejeita entrada inválida: $entrada',
      () => expect(validaBusca(entrada), isNotNull),
    );
  }
  test('Aceita português e apóstrofo', () {
    expect(validaBusca('  mísseis mágicos  '), isNull);
    expect(validaBusca("Melf's acid arrow"), isNull);
  });
  test('Traduz termo e prioriza correspondência exata', () async {
    final uris = <Uri>[];
    final service = DndService(
      client: MockClient((request) async {
        uris.add(request.url);
        return http.Response(
          jsonEncode(
            uris.length == 1
                ? {
                    'results': [
                      {'index': 'other', 'name': 'Other'},
                      {'index': 'fireball', 'name': 'Fireball'},
                    ],
                  }
                : {'name': 'Fireball', 'level': 3},
          ),
          200,
        );
      }),
    );
    addTearDown(service.dispose);
    final result = await service.buscaMagia('  bola   de fogo ');
    expect(uris.first.queryParameters['name'], 'fireball');
    expect(uris.last.path, '/api/2014/spells/fireball');
    expect(result['level'], 3);
    expect(result['_outros_resultados'], ['Other']);
  });
  test('Quatro categorias consultam seus endpoints', () async {
    final paths = <String>[];
    final service = DndService(
      client: MockClient((r) async {
        paths.add(r.url.path);
        return http.Response(
          jsonEncode(
            r.url.hasQuery
                ? {
                    'results': [
                      {'index': 'item', 'name': 'Item'},
                    ],
                  }
                : {'name': 'Item'},
          ),
          200,
        );
      }),
    );
    addTearDown(service.dispose);
    await service.buscaMonstro('goblin');
    await service.buscaMagia('fireball');
    await service.buscaClasse('mago');
    await service.buscaEquipamento('espada');
    for (final category in ['monsters', 'spells', 'classes', 'equipment']) {
      expect(paths, contains('/api/2014/$category/item'));
    }
  });
  test('Entrada vazia não faz requisição', () async {
    final service = DndService(
      client: MockClient((r) async => throw StateError('Não deve consultar')),
    );
    addTearDown(service.dispose);
    await expectLater(service.buscaMagia(' '), throwsException);
  });
  test('Busca sem resultados informa ausência', () async {
    final service = DndService(
      client: MockClient((r) async => http.Response('{"results":[]}', 200)),
    );
    addTearDown(service.dispose);
    await expectLater(
      service.buscaMagia('desconhecida'),
      throwsA(predicate((e) => e.toString().contains('Nenhum resultado'))),
    );
  });
  for (final status in [401, 403, 404, 429, 500]) {
    test('Trata HTTP $status', () async {
      final api = ApiClient(
        client: MockClient((r) async => http.Response('{}', status)),
      );
      addTearDown(api.close);
      await expectLater(
        api.get(Uri.https('example.com'), 'Teste'),
        throwsException,
      );
    });
  }
  for (final body in ['invalid', '[]']) {
    test('Trata JSON inválido $body', () async {
      final api = ApiClient(
        client: MockClient((r) async => http.Response(body, 200)),
      );
      addTearDown(api.close);
      await expectLater(
        api.get(Uri.https('example.com'), 'Teste'),
        throwsException,
      );
    });
  }
  for (final error in [
    http.ClientException('offline'),
    TimeoutException('lento'),
  ]) {
    test('Trata falha de rede ${error.runtimeType}', () async {
      final api = ApiClient(client: MockClient((r) async => throw error));
      addTearDown(api.close);
      await expectLater(
        api.get(Uri.https('example.com'), 'Teste'),
        throwsException,
      );
    });
  }
  test('Giphy usa nome encontrado e retorna URL animada', () async {
    final service = GiphyService(
      apiKey: 'test',
      client: MockClient((r) async {
        expect(r.url.queryParameters['q'], 'Fireball fantasy');
        expect(r.url.queryParameters['rating'], 'g');
        return http.Response(
          '{"data":[{"images":{"fixed_height":{"url":"https://media.giphy.com/fireball.gif"}}}]}',
          200,
        );
      }),
    );
    addTearDown(service.dispose);
    expect(await service.buscarGif('Fireball'), endsWith('fireball.gif'));
  });
  test('Giphy vazio e chave ausente têm tratamento', () async {
    final empty = GiphyService(
      apiKey: 'test',
      client: MockClient((r) async => http.Response('{"data":[]}', 200)),
    );
    final missing = GiphyService(apiKey: '');
    addTearDown(empty.dispose);
    addTearDown(missing.dispose);
    expect(await empty.buscarGif('Fireball'), isNull);
    await expectLater(missing.buscarGif('Fireball'), throwsException);
  });
}
