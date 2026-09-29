import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../estado/contador_cubit.dart';

class PantallaControl extends StatelessWidget {
  const PantallaControl({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pantalla 2 · Control (Cubit)'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BlocBuilder<ContadorCubit, int>(
                builder: (context, contador) {
                  return Text(
                    'Valor actual en Control: $contador',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  );
                },
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<ContadorCubit>().decrementar();
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
                      context.read<ContadorCubit>().incrementar();
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
