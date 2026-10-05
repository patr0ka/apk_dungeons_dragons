import 'package:flutter/material.dart';

import 'busca_categoria_page.dart';
import 'resultado_formatters.dart';

class BuscaMagia extends StatelessWidget {
  const BuscaMagia({super.key});
  @override
  Widget build(BuildContext context) => BuscaCategoriaPage(
    titulo: 'Magias',
    explicacao: 'Magias são efeitos sobrenaturais conjurados pelos personagens. Cada uma possui nível, alcance, componentes, duração e regras próprias.',
    exemplos: 'bola de fogo, escudo ou magic missile',
    consultar: (service, termo) => service.buscaMagia(termo),
    formatar: formataMagia,
  );
}
