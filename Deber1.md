# Deber 1 — Manejo de estado y uso de streams en Flutter

**Programación Asistida de Aplicaciones — USFQ**

## De qué se trata

Este deber tiene dos partes que responden dos preguntas distintas:

| Parte | Pregunta |
|---|---|
| **A** | ¿Qué gana un administrador de estado que `setState` no puede darme? |
| **B** | ¿Por qué un `Stream` es mejor que un `Future` cuando el dato **no deja de cambiar**? |

En la Parte A construyes **la misma app tres veces**: con `setState`, con **Riverpod** y con
**BLoC (Cubit)**. En la Parte B construyes un detector de conexión —Wi-Fi, datos móviles o
sin conexión— y lo resuelves primero con `Future` y después con `Stream`.

Todo el código lo escribe el agente. Tu trabajo es dirigirlo, verificar el resultado y
**explicar lo que observas**. Las preguntas valen tanto como el código.

---

## Las dos partes van con arquitectura limpia

La misma de la Semana 5 y de la participación de clase. **No es opcional:** es lo que hace
que el ejercicio tenga sentido.

```text
presentation  ──►  domain  ◄──  data
```

| Capa | Qué va aquí | Qué NO puede importar |
|---|---|---|
| `domain` | entidades, **contratos** abstractos y casos de uso | `flutter`, y cualquier paquete externo |
| `data` | las implementaciones concretas (SharedPreferences, connectivity_plus) | — |
| `presentation` | el administrador de estado y las pantallas | los paquetes de `data` |

### Por qué importa justo en este deber

En la Parte A vas a escribir `domain` y `data` **una sola vez**, y después cambiarás
**únicamente `presentation`** tres veces. Al final vas a comprobar con un comando de Git que
las tres ramas comparten exactamente el mismo `domain` y el mismo `data`.

Eso demuestra algo que vale más que los tres paquetes juntos:

> **El administrador de estado es un detalle de la capa de presentación.**
> No es "la arquitectura de la app". Es una pieza reemplazable.

---

## Cómo trabajar

Igual que en la participación de clase:

- **Qué vamos a hacer y por qué** → léelo antes de pedir nada.
- **▶ Pídeselo al agente** → bloque listo para copiar.
- **Verifica** → no avances sin comprobarlo.

> Un bloque por vez. Si pegas todo junto el código sale igual, pero no vas a poder responder
> ninguna pregunta.

---

## Entrega

Un repositorio en GitHub llamado `deber1-estado-streams` con:

```text
deber1-estado-streams/
├── parte_a_contador/      (tres ramas: setstate, riverpod, bloc)
├── parte_b_conexion/
├── demo.mp4
└── RESPUESTAS.md
```

Las **8 preguntas** van todas en `RESPUESTAS.md`, numeradas, junto con las dos tablas que
se piden (la comparativa de A.6 y la salida de los comandos de A.5).

**Fecha de entrega:** la del aula virtual.

---
---

# PARTE A · La misma app, tres veces

## A.0 · La app y el plan

Dos pantallas y **un contador compartido que además persiste**:

```text
Pantalla 1 · Visor              Pantalla 2 · Control

   Contador: 0                    [  +1  ]
                                  [  -1  ]
 [ Ir a Control ]                 [ Volver ]
```

La Pantalla 2 **modifica** el contador. La Pantalla 1 lo **muestra**. El valor sobrevive al
cierre de la app.

Suena trivial. Con `setState` no lo es, y ese es el punto.

### El plan de trabajo

```text
1. domain + data           →  se escriben UNA vez, en main
2. presentation setState   →  rama version/setstate
3. presentation Riverpod   →  rama version/riverpod
4. presentation Cubit      →  rama version/bloc
```

Las tres ramas salen de `main`, **no una de otra**. Es lo que permite compararlas.

```bash
mkdir parte_a_contador && cd parte_a_contador
flutter create .
flutter pub add shared_preferences
git init
git add . && git commit -m "chore: proyecto base"
```

---

## A.1 · El núcleo que no va a cambiar

Antes de tocar ningún administrador de estado definimos **qué se puede hacer con el
contador**, sin decir quién lo va a mostrar.

