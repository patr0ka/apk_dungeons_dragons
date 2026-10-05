String formataMonstro(Map<String, dynamic> data) {
  String dados = '';

  // Nome
  dados += "Nome: ${data['name'] ?? 'N/A'}\n";

  // Tipo / Raça
  String tipo = data['type'] ?? 'N/A';
  if (data['subtype'] != null && data['subtype'].toString().isNotEmpty) {
    tipo += " (${data['subtype']})";
  }
  dados += "Tipo / Raça: $tipo\n";

  // Tamanho e Alinhamento
  dados += "Tamanho: ${data['size'] ?? 'N/A'}\n";
  dados += "Alinhamento: ${data['alignment'] ?? 'N/A'}\n";

  // Pontos de Vida (HP)
  final hp = data['hit_points'] ?? 'N/A';
  final hd = data['hit_dice'] != null ? " (${data['hit_dice']})" : "";
  dados += "Pontos de Vida (HP): $hp$hd\n";

  // Classe de Armadura (CA)
  String acStr = 'N/A';
  if (data['armor_class'] is List && (data['armor_class'] as List).isNotEmpty) {
    final acItem = (data['armor_class'] as List).first;
    if (acItem is Map) {
      acStr = "${acItem['value'] ?? ''} (${acItem['type'] ?? 'padrão'})".trim();
    } else {
      acStr = acItem.toString();
    }
  } else if (data['armor_class'] != null) {
    acStr = data['armor_class'].toString();
  }
  dados += "Classe de Armadura (CA): $acStr\n";

  // Deslocamento (Speed)
  if (data['speed'] is Map) {
    final speedMap = data['speed'] as Map;
    final speedStr = speedMap.entries
        .map((e) => "${e.key}: ${e.value}")
        .join(', ');
    dados += "Deslocamento: $speedStr\n";
  }

  // Nível de Desafio (CR) e XP
  final cr = data['challenge_rating'] ?? 'N/A';
  final xp = data['xp'] != null ? " (${data['xp']} XP)" : "";
  dados += "Nível de Desafio (CR): $cr$xp\n";

  // Atributos
  final str = data['strength'] ?? '-';
  final dex = data['dexterity'] ?? '-';
  final con = data['constitution'] ?? '-';
  final intl = data['intelligence'] ?? '-';
  final wis = data['wisdom'] ?? '-';
  final cha = data['charisma'] ?? '-';
  dados +=
      "Atributos: FOR: $str | DES: $dex | CON: $con | INT: $intl | SAB: $wis | CAR: $cha\n";

  // Idiomas
  dados += "Idiomas: ${data['languages'] ?? 'Nenhum'}\n";

  // Habilidades Especiais
  if (data['special_abilities'] is List &&
      (data['special_abilities'] as List).isNotEmpty) {
    dados += "\n--- Habilidades Especiais ---\n";
    for (var hab in data['special_abilities']) {
      dados += "• ${hab['name']}: ${hab['desc']}\n";
    }
  }

  // Ações / Ataques
  if (data['actions'] is List && (data['actions'] as List).isNotEmpty) {
    dados += "\n--- Ações / Ataques ---\n";
    for (var acao in data['actions']) {
      dados += "• ${acao['name']}: ${acao['desc']}\n";
    }
  }

  // Outros monstros similares encontrados (se a busca foi ampla)
  if (data['_outros_resultados'] is List &&
      (data['_outros_resultados'] as List).isNotEmpty) {
    dados += "\nOutras opções encontradas:\n";
    for (var outro in data['_outros_resultados']) {
      dados += "- $outro\n";
    }
  }

  return dados;
}

