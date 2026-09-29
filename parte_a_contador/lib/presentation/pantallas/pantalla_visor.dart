import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../estado/contador_provider.dart';
import 'pantalla_control.dart';

class PantallaVisor extends ConsumerWidget {
  const PantallaVisor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contador = ref.watch(contadorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pantalla 1 · Visor (Riverpod)'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Contador:',
                style: TextStyle(fontSize: 24, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Text(
                '$contador',
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 48),
              FilledButton.icon(
                onPressed: () {
                  // Navegación normal sin pasar datos ni esperar retorno
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PantallaControl(),
                    ),
                  );
                },
                icon: const Icon(Icons.tune),
                label: const Text('Ir a Control'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
