import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class DndService {
  final String _baseUrl = "https://www.dnd5eapi.co/api/2014";

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

  // Busca detalhes de um monstro na D&D 5e API
  Future<Map<String, dynamic>> buscaMonstro(String? valor) async {
    if (valor == null || valor.trim().isEmpty) {
      throw Exception('Por favor, digite o nome de um monstro.');
    }

    String busca = valor.trim().toLowerCase();
    if (_monstrosAliases.containsKey(busca)) {
      busca = _monstrosAliases[busca]!;
    }

    try {
      // 1. Tentar busca por parâmetro name
      final searchUri = Uri.parse("$_baseUrl/monsters?name=${Uri.encodeQueryComponent(busca)}");
      final searchResponse = await http.get(searchUri);

      if (searchResponse.statusCode == 200) {
        final searchData = json.decode(searchResponse.body);
        final int count = searchData['count'] ?? 0;
        final List results = searchData['results'] ?? [];

        if (count > 0 && results.isNotEmpty) {
          var escolhido = results.firstWhere(
            (item) => item['name'].toString().toLowerCase() == busca,
            orElse: () => results.first,
          );

          final detailUri = Uri.parse("https://www.dnd5eapi.co${escolhido['url']}");
          final detailResponse = await http.get(detailUri);

          if (detailResponse.statusCode == 200) {
            final detailData = Map<String, dynamic>.from(json.decode(detailResponse.body));
            if (results.length > 1) {
              detailData['_outros_resultados'] = results
                  .take(6)
                  .map((e) => e['name'].toString())
                  .where((name) => name != detailData['name'])
                  .toList();
            }
            return detailData;
          }
        }
      }

      // 2. Fallback: tentar busca direta por slug / índice
      final slug = busca.replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-|-$'), '');
      final slugUri = Uri.parse("$_baseUrl/monsters/$slug");
      final slugResponse = await http.get(slugUri);

      if (slugResponse.statusCode == 200) {
        return Map<String, dynamic>.from(json.decode(slugResponse.body));
      }

      throw Exception('Monstro "$valor" não encontrado. Tente termos como: goblin, dragon, skeleton, zombie, beholder.');
    } on SocketException {
      throw Exception('Erro de conexão com a internet');
    } catch (e) {
      rethrow;
    }
  }

  // Busca detalhes de uma magia na D&D 5e API
  Future<Map<String, dynamic>> buscaMagia(String? valor) async {
    if (valor == null || valor.trim().isEmpty) {
      throw Exception('Por favor, digite o nome de uma magia.');
    }

    String busca = valor.trim().toLowerCase();
    if (_magiasAliases.containsKey(busca)) {
      busca = _magiasAliases[busca]!;
    }

    try {
      // 1. Tentar busca por parâmetro name
      final searchUri = Uri.parse("$_baseUrl/spells?name=${Uri.encodeQueryComponent(busca)}");
      final searchResponse = await http.get(searchUri);

      if (searchResponse.statusCode == 200) {
        final searchData = json.decode(searchResponse.body);
        final int count = searchData['count'] ?? 0;
        final List results = searchData['results'] ?? [];

        if (count > 0 && results.isNotEmpty) {
          var escolhido = results.firstWhere(
            (item) => item['name'].toString().toLowerCase() == busca,
            orElse: () => results.first,
          );

          final detailUri = Uri.parse("https://www.dnd5eapi.co${escolhido['url']}");
          final detailResponse = await http.get(detailUri);

          if (detailResponse.statusCode == 200) {
            final detailData = Map<String, dynamic>.from(json.decode(detailResponse.body));
            if (results.length > 1) {
              detailData['_outros_resultados'] = results
                  .take(6)
                  .map((e) => e['name'].toString())
                  .where((name) => name != detailData['name'])
                  .toList();
            }
            return detailData;
          }
        }
      }

      // 2. Fallback: tentar busca direta por slug / índice
      final slug = busca.replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-|-$'), '');
      final slugUri = Uri.parse("$_baseUrl/spells/$slug");
      final slugResponse = await http.get(slugUri);

      if (slugResponse.statusCode == 200) {
        return Map<String, dynamic>.from(json.decode(slugResponse.body));
      }

      throw Exception('Magia "$valor" não encontrada. Tente termos como: fireball, magic missile, shield, cure wounds.');
    } on SocketException {
      throw Exception('Erro de conexão com a internet');
    } catch (e) {
      rethrow;
    }
  }

  // Busca detalhes de uma classe na D&D 5e API
  Future<Map<String, dynamic>> buscaClasse(String? valor) async {
    if (valor == null || valor.trim().isEmpty) {
      throw Exception('Por favor, digite o nome de uma classe.');
    }

    String busca = valor.trim().toLowerCase();
    if (_classesAliases.containsKey(busca)) {
      busca = _classesAliases[busca]!;
    }

    try {
      // 1. Tentar busca por parâmetro name
      final searchUri = Uri.parse("$_baseUrl/classes?name=${Uri.encodeQueryComponent(busca)}");
      final searchResponse = await http.get(searchUri);

      if (searchResponse.statusCode == 200) {
        final searchData = json.decode(searchResponse.body);
        final int count = searchData['count'] ?? 0;
        final List results = searchData['results'] ?? [];

        if (count > 0 && results.isNotEmpty) {
          var escolhido = results.firstWhere(
            (item) => item['name'].toString().toLowerCase() == busca,
            orElse: () => results.first,
          );

          final detailUri = Uri.parse("https://www.dnd5eapi.co${escolhido['url']}");
          final detailResponse = await http.get(detailUri);

          if (detailResponse.statusCode == 200) {
            return Map<String, dynamic>.from(json.decode(detailResponse.body));
          }
        }
      }

      // 2. Fallback: tentar busca direta por slug / índice
      final slug = busca.replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-|-$'), '');
      final slugUri = Uri.parse("$_baseUrl/classes/$slug");
      final slugResponse = await http.get(slugUri);

      if (slugResponse.statusCode == 200) {
        return Map<String, dynamic>.from(json.decode(slugResponse.body));
      }

      throw Exception('Classe "$valor" não encontrada. Tente: wizard, fighter, rogue, cleric, barbarian, paladin, etc.');
    } on SocketException {
      throw Exception('Erro de conexão com a internet');
    } catch (e) {
      rethrow;
    }
  }
}
