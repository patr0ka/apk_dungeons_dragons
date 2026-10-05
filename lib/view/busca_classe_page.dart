import 'package:flutter/material.dart';

import 'busca_categoria_page.dart';
import 'resultado_formatters.dart';

class BuscaClasse extends StatelessWidget {
  const BuscaClasse({super.key});
  @override
  Widget build(BuildContext context) => BuscaCategoriaPage(
    titulo: 'Classes',
    explicacao: 'Classes definem a especialidade de um personagem, como mago, guerreiro ou ladino. Elas determinam pontos de vida, proficiências e habilidades.',
    exemplos: 'mago, guerreiro ou bardo',
    consultar: (service, termo) => service.buscaClasse(termo),
    formatar: formataClasse,
  );
}
