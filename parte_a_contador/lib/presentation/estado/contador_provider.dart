import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/contador_prefs_repository.dart';
import '../../domain/repositories/contador_repository.dart';
import '../../domain/usecases/decrementar.dart';
import '../../domain/usecases/incrementar.dart';
import '../../domain/usecases/obtener_contador.dart';

// Providers de repositorio y casos de uso
final contadorRepositoryProvider = Provider<ContadorRepository>((ref) {
  return ContadorPrefsRepository();
});

final obtenerContadorProvider = Provider<ObtenerContador>((ref) {
  final repo = ref.watch(contadorRepositoryProvider);
  return ObtenerContador(repo);
});

final incrementarProvider = Provider<Incrementar>((ref) {
  final repo = ref.watch(contadorRepositoryProvider);
  return Incrementar(repo);
});

final decrementarProvider = Provider<Decrementar>((ref) {
  final repo = ref.watch(contadorRepositoryProvider);
  return Decrementar(repo);
});

// Notifier de estado para el contador
class ContadorNotifier extends Notifier<int> {
  @override
  int build() {
    _cargarInicial();
    return 0;
  }

  Future<void> _cargarInicial() async {
    final obtener = ref.read(obtenerContadorProvider);
    state = await obtener();
  }

  Future<void> cargar() async {
    final obtener = ref.read(obtenerContadorProvider);
    state = await obtener();
  }

  Future<void> incrementar() async {
    final inc = ref.read(incrementarProvider);
    state = await inc();
  }

  Future<void> decrementar() async {
    final dec = ref.read(decrementarProvider);
    state = await dec();
  }
}

final contadorProvider = NotifierProvider<ContadorNotifier, int>(
  ContadorNotifier.new,
);
