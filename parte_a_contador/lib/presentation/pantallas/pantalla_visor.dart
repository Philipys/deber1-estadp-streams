import 'package:flutter/material.dart';
import '../../domain/usecases/decrementar.dart';
import '../../domain/usecases/incrementar.dart';
import '../../domain/usecases/obtener_contador.dart';
import 'pantalla_control.dart';

class PantallaVisor extends StatefulWidget {
  final ObtenerContador obtenerContador;
  final Incrementar incrementar;
  final Decrementar decrementar;

  const PantallaVisor({
    super.key,
    required this.obtenerContador,
    required this.incrementar,
    required this.decrementar,
  });

  @override
  State<PantallaVisor> createState() => _PantallaVisorState();
}

class _PantallaVisorState extends State<PantallaVisor> {
  int _contador = 0;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarContador();
  }

  Future<void> _cargarContador() async {
    final valor = await widget.obtenerContador();
    if (mounted) {
      setState(() {
        _contador = valor;
        _cargando = false;
      });
    }
  }

  Future<void> _irAControl() async {
    final valorRetornado = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaControl(
          valorInicial: _contador,
          incrementar: widget.incrementar,
          decrementar: widget.decrementar,
        ),
      ),
    );

    // Si vuelve con el botón de la app, valorRetornado trae el nuevo entero.
    // Si vuelve con el botón atrás del sistema (Android), valorRetornado es null.
    if (valorRetornado != null && mounted) {
      setState(() {
        _contador = valorRetornado;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pantalla 1 · Visor (setState)'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_cargando)
                const CircularProgressIndicator()
              else ...[
                const Text(
                  'Contador:',
                  style: TextStyle(fontSize: 24, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                Text(
                  '$_contador',
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ],
              const SizedBox(height: 48),
              FilledButton.icon(
                onPressed: _cargando ? null : _irAControl,
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
