import '../repositories/contador_repository.dart';

class Incrementar {
  final ContadorRepository _repository;

  Incrementar(this._repository);

  Future<int> call() async {
    final actual = await _repository.leer();
    final nuevo = actual + 1;
    await _repository.guardar(nuevo);
    return nuevo;
  }
}