`Incrementar` no es un simple `+1`: lee el valor guardado, le suma uno, lo persiste y
devuelve el resultado. Eso es una regla del negocio, no acceso a datos ni interfaz. Por eso
es un caso de uso.

### ▶ Pídeselo al agente

```text
Voy a construir una app Flutter con arquitectura limpia: domain, data y
presentation. Direccion de dependencias: presentation -> domain <- data.

Crea, dentro de lib/:

1) domain/repositories/contador_repository.dart   (clase ABSTRACTA)
   Future<int> leer();
   Future<void> guardar(int valor);

2) domain/usecases/obtener_contador.dart
   class ObtenerContador: recibe ContadorRepository por constructor,
   su metodo call() devuelve Future<int> con el valor guardado.

3) domain/usecases/incrementar.dart
   class Incrementar: recibe ContadorRepository por constructor.
   call() lee el valor actual, le suma 1, lo guarda y devuelve el nuevo valor.

4) domain/usecases/decrementar.dart
   igual que Incrementar pero restando 1.

5) data/repositories/contador_prefs_repository.dart
   implements ContadorRepository usando shared_preferences con la clave
   'contador'. Si no existe todavia, leer() devuelve 0.

Reglas obligatorias:
- domain/ NO puede importar flutter, shared_preferences ni ningun paquete.
- No crees todavia ninguna pantalla ni ningun administrador de estado.
```

### Verifica

Abre los tres archivos de `domain/` y mira **solo los imports**. Si aparece `flutter` o
`shared_preferences`, dile al agente que lo corrija antes de seguir.

```bash
git add . && git commit -m "feat: domain y data del contador"
```

> Este commit es el que van a compartir las tres ramas. De aquí en adelante **solo tocas
> `presentation/` y `main.dart`.**

---

## A.2 · Versión 1 — `setState`

`setState` solo puede reconstruir **el widget donde vive**. Si el contador es un campo del
`State` de la Pantalla 1, la Pantalla 2 no puede tocarlo: hay que pasárselo por constructor y
devolver el resultado al navegar de regreso.

Vas a sentir la incomodidad. Es intencional.

```bash
git switch -c version/setstate
```

### ▶ Pídeselo al agente

```text
Estoy en la rama version/setstate. Ya existen domain/ y data/. NO los
modifiques.

Crea solo la capa presentation, usando UNICAMENTE setState. Sin Provider, sin
Riverpod, sin BLoC, sin variables globales y sin singletons.

1) presentation/pantallas/pantalla_visor.dart  (StatefulWidget)
   - recibe los casos de uso ObtenerContador, Incrementar y Decrementar por
     constructor
   - guarda int _contador en su State
   - en initState llama a ObtenerContador y hace setState con el resultado
   - muestra "Contador: $_contador" en grande
   - boton "Ir a Control" que navega a PantallaControl pasandole el valor
     actual y los casos de uso, y que al regresar actualice _contador con el
     valor devuelto, usando setState

2) presentation/pantallas/pantalla_control.dart  (StatefulWidget)
   - recibe el valor inicial y los casos de uso por constructor
   - botones +1 y -1 que llaman a los casos de uso y hacen setState con el
     resultado
   - boton "Volver" que hace Navigator.pop devolviendo el valor actual

3) main.dart: crea ContadorPrefsRepository, los tres casos de uso, y
   pasalos a PantallaVisor. Este es el unico archivo que menciona la clase
   concreta del repositorio.

Las pantallas NO pueden importar shared_preferences.
```

### Verifica

1. Incrementa 3 veces en Control y vuelve. El visor debe mostrar 3.
2. Cierra la app por completo y vuelve a abrirla. El 3 sigue ahí (lo guardó `data`).
3. Ahora entra a Control, incrementa, y **sal con el botón atrás del sistema** (el de
   Android, no el de la app).

**Responder:**

> **1.** ¿Qué pasó en el paso 3 y por qué? Ojo: el valor **sí** se guardó en disco. ¿Qué es
> exactamente lo que quedó desactualizado? Y para que el contador viajara entre las dos
> pantallas, ¿cuántos lugares del código tuvieron que ponerse de acuerdo?

