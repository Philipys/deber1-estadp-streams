import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parte_a_contador/domain/repositories/contador_repository.dart';
import 'package:parte_a_contador/domain/usecases/decrementar.dart';
import 'package:parte_a_contador/domain/usecases/incrementar.dart';
import 'package:parte_a_contador/domain/usecases/obtener_contador.dart';
import 'package:parte_a_contador/presentation/estado/contador_cubit.dart';
import 'package:parte_a_contador/main.dart';

class FakeContadorRepository implements ContadorRepository {
  int valor = 0;
  @override
  Future<int> leer() async => valor;
  @override
  Future<void> guardar(int nuevoValor) async => valor = nuevoValor;
}

void main() {
  testWidgets('Smoke test inicial de la app Cubit', (WidgetTester tester) async {
    final repo = FakeContadorRepository();
    await tester.pumpWidget(
      BlocProvider(
        create: (context) => ContadorCubit(
          obtenerContador: ObtenerContador(repo),
          incrementarUsecase: Incrementar(repo),
          decrementarUsecase: Decrementar(repo),
        ),
        child: const AppBloc(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Contador:'), findsOneWidget);
  });
}
