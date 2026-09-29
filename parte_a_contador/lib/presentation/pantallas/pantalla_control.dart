import 'package:flutter/material.dart';
import '../../domain/usecases/decrementar.dart';
import '../../domain/usecases/incrementar.dart';

class PantallaControl extends StatefulWidget {
  final int valorInicial;
  final Incrementar incrementar;
  final Decrementar decrementar;

  const PantallaControl({
    super.key,
    required this.valorInicial,
    required this.incrementar,
    required this.decrementar,
  });

  @override
  State<PantallaControl> createState() => _PantallaControlState();
}

class _PantallaControlState extends State<PantallaControl> {
  late int _contador;
  bool _procesando = false;

  @override
  void initState() {
    super.initState();
    _contador = widget.valorInicial;
  }

  Future<void> _handleIncrementar() async {
    setState(() => _procesando = true);
    final nuevo = await widget.incrementar();
    setState(() {
      _contador = nuevo;
      _procesando = false;
    });
  }

  Future<void> _handleDecrementar() async {
    setState(() => _procesando = true);
    final nuevo = await widget.decrementar();
    setState(() {
      _contador = nuevo;
      _procesando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pantalla 2 · Control (setState)'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Valor actual en Control: $_contador',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _procesando ? null : _handleDecrementar,
                    icon: const Icon(Icons.remove),
                    label: const Text('-1'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 24),
                  ElevatedButton.icon(
                    onPressed: _procesando ? null : _handleIncrementar,
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
                  Navigator.pop(context, _contador);
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