```bash
git add . && git commit -m "feat: presentation con setState"
```

---

## A.3 · Versión 2 — Riverpod

Riverpod saca el estado **fuera del árbol de widgets**. El contador deja de pertenecer a una
pantalla: vive en un provider al que cualquiera puede asomarse.

Fíjate en que las pantallas ya **no se pasan nada** entre ellas.

```bash
git switch main && git switch -c version/riverpod
flutter pub add flutter_riverpod
```

### ▶ Pídeselo al agente

```text
Estoy en la rama version/riverpod. Ya existen domain/ y data/ del commit
anterior. NO los modifiques: la app debe seguir usando los mismos casos de uso.

Crea la capa presentation con Riverpod (flutter_riverpod), usando la API
actual del paquete:

1) presentation/estado/contador_provider.dart
   - un provider que exponga el repositorio y los casos de uso
   - un provider de estado que guarde el valor del contador y ofrezca
     cargar(), incrementar() y decrementar(), llamando SIEMPRE a los casos
     de uso del domain (nunca a shared_preferences directamente)

2) presentation/pantallas/pantalla_visor.dart
   observa el provider y muestra el valor

3) presentation/pantallas/pantalla_control.dart
   llama a incrementar() y decrementar()

4) main.dart: envuelve la app en ProviderScope

Requisitos:
- las pantallas NO se pasan datos por constructor
- la navegacion es push/pop normal, sin devolver valores
- ningun archivo de presentation/ importa shared_preferences
Manten la misma interfaz visual que la version con setState.
```

### Verifica

1. Incrementa en Control y vuelve: el visor ya está actualizado **sin devolver nada**.
2. Sal con el botón atrás del sistema. Ahora **sí** funciona.

**Responder:**

> **2.** ¿Por qué ahora el botón atrás del sistema no rompe nada? ¿Dónde vive el contador?

```bash
git add . && git commit -m "feat: presentation con Riverpod"
```

---

## A.4 · Versión 3 — BLoC (Cubit)

Cubit es la versión simple de BLoC: una clase con métodos que **emiten** un estado nuevo.

La diferencia con los anteriores es que el estado es **inmutable**: no se modifica, se
reemplaza. Cada cambio produce un estado nuevo, y eso hace que toda la historia sea
rastreable.

```bash
git switch main && git switch -c version/bloc
flutter pub add flutter_bloc
```

### ▶ Pídeselo al agente

```text
Estoy en la rama version/bloc. Ya existen domain/ y data/. NO los modifiques.

Crea la capa presentation con flutter_bloc:

1) presentation/estado/contador_cubit.dart
   class ContadorCubit extends Cubit<int> con estado inicial 0.
   Recibe los casos de uso ObtenerContador, Incrementar y Decrementar por
   constructor. Metodos cargar(), incrementar() y decrementar() que llamen a
   los casos de uso y hagan emit() con el resultado.
   El Cubit NO puede importar shared_preferences.

2) presentation/pantallas/pantalla_visor.dart
   usa BlocBuilder para mostrar el valor

3) presentation/pantallas/pantalla_control.dart
   usa context.read<ContadorCubit>() para llamar a los metodos

4) main.dart: BlocProvider por encima de las dos pantallas, construyendo el
   Cubit con los casos de uso. Ademas registra un BlocObserver simple que
   imprima en consola cada cambio con el formato "ContadorCubit: 3 -> 4".

Requisitos: las pantallas NO se pasan datos por constructor.
Manten la misma interfaz visual que las versiones anteriores.
```

### Verifica

Incrementa y decrementa varias veces mirando la **consola de depuración**. Deberías ver la
secuencia completa de cambios.

**Responder:**

> **3.** ¿Qué te permite ver el `BlocObserver` que las otras dos versiones no te daban?
> ¿En qué situación real sería útil ese registro?

```bash
git add . && git commit -m "feat: presentation con BLoC (Cubit)"
git push -u origin --all
```

---

## A.5 · La prueba de que la arquitectura sirvió

Este es el momento importante del deber. Corre estos dos comandos:

```bash
git diff version/setstate version/riverpod -- lib/domain lib/data
git diff version/setstate version/bloc     -- lib/domain lib/data
```

