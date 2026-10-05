import 'package:flutter/material.dart';

/// Identidade visual compartilhada pela home e pelas quatro pesquisas.
class AppLogoTitle extends StatelessWidget {
  const AppLogoTitle({super.key, required this.titulo});
  final String titulo;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Image.asset(
        'assets/imgs/compendio.png',
        width: 44,
        height: 44,
        fit: BoxFit.contain,
        excludeFromSemantics: true,
      ),
      const SizedBox(width: 10),
      Flexible(
        child: Text(
          titulo,
          maxLines: 2,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    ],
  );
}
