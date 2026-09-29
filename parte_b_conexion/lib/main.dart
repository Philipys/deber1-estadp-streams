import 'package:flutter/material.dart';
import 'data/repositories/conexion_plus_repository.dart';
import 'domain/usecases/consultar_conexion.dart';
import 'domain/usecases/observar_conexion.dart';
import 'presentation/pantallas/pantalla_foto.dart';
import 'presentation/pantallas/pantalla_stream.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // main.dart es el ÚNICO archivo que conoce ConexionPlusRepository
  final repository = ConexionPlusRepository();
  final consultarConexion = ConsultarConexion(repository);
  final observarConexion = ObservarConexion(repository);

  runApp(AppConexion(
    consultarConexion: consultarConexion,
    observarConexion: observarConexion,
  ));
}

class AppConexion extends StatelessWidget {
  final ConsultarConexion consultarConexion;
  final ObservarConexion observarConexion;

  const AppConexion({
    super.key,
    required this.consultarConexion,
    required this.observarConexion,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conexión: Future vs Stream',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blueAccent,
        useMaterial3: true,
      ),
      home: _PantallaPrincipal(
        consultarConexion: consultarConexion,
        observarConexion: observarConexion,
      ),
    );
  }
}

class _PantallaPrincipal extends StatefulWidget {
  final ConsultarConexion consultarConexion;
  final ObservarConexion observarConexion;

  const _PantallaPrincipal({
    required this.consultarConexion,
    required this.observarConexion,
  });

  @override
  State<_PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<_PantallaPrincipal> {
  int _indiceActual = 0;

  @override
  Widget build(BuildContext context) {
    final paginas = [
      PantallaFoto(consultarConexion: widget.consultarConexion),
      PantallaStream(
        consultarConexion: widget.consultarConexion,
        observarConexion: widget.observarConexion,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_indiceActual == 0 ? 'Con Future (Foto fija)' : 'Con Stream (En vivo)'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: paginas[_indiceActual],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceActual,
        onTap: (index) {
          setState(() {
            _indiceActual = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Con Future',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sensors),
            label: 'Con Stream',
          ),
        ],
      ),
    );
  }
}