**Los dos deben salir completamente vacíos.**

Si salen vacíos significa que cambiaste de administrador de estado **tres veces** sin tocar
ni una línea de la lógica de tu aplicación. Si sale alguna diferencia, algo se filtró de
`presentation` hacia adentro: revísalo con el agente.

Ahora corre este otro:

```bash
git diff version/setstate version/bloc --stat -- lib/presentation
```

Ahí sí hay diferencias, y muchas. Esa es la frontera.

**Responder:**

> **4.** Pega la salida de los tres comandos en `RESPUESTAS.md`. ¿Qué demuestra que los dos
> primeros salgan vacíos y el tercero no? Si mañana tuvieras que cambiar Riverpod por otro
> paquete, ¿qué parte del proyecto tendrías que volver a escribir?

---

## A.6 · La comparación

Completa esta tabla en `RESPUESTAS.md` con lo que **observaste**, no con lo que dice
internet:

| | setState | Riverpod | Cubit |
|---|---|---|---|
| ¿Dónde vive el contador? | | | |
| ¿Las pantallas se pasan datos? | | | |
| Archivos de `presentation/` que tocaste | | | |
| ¿Qué pasa con el botón atrás? | | | |
| ¿Tuviste que tocar `domain/`? | | | |

**Responder:**

> **5.** Si la app tuviera **una sola pantalla**, ¿cuál de las tres elegirías y por qué?
> ¿Y si tuviera ocho pantallas que comparten cinco datos distintos? `setState` no es "malo":
> cierra tu respuesta diciendo en dos líneas cuándo **sí** es la opción correcta.

---
---

# PARTE B · Future vs Stream, con algo que cambia de verdad

## B.0 · Por qué la conexión es el ejemplo perfecto

Hasta ahora los datos cambiaban **porque tú los cambiabas**. La conexión del teléfono no:
cambia sola, cuando entras al ascensor, cuando sales del rango del Wi-Fi, cuando pasas de
Wi-Fi a datos móviles.

Ese es el escenario donde la diferencia entre `Future` y `Stream` deja de ser teoría.

```text
Future  →  "¿cómo está la conexión AHORA?"        una foto
Stream  →  "avísame cada vez que cambie"          un flujo
```

### Prepara el proyecto

```bash
mkdir parte_b_conexion && cd parte_b_conexion
flutter create .
flutter pub add connectivity_plus flutter_bloc
git init && git add . && git commit -m "chore: proyecto base"
```

---

## B.1 · Primero el dominio, sin el paquete

Antes de tocar `connectivity_plus` definimos **qué queremos saber**, sin decir cómo se
averigua. Así la app no queda casada con ese paquete: si mañana lo cambias, solo tocas
`data/`.

Fíjate en el contrato: un método devuelve `Future` y el otro `Stream`. **Esa decisión se
toma en `domain`**, antes de escribir una sola línea de interfaz, porque describe la
naturaleza del dato — no un detalle técnico.

### ▶ Pídeselo al agente

```text
Voy a construir una app Flutter con arquitectura limpia: domain, data y
presentation. Direccion de dependencias: presentation -> domain <- data.

Crea:

1) lib/domain/entities/estado_conexion.dart
   enum EstadoConexion { wifi, datosMoviles, otro, sinConexion }

2) lib/domain/repositories/conexion_repository.dart   (clase ABSTRACTA)
   Future<EstadoConexion> consultarAhora();
   Stream<EstadoConexion> observarCambios();

3) lib/domain/usecases/consultar_conexion.dart
   class ConsultarConexion: recibe ConexionRepository, call() devuelve
   Future<EstadoConexion>.

4) lib/domain/usecases/observar_conexion.dart
   class ObservarConexion: recibe ConexionRepository, call() devuelve
   Stream<EstadoConexion>.

5) lib/data/repositories/conexion_plus_repository.dart
   implements ConexionRepository usando connectivity_plus:
   - consultarAhora() usa Connectivity().checkConnectivity()
   - observarCambios() usa Connectivity().onConnectivityChanged
   Traduce el resultado del paquete a nuestro enum EstadoConexion.
   Si la version del paquete devuelve una lista, prioriza wifi, luego mobile,
   y si no hay ninguno devuelve sinConexion.

Regla: domain/ NO puede importar connectivity_plus ni flutter.
```

