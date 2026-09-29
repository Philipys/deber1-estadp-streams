# Deber 1 — Respuestas y Análisis

**Programación Asistida de Aplicaciones — USFQ**  
**Estudiante:** Felipe  
**Materia:** Manejo de estado y uso de streams en Flutter  

---

## PARTE A · La misma app, tres veces

### Pregunta 1 (A.2 · Versión setState)
> *¿Qué pasó en el paso 3 y por qué? Ojo: el valor sí se guardó en disco. ¿Qué es exactamente lo que quedó desactualizado? Y para que el contador viajara entre las dos pantallas, ¿cuántos lugares del código tuvieron que ponerse de acuerdo?*

**Respuesta:**

1. **Qué pasó y por qué:**  
   Al presionar el botón atrás nativo del sistema operativo (Android back gesture/button), la `PantallaVisor` siguió mostrando el valor anterior, sin reflejar los incrementos realizados en la `PantallaControl`.  
   Esto sucedió porque la pantalla visor dependía exclusivamente del valor retornado por la promesa de navegación (`final nuevoValor = await Navigator.push<int>(...)`). Cuando el usuario usa el botón atrás del sistema operativo, Flutter realiza un `Navigator.pop(context)` sin argumentos (retorna `null`). Como `nuevoValor` fue `null`, la instrucción de actualización `setState(() => _contador = nuevoValor)` nunca llegó a ejecutarse.

2. **Qué quedó exactamente desactualizado:**  
   El valor en disco (`shared_preferences`) **sí** se guardó correctamente gracias al caso de uso `Incrementar`. Lo que quedó desactualizado fue únicamente la **variable de estado en memoria del widget** (`_PantallaVisorState._contador`), produciendo una inconsistencia visual donde la UI mentía respecto al dato persistido.

3. **Lugares del código que tuvieron que ponerse de acuerdo (4 lugares):**
   - **`PantallaVisor._irAControl()`:** Debe enviar el valor actual como argumento por el constructor al navegar (`PantallaControl(valorInicial: _contador, ...)`).
   - **`PantallaControl` (Constructor y State):** Debe declarar el parámetro obligatorio `final int valorInicial`, recibirlo y asignarlo a su variable de estado local `_contador` en `initState`.
   - **`PantallaControl` (Botón Volver):** Debe invocar explícitamente `Navigator.pop(context, _contador)` pasando el entero resultante.
   - **`PantallaVisor` (Retorno de navegación):** Debe esperar la respuesta (`await Navigator.push<int>(...)`) y llamar a `setState()` con el dato recibido.

---

### Pregunta 2 (A.3 · Versión Riverpod)
> *¿Por qué ahora el botón atrás del sistema no rompe nada? ¿Dónde vive el contador?*

**Respuesta:**

1. **Dónde vive el contador:**  
   El contador ya no vive en el `State` de ningún widget efímero ni se transporta como parámetro entre rutas. Vive fuera del árbol de widgets, en un `ContadorNotifier` centralizado gestionado por `ProviderScope` a través del provider `contadorProvider`.

2. **Por qué el botón atrás no rompe nada:**  
   Ambas pantallas (`PantallaVisor` y `PantallaControl`) están suscritas al mismo provider. Cuando en `PantallaControl` se presiona `+1`, se llama a `ref.read(contadorProvider.notifier).incrementar()`, mutando el estado global del provider.  
   Al presionar el botón atrás del sistema, `PantallaControl` simplemente se destruye de la pila de navegación; pero al reenfocar `PantallaVisor`, esta ya cuenta con el valor actualizado porque está observando reactivamente el provider con `ref.watch(contadorProvider)`. La navegación vuelve a ser desacoplada (un simple `push`/`pop` sin contratos de retorno).

---

### Pregunta 3 (A.4 · Versión BLoC / Cubit)
> *¿Qué te permite ver el `BlocObserver` que las otras dos versiones no te daban? ¿En qué situación real sería útil ese registro?*

**Respuesta:**

1. **Qué permite ver el `BlocObserver`:**  
   Permite registrar y observar de manera centralizada e inequívoca cada cambio de estado, transición y error en cualquier Cubit/Bloc de la aplicación. En la consola se imprime en vivo el ciclo de transiciones con el formato:
   ```text
   ContadorCubit: 0 -> 1
   ContadorCubit: 1 -> 2
   ContadorCubit: 2 -> 3
   ```
   A diferencia de `setState` (cuyos cambios son mutaciones locales mudas dentro de un widget) o `Riverpod` (que requiere un `ProviderObserver` explícito y no modela transiciones de estado inmutables de forma nativa), Cubit genera un historial formal de cada evento de negocio.

