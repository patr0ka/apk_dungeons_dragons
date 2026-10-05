import 'api_client.dart';
import 'busca_validator.dart';

import 'package:http/http.dart' as http;

class DndService {
  DndService({http.Client? client}) : _api = ApiClient(client: client);
  final ApiClient _api;
  void dispose() => _api.close();

  // Dicionário de tradução/apelidos para Monstros (Português -> Inglês)
  static final Map<String, String> _monstrosAliases = {
    'dragao': 'dragon',
    'dragão': 'dragon',
    'dragao negro': 'adult black dragon',
    'dragão negro': 'adult black dragon',
    'dragao azul': 'adult blue dragon',
    'dragão azul': 'adult blue dragon',
    'dragao vermelho': 'adult red dragon',
    'dragão vermelho': 'adult red dragon',
    'dragao branco': 'adult white dragon',
    'dragão branco': 'adult white dragon',
    'dragao verde': 'adult green dragon',
    'dragão verde': 'adult green dragon',
    'dragao de ouro': 'adult gold dragon',
    'dragão de ouro': 'adult gold dragon',
    'esqueleto': 'skeleton',
    'zumbi': 'zombie',
    'vampiro': 'vampire',
    'lobo': 'wolf',
    'lobo atroz': 'dire wolf',
    'urso': 'bear',
    'urso coruja': 'owlbear',
    'aranha': 'spider',
    'aranha gigante': 'giant spider',
    'fantasma': 'ghost',
    'quimera': 'chimera',
    'minotauro': 'minotaur',
    'medusa': 'medusa',
    'hidra': 'hydra',
    'tarrasque': 'tarrasque',
    'beholder': 'beholder',
    'observador': 'beholder',
    'lich': 'lich',
    'diabo': 'devil',
    'demonio': 'demon',
    'demônio': 'demon',
    'espectro': 'specter',
    'basilisco': 'basilisk',
    'mumia': 'mummy',
    'múmia': 'mummy',
    'ogro': 'ogre',
    'orc': 'orc',
    'troll': 'troll',
  };

  // Dicionário de tradução/apelidos para Magias (Português -> Inglês)
  static final Map<String, String> _magiasAliases = {
    'bola de fogo': 'fireball',
    'misseis magicos': 'magic missile',
    'mísseis mágicos': 'magic missile',
    'curar ferimentos': 'cure wounds',
    'cura': 'cure wounds',
    'escudo': 'shield',
    'escudo arcano': 'shield',
    'invisibilidade': 'invisibility',
    'onda de trovao': 'thunderwave',
    'onda de trovão': 'thunderwave',
    'trovao': 'thunderwave',
    'trovão': 'thunderwave',
    'raio de gelo': 'ray of frost',
    'sono': 'sleep',
    'voar': 'fly',
    'luz': 'light',
    'bencao': 'bless',
    'bênção': 'bless',
    'relampago': 'lightning bolt',
    'relâmpago': 'lightning bolt',
    'velocidade': 'haste',
    'teleporte': 'teleport',
    'identificacao': 'identify',
    'identificação': 'identify',
    'detectar magia': 'detect magic',
    'visao no escuro': 'darkvision',
    'visão no escuro': 'darkvision',
    'teia': 'web',
    'passo nebuloso': 'misty step',
    'contramagica': 'counterspell',
    'contra magica': 'counterspell',
    'contramágica': 'counterspell',
    'contra-magica': 'counterspell',
    'contra-mágica': 'counterspell',
    'arma espiritual': 'spiritual weapon',
    'curar': 'cure wounds',
  };

  // Dicionário de tradução/apelidos para Classes (Português -> Inglês)
  static final Map<String, String> _classesAliases = {
    'mago': 'wizard',
    'guerreiro': 'fighter',
    'ladino': 'rogue',
    'ladrao': 'rogue',
    'ladrão': 'rogue',
    'clerigo': 'cleric',
    'clérigo': 'cleric',
    'bardo': 'bard',
    'barbaro': 'barbarian',
    'bárbaro': 'barbarian',
    'druida': 'druid',
    'monge': 'monk',
    'paladino': 'paladin',
    'patrulheiro': 'ranger',
    'ranger': 'ranger',
    'feiticeiro': 'sorcerer',
    'bruxo': 'warlock',
  };

  Future<Map<String, dynamic>> buscaMonstro(String? valor) =>
      _buscar('monsters', valor, _monstrosAliases);
  Future<Map<String, dynamic>> buscaMagia(String? valor) =>
      _buscar('spells', valor, _magiasAliases);
  Future<Map<String, dynamic>> buscaClasse(String? valor) =>
      _buscar('classes', valor, _classesAliases);
  Future<Map<String, dynamic>> buscaEquipamento(String? valor) =>
      _buscar('equipment', valor, const {
        'espada': 'longsword',
        'espada longa': 'longsword',
        'adaga': 'dagger',
        'escudo': 'shield',
        'arco longo': 'longbow',
        'armadura de placas': 'plate',
        'machado': 'battleaxe',
        'corda': 'rope',
        'tocha': 'torch',
        'mochila': 'backpack',
      });

  Future<Map<String, dynamic>> _buscar(
    String categoria,
    String? valor,
    Map<String, String> aliases,
  ) async {
    final erro = validaBusca(valor);
    if (erro != null) throw Exception(erro);
    final normalizado = valor!.trim().toLowerCase().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
    final busca = aliases[normalizado] ?? normalizado;
    final listagem = await _api.get(
      Uri.https('www.dnd5eapi.co', '/api/2014/$categoria', {'name': busca}),
      'D&D',
    );
    final results = listagem['results'];
    if (results is! List) {
      throw Exception('A API D&D retornou uma resposta inválida.');
    }
    if (results.isEmpty) {
      throw Exception(
        'Nenhum resultado para "$valor". Tente o nome em inglês ou um dos exemplos.',
      );
    }
    final itens = results.whereType<Map>().toList();
    if (itens.isEmpty) {
      throw Exception('A API D&D retornou uma resposta inválida.');
    }
    final escolhido = itens.firstWhere(
      (item) => item['name'].toString().toLowerCase() == busca,
      orElse: () => itens.first,
    );
    final index = escolhido['index'];
    if (index is! String || !RegExp(r'^[a-z0-9-]+$').hasMatch(index)) {
      throw Exception('A API D&D retornou um identificador inválido.');
    }
    final detalhe = await _api.get(
      Uri.https('www.dnd5eapi.co', '/api/2014/$categoria/$index'),
      'D&D',
    );
    if (detalhe['name'] is! String) {
      throw Exception('A API D&D retornou uma resposta inválida.');
    }
    detalhe['_outros_resultados'] = itens
        .where((e) => e['index'] != index)
        .take(5)
        .map((e) => e['name'])
        .toList();
    return detalhe;
  }
}
