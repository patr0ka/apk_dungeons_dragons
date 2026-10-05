import 'package:flutter/material.dart';

import 'busca_categoria_page.dart';
import 'resultado_formatters.dart';

class BuscaEquipamento extends StatelessWidget {
  const BuscaEquipamento({super.key});
  @override
  Widget build(BuildContext context) => BuscaCategoriaPage(
    titulo: 'Equipamentos',
    explicacao: 'Equipamentos são as armas, armaduras e objetos usados nas aventuras. Consulte características como custo, peso e dano.',
    exemplos: 'espada longa, adaga ou mochila',
    consultar: (service, termo) => service.buscaEquipamento(termo),
    formatar: formataEquipamento,
  );
}
