import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../estado/contador_provider.dart';

class PantallaControl extends ConsumerWidget {
  const PantallaControl({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contador = ref.watch(contadorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pantalla 2 · Control (Riverpod)'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Valor actual en Control: $contador',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.read(contadorProvider.notifier).decrementar();
                    },
                    icon: const Icon(Icons.remove),
                    label: const Text('-1'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.read(contadorProvider.notifier).incrementar();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('+1'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              FilledButton.tonalIcon(
                onPressed: () {
                  Navigator.pop(context); // Pop normal sin devolver valores
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver al Visor'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
