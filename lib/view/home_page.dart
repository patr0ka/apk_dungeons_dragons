import 'package:flutter/material.dart';
import 'busca_monstro_page.dart';
import 'busca_magia_page.dart';
import 'busca_classe_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/imgs/logo.jpeg',
              fit: BoxFit.contain,
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                return const Text(
                  "D&D 5e Compêndio",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                );
              },
            ),
          ],
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            GestureDetector(
              child: const Row(
                children: [
                  Icon(Icons.pets, color: Colors.white, size: 50.0),
                  SizedBox(width: 30),
                  Text(
                    "Monstros",
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BuscaMonstro()),
                );
              },
            ),

            const SizedBox(height: 10),

            GestureDetector(
              child: const Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.white, size: 50.0),
                  SizedBox(width: 30),
                  Text(
                    "Magias",
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BuscaMagia()),
                );
              },
            ),

            const SizedBox(height: 10),

            GestureDetector(
              child: const Row(
                children: [
                  Icon(Icons.shield, color: Colors.white, size: 50.0),
                  SizedBox(width: 30),
                  Text(
                    "Classes",
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BuscaClasse()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
