import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/estado_conexion.dart';
import '../../domain/usecases/consultar_conexion.dart';
import '../../domain/usecases/observar_conexion.dart';
import '../estado/conexion_cubit.dart';

class PantallaStream extends StatelessWidget {
  final ConsultarConexion consultarConexion;
  final ObservarConexion observarConexion;

  const PantallaStream({
    super.key,
    required this.consultarConexion,
    required this.observarConexion,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ConexionCubit(
        consultarConexion: consultarConexion,
        observarConexion: observarConexion,
      )..iniciar(),
      child: const _VistaStream(),
    );
  }
}

class _VistaStream extends StatefulWidget {
  const _VistaStream();

  @override
  State<_VistaStream> createState() => _VistaStreamState();
}

class _VistaStreamState extends State<_VistaStream> {
  int _contadorCambios = 0;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ConexionCubit, EstadoConexion>(
      listener: (context, state) {
        setState(() {
          _contadorCambios++;
        });
      },
      builder: (context, estado) {
        final String textoEstado;
        final IconData icono;
        final Color color;

        switch (estado) {
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
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.sync, size: 18, color: Colors.blueGrey),
                      const SizedBox(width: 8),
                      Text(
                        'Cambios detectados: $_contadorCambios',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'El estado cambia automáticamente en tiempo real (Stream)',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