2. **Situaciones reales donde es indispensable:**
   - **Trazabilidad en transacciones críticas:** En flujos bancarios, carritos de compra o autenticación, permite auditar la secuencia cronológica exacta de estados antes de que se produzca una falla.
   - **Integración con telemetría de producción (Crashlytics / Sentry / Datadog):** Permite adjuntar como "breadcrumbs" el historial de las últimas 20 transiciones de estado previas a un crash en el dispositivo del cliente.
   - **Detección de condiciones de carrera y re-renderizados innecesarios:** Facilita detectar si un endpoint asíncrono está emitiendo estados duplicados o fuera de orden.

---

### Pregunta 4 (A.5 · La prueba de la arquitectura)
> *Pega la salida de los tres comandos en `RESPUESTAS.md`. ¿Qué demuestra que los dos primeros salgan vacíos y el tercero no? Si mañana tuvieras que cambiar Riverpod por otro paquete, ¿qué parte del proyecto tendrías que volver a escribir?*

#### 1. Salida de los comandos Git:

```bash
$ git diff version/setstate version/riverpod -- lib/domain lib/data
# (Salida vacía: 0 líneas de diferencia)
```

```bash
$ git diff version/setstate version/bloc -- lib/domain lib/data
# (Salida vacía: 0 líneas de diferencia)
```

```bash
$ git diff version/setstate version/bloc --stat -- lib/presentation
 lib/presentation/estado/contador_cubit.dart      |  33 +++++++
 lib/presentation/pantallas/pantalla_control.dart |  73 +++++----------
 lib/presentation/pantallas/pantalla_visor.dart   | 110 +++++++----------------
 3 files changed, 84 insertions(+), 132 deletions(-)
```

#### 2. Qué demuestra este resultado:
Demuestra el principio de **inversión de dependencias y separación de responsabilidades de la Arquitectura Limpia**:
- Las reglas de negocio (`domain`) y el almacenamiento persistente (`data`) son completamente agnósticos respecto a quién los muestra y cómo se gestiona el estado en la interfaz de usuario.
- El administrador de estado es simplemente un **detalle de implementación de la capa de presentación**, totalmente intercambiable y descartable.

#### 3. Qué parte habría que volver a escribir si se cambia el paquete:
Únicamente la capa **`lib/presentation/`** y la inyección inicial en **`lib/main.dart`**. El 100% de la lógica de casos de uso (`domain/`) y los repositorios (`data/`) se conservan sin modificar ni una sola línea de código.

---

### Pregunta 5 (A.6 · Comparación final de administradores de estado)

#### Tabla comparativa:

| Criterio | `setState` | `Riverpod` | `Cubit` |
|---|---|---|---|
| **¿Dónde vive el contador?** | En el `State` de `PantallaVisor` y `PantallaControl` (local y duplicado) | Fuera del árbol, en un `ContadorNotifier` dentro de `ProviderScope` | En la instancia de `ContadorCubit` provista por `BlocProvider` |
| **¿Las pantallas se pasan datos?** | **Sí** (por constructor y como retorno de `Navigator.pop`) | **No** (consumen el mismo provider de forma independiente) | **No** (leen y escuchan el mismo `ContadorCubit` del árbol) |
| **Archivos de `presentation/` que se crearon** | `pantalla_visor.dart`, `pantalla_control.dart` | `contador_provider.dart`, `pantalla_visor.dart`, `pantalla_control.dart` | `contador_cubit.dart`, `pantalla_visor.dart`, `pantalla_control.dart` |
| **¿Qué pasa con el botón atrás del sistema?** | **Se rompe la sincronización** (retorna `null` y la UI queda desactualizada) | **Mantiene la sincronización** (la UI lee el estado global automáticamente) | **Mantiene la sincronización** (el `BlocBuilder` reconstruye con el estado real) |
| **¿Tuviste que tocar `domain/`?** | **No** | **No** | **No** |

#### Análisis y elección:
- **Si la app tuviera una sola pantalla:**  
  Elegiría **`setState`**. No existe prop-drilling ni necesidad de compartir datos con otras vistas; introducir un gestor externo para una pantalla individual simple agrega complejidad accidental innecesaria.
- **Si tuviera ocho pantallas compartiendo cinco datos distintos:**  
  Elegiría **`Riverpod`** o **`Cubit`**. Riverpod permite componer y derivar proveedores con mínima fricción sin anidar providers; Cubit brinda inmutabilidad estricta y trazabilidad con su observer para flujos empresariales robustos.
- **Cuándo `setState` SÍ es la opción correcta (en 2 líneas):**  
  `setState` es la opción correcta para el **estado efímero y estrictamente local de un widget** (como la visibilidad de una contraseña, animaciones, pestañas seleccionadas o abrir un menú desplegable), donde ninguna otra pantalla o capa de la app necesita conocer dicho dato.