### Verifica

Busca `connectivity` en `lib/domain/`. No debe aparecer.

Fíjate además en la firma del contrato: un método devuelve `Future` y el otro `Stream`. Esa
decisión ya describe la naturaleza del dato, antes de escribir una línea de interfaz.

---

## B.2 · La versión `Future` — la foto

Una pantalla con un botón **"Consultar"** y el estado actual.

### ▶ Pídeselo al agente

```text
Crea lib/presentation/pantallas/pantalla_foto.dart: un StatefulWidget que use
SOLO el caso de uso ConsultarConexion (la version Future).

  - un boton "Consultar ahora"
  - al pulsarlo llama al caso de uso y muestra el resultado en grande:
    "Wi-Fi", "Datos moviles" o "Sin conexion", con un icono y un color
    (verde si hay conexion, rojo si no)
  - muestra tambien la hora exacta de la consulta, con formato HH:mm:ss

No uses streams aqui. Quiero ver la limitacion.
Esta pantalla NO puede importar connectivity_plus.
```

### Verifica — este es el experimento

1. Con Wi-Fi encendido, pulsa **Consultar**. Dice *Wi-Fi* y la hora.
2. **Apaga el Wi-Fi del teléfono** (o activa modo avión).
3. **No toques la app.** Mírala.

La pantalla sigue diciendo *Wi-Fi*, con la hora de hace un rato. Está mintiendo.

4. Pulsa **Consultar** otra vez. Ahora sí dice *Sin conexión*.

**Responder:**

> **6.** ¿Por qué la pantalla siguió mostrando "Wi-Fi" si el Wi-Fi ya estaba apagado?
> ¿La app tenía un dato **incorrecto**, o tenía un dato **correcto de un momento
> equivocado**?

---

## B.3 · La versión `Stream` con Cubit

Ahora el Cubit **se suscribe** al stream y emite un estado nuevo cada vez que el sistema
operativo avisa de un cambio.

Fíjate en el detalle que se nos escapa siempre: un Cubit que abre una suscripción tiene que
**cerrarla** en `close()`. Si no, queda escuchando para siempre.

### ▶ Pídeselo al agente

```text
Ahora la version reactiva, con flutter_bloc. El Cubit solo puede conocer los
casos de uso del domain: NO puede importar connectivity_plus.

1) lib/presentation/estado/conexion_cubit.dart
   class ConexionCubit extends Cubit<EstadoConexion>
   - recibe ConsultarConexion y ObservarConexion por constructor
   - estado inicial: EstadoConexion.otro
   - un metodo iniciar() que primero haga emit con ConsultarConexion y luego
     se suscriba a ObservarConexion emitiendo cada valor que llegue
   - guarda la StreamSubscription en un campo y cancelala en el override de
     close() con await

2) lib/presentation/pantallas/pantalla_stream.dart
   - BlocProvider que crea el ConexionCubit y llama a iniciar()
   - BlocBuilder que muestre el estado actual en grande, con icono y color
   - un contador de cuantos cambios se han recibido desde que se abrio

3) En main.dart:
   - crea ConexionPlusRepository y los dos casos de uso
   - pon las dos pantallas en un TabBar o BottomNavigationBar:
     "Con Future" y "Con Stream"
   main.dart es el unico archivo que menciona ConexionPlusRepository.
```

### Verifica — el momento del deber

Abre la pestaña **Con Stream** y, sin tocar la pantalla:

1. Apaga el Wi-Fi → la pantalla cambia **sola** a *Sin conexión*.
2. Enciéndelo → vuelve **sola** a *Wi-Fi*.
3. Si tienes datos móviles, apaga solo el Wi-Fi y observa que pasa a *Datos móviles*.

Graba un video corto de la pantalla (15–20 segundos) mostrando los cambios en vivo y
súbelo al repositorio como `demo.mp4`.

### La misma prueba de arquitectura

```bash
grep -r "connectivity" lib/ --include=*.dart -l
```

Solo debe aparecer **un archivo**: `lib/data/repositories/conexion_plus_repository.dart`.

