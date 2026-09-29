import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/repositories/contador_prefs_repository.dart';
import 'domain/usecases/decrementar.dart';
import 'domain/usecases/incrementar.dart';
import 'domain/usecases/obtener_contador.dart';
import 'presentation/estado/contador_cubit.dart';
import 'presentation/pantallas/pantalla_visor.dart';

// Observer para imprimir los cambios de estado en consola
class SimpleBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    debugPrint('${bloc.runtimeType}: ${change.currentState} -> ${change.nextState}');
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Registra el observer global de Bloc
  Bloc.observer = SimpleBlocObserver();

  // main.dart es el único que conoce la implementación concreta de data
  final repository = ContadorPrefsRepository();
  final obtenerContador = ObtenerContador(repository);
  final incrementar = Incrementar(repository);
  final decrementar = Decrementar(repository);

  runApp(
    BlocProvider(
      create: (context) => ContadorCubit(
        obtenerContador: obtenerContador,
        incrementarUsecase: incrementar,
        decrementarUsecase: decrementar,
      ),
      child: const AppBloc(),
    ),
  );
}

class AppBloc extends StatelessWidget {
  const AppBloc({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contador - BLoC (Cubit)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const PantallaVisor(),
    );
  }
}