---

## PARTE B · Future vs Stream

### Pregunta 6 (B.2 · Versión Future)
> *¿Por qué la pantalla siguió mostrando "Wi-Fi" si el Wi-Fi ya estaba apagado? ¿La app tenía un dato incorrecto, o tenía un dato correcto de un momento equivocado?*

**Respuesta:**

1. **Por qué siguió mostrando "Wi-Fi":**  
   Porque un `Future` representa un valor asíncrono que se resuelve **una única vez y se cierra**. Cuando se presionó el botón "Consultar ahora", el `Future` capturó la foto instantánea de la conexión en ese preciso segundo. Una vez resuelto, el `Future` no mantiene ninguna escucha ni canal abierto con el sistema operativo; por ende, al apagar el Wi-Fi, la interfaz continuó mostrando la foto estática capturada anteriormente.

2. **Dato incorrecto vs dato correcto de un momento equivocado:**  
   La app **tenía un dato correcto de un momento equivocado**. En el instante `14:08:15` en que se ejecutó la consulta, el dispositivo efectivamente tenía Wi-Fi activo. La información era 100% verídica para ese momento del pasado, pero se volvió obsoleta ante los cambios continuos del entorno físico.

---

### Pregunta 7 (B.3 · Versión Stream con Cubit)
> *¿Qué pasaría si borras el `cancel()` del `close()` del Cubit y el usuario entra y sale de esa pantalla cincuenta veces?*

**Respuesta:**

1. **Fuga de memoria (Memory Leak):**  
   Cada vez que el usuario ingresa a la pestaña o pantalla con Stream, se instancia un nuevo `ConexionCubit` que abre una suscripción (`StreamSubscription`) con el `EventChannel` de la plataforma (`connectivity_plus`). Si no se cancela en `close()`, las 50 suscripciones quedan vivas y retenidas en memoria por el motor de Flutter/Android.
2. **Excepciones en ejecución (`StateError`):**  
   La próxima vez que la conexión cambie (ej. al alternar el modo avión), las 50 suscripciones intentarán emitir simultáneamente sobre Cubits que el recolector de basura o el árbol de widgets ya cerró, provocando una avalancha de excepciones:
   ```text
   StateError (Bad state: Cannot emit new states after calling close)
   ```
3. **Degradación de rendimiento:**  
   El consumo de CPU y memoria aumentará de forma acumulativa hasta ralentizar la app o provocar que el sistema operativo la cierre por falta de recursos (Crash OOM).

---

### Pregunta 8 (B.3 · Síntesis Future vs Stream)
> *Con lo que viste: ¿por qué decimos que un `Future` es una foto y un `Stream` una película? Explícalo con la conexión, no con la definición del libro. Cierra nombrando **dos datos** de una app real que pedirías con `Future` y **dos** que observarías con `Stream`.*

**Respuesta:**

1. **Explicación con la conexión:**  
   - El **`Future` es una foto** porque toma una captura estática de la red en un instante puntual. Si tomas una foto de un carro en movimiento, la foto siempre mostrará el carro quieto en ese metro de la calle, sin importar si 5 segundos después el carro ya dobló la esquina. En la app, pulsar "Consultar" congela el estado de la conexión en ese segundo; si sales al pasillo y pierdes la señal, la foto sigue diciendo "Wi-Fi" hasta que manualmente decidas tomar otra foto.
   - El **`Stream` es una película** porque no congela nada: es un flujo continuo de fotogramas en vivo a lo largo del tiempo. La app mantiene la cámara encendida hacia el sistema operativo: en el instante exacto en que entras al ascensor, el Stream emite "Sin conexión", y al salir al parque emite "Datos móviles", actualizando la pantalla sola sin intervención del usuario.

2. **Dos datos de una app real con `Future`:**
   - **Autenticación / Login (`POST /api/auth/login`):** Se envía el usuario y la contraseña una sola vez y se espera una única respuesta con el token de acceso o el error.
   - **Carga de términos y condiciones o detalles de un producto (`GET /productos/45`):** Se solicita la información estática del producto una vez al abrir su detalle.

3. **Dos datos de una app real con `Stream`:**
   - **Ubicación GPS de un conductor en Uber o delivery:** La posición de latitud/longitud cambia constantemente a medida que el vehículo se desplaza y el mapa debe reflejar el movimiento en tiempo real.
   - **Mensajería instantánea en un chat (WhatsApp/Telegram o WebSockets/Firebase):** El usuario no tiene que presionar un botón "actualizar mensajes"; los nuevos mensajes entrantes fluyen por el Stream y aparecen en pantalla de forma instantánea.
