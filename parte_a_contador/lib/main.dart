import 'package:flutter/material.dart';
import 'data/repositories/contador_prefs_repository.dart';
import 'domain/usecases/decrementar.dart';
import 'domain/usecases/incrementar.dart';
import 'domain/usecases/obtener_contador.dart';
import 'presentation/pantallas/pantalla_visor.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // main.dart es el único lugar que instancia la implementación concreta
  final contadorRepository = ContadorPrefsRepository();

  final obtenerContador = ObtenerContador(contadorRepository);
  final incrementar = Incrementar(contadorRepository);
  final decrementar = Decrementar(contadorRepository);

  runApp(AppSetState(
    obtenerContador: obtenerContador,
    incrementar: incrementar,
    decrementar: decrementar,
  ));
}

class AppSetState extends StatelessWidget {
  final ObtenerContador obtenerContador;
  final Incrementar incrementar;
  final Decrementar decrementar;

  const AppSetState({
    super.key,
    required this.obtenerContador,
    required this.incrementar,
    required this.decrementar,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contador - setState',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: PantallaVisor(
        obtenerContador: obtenerContador,
        incrementar: incrementar,
        decrementar: decrementar,
      ),
    );
  }
}