Si aparece el Cubit o alguna pantalla, el paquete se filtró hacia arriba.

**Responder:**

> **7.** ¿Qué pasaría si borras el `cancel()` del `close()` del Cubit y el usuario entra y
> sale de esa pantalla cincuenta veces?

> **8.** Con lo que viste: ¿por qué decimos que un `Future` es una foto y un `Stream` una
> película? Explícalo con la conexión, no con la definición del libro. Cierra nombrando
> **dos datos** de una app real que pedirías con `Future` y **dos** que observarías con
> `Stream`.

---

## B.4 · Cierre

```bash
git add . && git commit -m "feat: conexion con Future y con Stream + Cubit"
git push -u origin main
```

---
---

# Estructura esperada

```text
parte_a_contador/lib/                    parte_b_conexion/lib/
├── domain/                              ├── domain/
│   ├── repositories/                    │   ├── entities/estado_conexion.dart
│   │   └── contador_repository.dart     │   ├── repositories/
│   └── usecases/                        │   │   └── conexion_repository.dart
│       ├── obtener_contador.dart        │   └── usecases/
│       ├── incrementar.dart             │       ├── consultar_conexion.dart
│       └── decrementar.dart             │       └── observar_conexion.dart
├── data/                                ├── data/
│   └── repositories/                    │   └── repositories/
│       └── contador_prefs_…dart         │       └── conexion_plus_…dart
├── presentation/   ← lo único que       ├── presentation/
│   ├── estado/        cambia en las     │   ├── estado/conexion_cubit.dart
│   └── pantallas/     tres ramas        │   └── pantallas/
└── main.dart                            └── main.dart
```

### Verificación por imports

| Archivo | NO debe importar |
|---|---|
| `domain/*` (ambas partes) | `flutter` y cualquier paquete externo |
| `presentation/*` Parte A | `shared_preferences` |
| `presentation/*` Parte B | `connectivity_plus` |
| `main.dart` | — (es el único que nombra las clases concretas) |

---

# Antes de entregar, revisa que

- [ ] Las **tres ramas** de la Parte A existen y cada una corre.
- [ ] Los dos `git diff` de `domain` y `data` entre ramas salen **vacíos**.
- [ ] En Riverpod y en Cubit las pantallas **no se pasan datos** por constructor.
- [ ] El `BlocObserver` imprime los cambios en consola.
- [ ] En la Parte B, `grep -r "connectivity" lib/ -l` devuelve **un solo archivo**.
- [ ] El `cancel()` está dentro del `close()` del Cubit.
- [ ] El `demo.mp4` muestra la pantalla cambiando sola al apagar el Wi-Fi.
- [ ] Las **8 respuestas** están en `RESPUESTAS.md`, y hablan de lo que viste en tu
      pantalla, no de la definición del libro.

---

# Si algo no funciona

| Síntoma | Causa más común |
|---|---|
| El `git diff` de `domain` no sale vacío | Creaste una rama desde otra en vez de desde `main` |
| `connectivity_plus` no compila en Android | Falta subir `minSdkVersion` en `android/app/build.gradle` |
| El stream no emite nada al apagar el Wi-Fi | Estás en un emulador: prueba con modo avión o en un teléfono real |
| `checkConnectivity()` devuelve un tipo inesperado | Versiones recientes devuelven una **lista**; pídele al agente que la maneje |
| `Cubit` lanza error al cerrar la pantalla | Falta `await _sub.cancel()` dentro de `close()` |
| Riverpod: "No ProviderScope found" | Falta envolver la app en `ProviderScope` en `main()` |
| El agente metió `shared_preferences` en el Cubit | Tomó el atajo: pídele que use el caso de uso del `domain` |

---

# Una última cosa

Este deber no se trata de aprender tres paquetes. Se trata de que puedas responder dos
preguntas: frente a un dato,

> *"¿lo voy a pedir una vez, o va a seguir cambiando mientras la app está abierta?"*

y frente a una decisión técnica,

> *"¿esto pertenece a la lógica de mi aplicación, o es un detalle que mañana podría
> cambiar?"*

Las respuestas a esas dos preguntas deciden casi todo lo demás.
