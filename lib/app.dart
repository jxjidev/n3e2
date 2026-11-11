import 'package:flutter/material.dart';

import 'pages/colecao_page.dart';

class MinhaColecaoApp extends StatelessWidget {
  const MinhaColecaoApp({super.key});

  @override
  Widget build(BuildContext context) {
    const semente = Color(0xFF2E7D6B);

    return MaterialApp(
      title: 'Minha Coleção',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: semente,
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: semente,
        brightness: Brightness.dark,
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const ColecaoPage(),
    );
  }
}
