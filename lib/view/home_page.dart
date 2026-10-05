import 'app_logo_title.dart';

import 'package:flutter/material.dart';

import 'busca_monstro_page.dart';
import 'busca_magia_page.dart';
import 'busca_classe_page.dart';
import 'busca_equipamento_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const categorias = [
      ('Monstros', Icons.pets, BuscaMonstro()),
      ('Magias', Icons.auto_awesome, BuscaMagia()),
      ('Classes', Icons.shield, BuscaClasse()),
      ('Equipamentos', Icons.backpack, BuscaEquipamento()),
    ];
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const AppLogoTitle(titulo: 'D&D 5e Compêndio'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: GridView.count(
          padding: const EdgeInsets.all(16),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          mainAxisExtent: 180,
          children: categorias
              .map(
                (categoria) => OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(8),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(builder: (_) => categoria.$3),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(categoria.$2, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        categoria.$1,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
