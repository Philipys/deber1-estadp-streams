import 'package:flutter_test/flutter_test.dart';
import 'package:parte_b_conexion/domain/entities/estado_conexion.dart';
import 'package:parte_b_conexion/domain/repositories/conexion_repository.dart';
import 'package:parte_b_conexion/domain/usecases/consultar_conexion.dart';
import 'package:parte_b_conexion/domain/usecases/observar_conexion.dart';
import 'package:parte_b_conexion/main.dart';

class FakeConexionRepository implements ConexionRepository {
  @override
  Future<EstadoConexion> consultarAhora() async => EstadoConexion.wifi;

  @override
  Stream<EstadoConexion> observarCambios() => Stream.value(EstadoConexion.wifi);
}

void main() {
  testWidgets('Smoke test inicial de la app de conexion', (WidgetTester tester) async {
    final fakeRepo = FakeConexionRepository();
    await tester.pumpWidget(AppConexion(
      consultarConexion: ConsultarConexion(fakeRepo),
      observarConexion: ObservarConexion(fakeRepo),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Con Future'), findsWidgets);
  });
}
