import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/pantallas/pantalla_visor.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: AppRiverpod(),
    ),
  );
}

class AppRiverpod extends StatelessWidget {
  const AppRiverpod({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contador - Riverpod',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      home: const PantallaVisor(),
    );
  }
}
