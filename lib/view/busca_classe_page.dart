import 'package:flutter/material.dart';
import 'package:dnd/service/dnd_service.dart';

class BuscaClasse extends StatefulWidget {
  const BuscaClasse({super.key});

  @override
  State<BuscaClasse> createState() => _BuscaClasseState();
}

class _BuscaClasseState extends State<BuscaClasse> {
  String? campo;
  String? resultado;
  final apiService = DndService();
  final TextEditingController _controller = TextEditingController();

  Future<Map<String, dynamic>?> _consultar() async {
    if (campo == null) return null;

    final texto = campo!.trim();

    // Validações de entrada do usuário
    if (texto.isEmpty) {
      throw Exception('Por favor, digite o nome de uma classe.');
    }
    if (texto.length < 2) {
      throw Exception('O termo de busca deve conter pelo menos 2 caracteres.');
    }
    if (RegExp(r'^\d+$').hasMatch(texto)) {
      throw Exception('O nome da classe não pode ser composto apenas por números.');
    }
    if (!RegExp(r"^[a-zA-ZÀ-ÿ0-9\s'\-]+$").hasMatch(texto)) {
      throw Exception('Caracteres inválidos detectados. Use apenas letras e espaços.');
    }

    return await apiService.buscaClasse(texto);
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
          "Busca de Classes",
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
                labelText: "Digite a classe (ex: wizard, fighter, rogue)",
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
    dados += "Classe: ${data['name'] ?? 'N/A'}\n";

    // Dado de Vida (Hit Die)
    dados += "Dado de Vida: d${data['hit_die'] ?? 'N/A'}\n";

    // Testes de Resistência / Salvaguardas (Saving Throws)
    if (data['saving_throws'] is List) {
      final stStr = (data['saving_throws'] as List).map((s) => s['name']).join(', ');
      dados += "Testes de Resistência: $stStr\n";
    }

    // Proficiências
    if (data['proficiencies'] is List && (data['proficiencies'] as List).isNotEmpty) {
      final profStr = (data['proficiencies'] as List).map((p) => p['name']).join(', ');
      dados += "Proficiências: $profStr\n";
    }

    // Escolhas de Perícias
    if (data['proficiency_choices'] is List && (data['proficiency_choices'] as List).isNotEmpty) {
      dados += "\n--- Escolha de Perícias ---\n";
      for (var choice in data['proficiency_choices']) {
        dados += "• ${choice['desc'] ?? ''}\n";
      }
    }

    // Habilidade de Conjuração
    if (data['spellcasting'] != null && data['spellcasting']['spellcasting_ability'] != null) {
      final spellAbility = data['spellcasting']['spellcasting_ability']['name'] ?? 'N/A';
      dados += "\nHabilidade de Conjuração: $spellAbility\n";
    }

    // Subclasses
    if (data['subclasses'] is List && (data['subclasses'] as List).isNotEmpty) {
      final subStr = (data['subclasses'] as List).map((s) => s['name']).join(', ');
      dados += "\nSubclasses / Arquétipos: $subStr\n";
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
