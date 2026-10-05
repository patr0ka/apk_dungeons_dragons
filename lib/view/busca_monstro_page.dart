import 'package:flutter/material.dart';

import 'busca_categoria_page.dart';
import 'resultado_formatters.dart';

class BuscaMonstro extends StatelessWidget {
  const BuscaMonstro({super.key});
  @override
  Widget build(BuildContext context) => BuscaCategoriaPage(
    titulo: 'Monstros',
    explicacao: 'Monstros são as criaturas que os aventureiros encontram. Consulte seus atributos, pontos de vida, habilidades e ações.',
    exemplos: 'goblin, esqueleto ou dragão vermelho',
    consultar: (service, termo) => service.buscaMonstro(termo),
    formatar: formataMonstro,
  );
}
