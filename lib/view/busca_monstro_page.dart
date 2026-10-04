import 'package:flutter/material.dart';
import 'package:dnd/service/dnd_service.dart';

class BuscaMonstro extends StatefulWidget {
  const BuscaMonstro({super.key});

  @override
  State<BuscaMonstro> createState() => _BuscaMonstroState();
}

class _BuscaMonstroState extends State<BuscaMonstro> {
  String? campo;
  String? resultado;
  final apiService = DndService();
  final TextEditingController _controller = TextEditingController();

  Future<Map<String, dynamic>?> _consultar() async {
    if (campo == null) return null;

    final texto = campo!.trim();

    // Validações de entrada do usuário
    if (texto.isEmpty) {
      throw Exception('Por favor, digite o nome de um monstro.');
    }
    if (texto.length < 2) {
      throw Exception('O termo de busca deve conter pelo menos 2 caracteres.');
    }
    if (RegExp(r'^\d+$').hasMatch(texto)) {
      throw Exception('O nome do monstro não pode ser composto apenas por números.');
    }
    if (!RegExp(r"^[a-zA-ZÀ-ÿ0-9\s'\-]+$").hasMatch(texto)) {
      throw Exception('Caracteres inválidos detectados. Use apenas letras e espaços.');
    }

    return await apiService.buscaMonstro(texto);
  }

  void _executarBusca() {
    setState(() {
      campo = _controller.text;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Busca de Monstros",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: "Digite o monstro (ex: goblin, dragon, skeleton)",
                labelStyle: const TextStyle(color: Colors.white),
                border: const OutlineInputBorder(),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 2.0),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: _executarBusca,
                ),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 18),
              onSubmitted: (value) {
                _executarBusca();
              },
            ),

            Expanded(
              child: FutureBuilder(
                future: _consultar(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const Padding(
                        padding: EdgeInsets.only(top: 20.0),
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 5.0,
                          ),
                        ),
                      );
                    case ConnectionState.none:
                      return Container();
                    default:
                      if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: Text(
                            snapshot.error.toString().replaceAll('Exception: ', ''),
                            style: const TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data == null) {
                        return Container();
                      } else {
                        return exibeResultado(context, snapshot);
                      }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget exibeResultado(BuildContext context, AsyncSnapshot snapshot) {
    final data = snapshot.data;
    if (data == null) return Container();

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
      final speedStr = speedMap.entries.map((e) => "${e.key}: ${e.value}").join(', ');
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
    dados += "Atributos: FOR: $str | DES: $dex | CON: $con | INT: $intl | SAB: $wis | CAR: $cha\n";

    // Idiomas
    dados += "Idiomas: ${data['languages'] ?? 'Nenhum'}\n";

    // Habilidades Especiais
    if (data['special_abilities'] is List && (data['special_abilities'] as List).isNotEmpty) {
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
    if (data['_outros_resultados'] is List && (data['_outros_resultados'] as List).isNotEmpty) {
      dados += "\nOutras opções encontradas:\n";
      for (var outro in data['_outros_resultados']) {
        dados += "- $outro\n";
      }
    }

    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: SingleChildScrollView(
        child: Text(
          dados,
          style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.4),
          softWrap: true,
        ),
      ),
    );
  }
}
