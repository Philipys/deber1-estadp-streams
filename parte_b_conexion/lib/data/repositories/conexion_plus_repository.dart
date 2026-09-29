import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/entities/estado_conexion.dart';
import '../../domain/repositories/conexion_repository.dart';

class ConexionPlusRepository implements ConexionRepository {
  final Connectivity _connectivity;

  ConexionPlusRepository({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  EstadoConexion _mapearResultado(List<ConnectivityResult> resultados) {
    if (resultados.contains(ConnectivityResult.wifi)) {
      return EstadoConexion.wifi;
    } else if (resultados.contains(ConnectivityResult.mobile)) {
      return EstadoConexion.datosMoviles;
    } else if (resultados.contains(ConnectivityResult.ethernet) ||
        resultados.contains(ConnectivityResult.vpn) ||
        resultados.contains(ConnectivityResult.bluetooth) ||
        resultados.contains(ConnectivityResult.other)) {
      return EstadoConexion.otro;
    } else {
      return EstadoConexion.sinConexion;
    }
  }

  @override
  Future<EstadoConexion> consultarAhora() async {
    final resultados = await _connectivity.checkConnectivity();
    return _mapearResultado(resultados);
  }

  @override
  Stream<EstadoConexion> observarCambios() {
    return _connectivity.onConnectivityChanged.map(_mapearResultado);
  }
}
