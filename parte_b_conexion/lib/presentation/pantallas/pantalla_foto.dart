import 'package:flutter/material.dart';
import '../../domain/entities/estado_conexion.dart';
import '../../domain/usecases/consultar_conexion.dart';

class PantallaFoto extends StatefulWidget {
  final ConsultarConexion consultarConexion;

  const PantallaFoto({
    super.key,
    required this.consultarConexion,
  });

  @override
  State<PantallaFoto> createState() => _PantallaFotoState();
}

class _PantallaFotoState extends State<PantallaFoto> {
  EstadoConexion? _estado;
  String? _horaConsulta;
  bool _consultando = false;

  String _formatearHora(DateTime fecha) {
    final hh = fecha.hour.toString().padLeft(2, '0');
    final mm = fecha.minute.toString().padLeft(2, '0');
    final ss = fecha.second.toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }

  Future<void> _consultar() async {
    setState(() => _consultando = true);
    final resultado = await widget.consultarConexion();
    final hora = _formatearHora(DateTime.now());

    if (mounted) {
      setState(() {
        _estado = resultado;
        _horaConsulta = hora;
        _consultando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String textoEstado;
    final IconData icono;
    final Color color;

    switch (_estado) {
      case EstadoConexion.wifi:
        textoEstado = 'Wi-Fi';
        icono = Icons.wifi;
        color = Colors.green;
        break;
      case EstadoConexion.datosMoviles:
        textoEstado = 'Datos móviles';
        icono = Icons.signal_cellular_alt;
        color = Colors.green;
        break;
      case EstadoConexion.otro:
        textoEstado = 'Conectado (Otro)';
        icono = Icons.cable;
        color = Colors.green;
        break;
      case EstadoConexion.sinConexion:
        textoEstado = 'Sin conexión';
        icono = Icons.wifi_off;
        color = Colors.red;
        break;
      case null:
        textoEstado = 'Sin consultar aún';
        icono = Icons.help_outline;
        color = Colors.grey;
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icono,
                size: 80,
                color: color,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              textoEstado,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            if (_horaConsulta != null)
              Text(
                'Hora de la consulta: $_horaConsulta',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              )
            else
              const Text(
                'Presiona el botón para tomar la "foto"',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
            const SizedBox(height: 40),
            FilledButton.icon(
              onPressed: _consultando ? null : _consultar,
              icon: _consultando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.camera_alt),
              label: const Text('Consultar ahora'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
                backgroundColor: Colors.blueAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
