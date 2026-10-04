import 'package:flutter/material.dart';
import 'package:dnd/service/dnd_service.dart';

class BuscaMagia extends StatefulWidget {
  const BuscaMagia({super.key});

  @override
  State<BuscaMagia> createState() => _BuscaMagiaState();
}

class _BuscaMagiaState extends State<BuscaMagia> {
  String? campo;
  String? resultado;
  final apiService = DndService();
  final TextEditingController _controller = TextEditingController();

  Future<Map<String, dynamic>?> _consultar() async {
    if (campo == null) return null;

    final texto = campo!.trim();

    // Validações de entrada do usuário
    if (texto.isEmpty) {
      throw Exception('Por favor, digite o nome de uma magia.');
    }
    if (texto.length < 2) {
      throw Exception('O termo de busca deve conter pelo menos 2 caracteres.');
    }
    if (RegExp(r'^\d+$').hasMatch(texto)) {
      throw Exception('O nome da magia não pode ser composto apenas por números.');
    }
    if (!RegExp(r"^[a-zA-ZÀ-ÿ0-9\s'\-]+$").hasMatch(texto)) {
      throw Exception('Caracteres inválidos detectados. Use apenas letras e espaços.');
    }

    return await apiService.buscaMagia(texto);
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
          "Busca de Magias",
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
                labelText: "Digite a magia (ex: fireball, shield, light)",
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
      final classesStr = (data['classes'] as List).map((c) => c['name']).join(', ');
      dados += "Classes: $classesStr\n";
    }

    // Descrição
    if (data['desc'] is List && (data['desc'] as List).isNotEmpty) {
      dados += "\n--- Descrição ---\n";
      dados += "${(data['desc'] as List).join('\n\n')}\n";
    }

    // Em Níveis Superiores
    if (data['higher_level'] is List && (data['higher_level'] as List).isNotEmpty) {
      dados += "\n--- Em Níveis Superiores ---\n";
      dados += "${(data['higher_level'] as List).join('\n\n')}\n";
    }

    // Outras opções encontradas
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
