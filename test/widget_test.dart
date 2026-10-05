import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dnd/main.dart';
import 'package:dnd/view/busca_categoria_page.dart';
import 'package:dnd/service/giphy_service.dart';

void main() {
  testWidgets('Quatro botões abrem telas e pop-ups', (tester) async {
    await tester.pumpWidget(const DndApp());
    expect(find.byType(GridView), findsOneWidget);
    for (final category in ['Monstros', 'Magias', 'Classes', 'Equipamentos']) {
      await tester.tap(find.text(category));
      await tester.pumpAndSettle();
      expect(find.text('Busca de $category'), findsOneWidget);
      await tester.tap(find.text('O que são ${category.toLowerCase()}?'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('Entendi'));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
  });
  testWidgets('Valida, impede duplicação e preserva dados sem chave Giphy', (
    tester,
  ) async {
    var requests = 0;
    final pending = Completer<Map<String, dynamic>>();
    final giphy = GiphyService(apiKey: '');
    addTearDown(giphy.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: BuscaCategoriaPage(
          titulo: 'Magias',
          explicacao: 'Explicação',
          exemplos: 'fireball',
          giphyService: giphy,
          consultar: (_, termo) {
            requests++;
            return pending.future;
          },
          formatar: (data) => 'Magia: ${data['name']}',
        ),
      ),
    );
    await tester.tap(find.text('Pesquisar'));
    await tester.pump();
    expect(find.text('Digite um nome para pesquisar.'), findsOneWidget);
    expect(requests, 0);
    await tester.enterText(find.byType(TextFormField), 'fireball');
    await tester.tap(find.text('Pesquisar'));
    await tester.pump();
    expect(requests, 1);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    pending.complete({'name': 'Fireball'});
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is SelectableText && widget.data == 'Magia: Fireball',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('chave do Giphy'), findsOneWidget);
    await tester.tap(find.text('O que são magias?'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Entendi'));
    await tester.pumpAndSettle();
    expect(requests, 1);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Resposta após sair não atualiza tela descartada', (
    tester,
  ) async {
    final pending = Completer<Map<String, dynamic>>();
    await tester.pumpWidget(
      MaterialApp(
        home: BuscaCategoriaPage(
          titulo: 'Magias',
          explicacao: 'Explicação',
          exemplos: 'fireball',
          consultar: (_, termo) => pending.future,
          formatar: (_) => 'resultado',
        ),
      ),
    );
    await tester.enterText(find.byType(TextFormField), 'fireball');
    await tester.tap(find.text('Pesquisar'));
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    pending.complete({'name': 'Fireball'});
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
  testWidgets('Tela pequena permite rolagem', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const DndApp());
    await tester.tap(find.text('Equipamentos'));
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