String formataMagia(Map<String, dynamic> data) {
  String dados = '';

  // Nome
  dados += "Nome: ${data['name'] ?? 'N/A'}\n";

  // Nível / Círculo
  final level = data['level'];
  if (level == 0) {
    dados += "Nível: Truque (Cantrip)\n";
  } else {
    dados += "Nível: $levelº Círculo\n";
  }

  // Escola de Magia
  final school = data['school'] != null ? data['school']['name'] : 'N/A';
  dados += "Escola: $school\n";

  // Tempo de Conjuração
  dados += "Tempo de Conjuração: ${data['casting_time'] ?? 'N/A'}\n";

  // Alcance
  dados += "Alcance: ${data['range'] ?? 'N/A'}\n";

  // Componentes
  String comp = 'N/A';
  if (data['components'] is List) {
    comp = (data['components'] as List).join(', ');
  }
  if (data['material'] != null && data['material'].toString().isNotEmpty) {
    comp += " (${data['material']})";
  }
  dados += "Componentes: $comp\n";

  // Duração e Concentração
  String duracao = data['duration'] ?? 'N/A';
  if (data['concentration'] == true) {
    duracao += " (Requer Concentração)";
  }
  dados += "Duração: $duracao\n";

  // Ritual
  final ritual = data['ritual'] == true ? 'Sim' : 'Não';
  dados += "Ritual: $ritual\n";

  // Classes aptas
  if (data['classes'] is List) {
    final classesStr = (data['classes'] as List)
        .map((c) => c['name'])
        .join(', ');
    dados += "Classes: $classesStr\n";
  }

  // Descrição
  if (data['desc'] is List && (data['desc'] as List).isNotEmpty) {
    dados += "\n--- Descrição ---\n";
    dados += "${(data['desc'] as List).join('\n\n')}\n";
  }

  // Em Níveis Superiores
  if (data['higher_level'] is List &&
      (data['higher_level'] as List).isNotEmpty) {
    dados += "\n--- Em Níveis Superiores ---\n";
    dados += "${(data['higher_level'] as List).join('\n\n')}\n";
  }

  // Outras opções encontradas
  if (data['_outros_resultados'] is List &&
      (data['_outros_resultados'] as List).isNotEmpty) {
    dados += "\nOutras opções encontradas:\n";
    for (var outro in data['_outros_resultados']) {
      dados += "- $outro\n";
    }
  }

  return dados;
}

String formataClasse(Map<String, dynamic> data) {
  String dados = '';

  // Nome
  dados += "Classe: ${data['name'] ?? 'N/A'}\n";

  // Dado de Vida (Hit Die)
  dados += "Dado de Vida: d${data['hit_die'] ?? 'N/A'}\n";

  // Testes de Resistência / Salvaguardas (Saving Throws)
  if (data['saving_throws'] is List) {
    final stStr = (data['saving_throws'] as List)
        .map((s) => s['name'])
        .join(', ');
    dados += "Testes de Resistência: $stStr\n";
  }

  // Proficiências
  if (data['proficiencies'] is List &&
      (data['proficiencies'] as List).isNotEmpty) {
    final profStr = (data['proficiencies'] as List)
        .map((p) => p['name'])
        .join(', ');
    dados += "Proficiências: $profStr\n";
  }

  // Escolhas de Perícias
  if (data['proficiency_choices'] is List &&
      (data['proficiency_choices'] as List).isNotEmpty) {
    dados += "\n--- Escolha de Perícias ---\n";
    for (var choice in data['proficiency_choices']) {
      dados += "• ${choice['desc'] ?? ''}\n";
    }
  }

  // Habilidade de Conjuração
  if (data['spellcasting'] != null &&
      data['spellcasting']['spellcasting_ability'] != null) {
    final spellAbility =
        data['spellcasting']['spellcasting_ability']['name'] ?? 'N/A';
    dados += "\nHabilidade de Conjuração: $spellAbility\n";
  }

  // Subclasses
  if (data['subclasses'] is List && (data['subclasses'] as List).isNotEmpty) {
    final subStr = (data['subclasses'] as List)
        .map((s) => s['name'])
        .join(', ');
    dados += "\nSubclasses / Arquétipos: $subStr\n";
  }

  return dados;
}

String formataEquipamento(Map<String, dynamic> data) {
  final linhas = <String>['Nome: ${data['name']}'];
  void campo(String titulo, dynamic valor) {
    if (valor != null) linhas.add('$titulo: $valor');
  }

  campo('Categoria', data['equipment_category']?['name']);
  campo('Peso (lb)', data['weight']);
  if (data['cost'] is Map) {
    campo('Custo', "${data['cost']['quantity']} ${data['cost']['unit']}");
  }
  campo('Categoria da arma', data['weapon_category']);
  campo('Dano', data['damage']?['damage_dice']);
  campo('Tipo de dano', data['damage']?['damage_type']?['name']);
  campo('Classe de armadura base', data['armor_class']?['base']);
  campo('Força mínima', data['str_minimum']);
  if (data['properties'] is List) {
    campo(
      'Propriedades',
      (data['properties'] as List).map((e) => e['name']).join(', '),
    );
  }
  if (data['desc'] is List) {
    linhas.addAll((data['desc'] as List).map((e) => e.toString()));
  }
  if (data['_outros_resultados'] is List) {
    campo(
      'Outras opções encontradas',
      (data['_outros_resultados'] as List).join(', '),
    );
  }
  return linhas.join('\n');
}
