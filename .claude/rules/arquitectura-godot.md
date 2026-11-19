---
paths:
  - "src/**"
---

# Arquitectura del juego

## Principio: "llamar hacia abajo, señalar hacia arriba"

- Un nodo **llama métodos** de sus hijos y **escucha señales** de ellos.
- Un hijo **nunca** accede a su padre ni a sus hermanos. Comunica lo que pasa **emitiendo señales**.
- Las dependencias externas se inyectan con `@export` o se conectan en el editor.

```gdscript
# ✅ el hijo emite, el padre decide
signal interacted(by: Node2D)

# ❌ el hijo controla al padre
get_parent().get_parent().start_dialogue()
get_node("../../UI/DialogueBox").show()
```

**Por qué**: las escenas desacopladas se pueden probar y reutilizar solas, y cambiar el árbol no rompe nada.

## Autoloads (singletons)

Hay solo cuatro, cada uno con una responsabilidad fija:

| Autoload | Responsabilidad | No debe |
|---|---|---|
| `Events` | Bus de señales globales entre sistemas que no se conocen (`dialogue_started`, `quest_updated`) | Tener estado ni lógica |
| `GameState` | Estado de la partida: banderas de historia, inventario, piedras colocadas, decisiones | Tocar nodos de escena o la UI |
| `SceneManager` | Cambiar de escena con transición y llevar la escena actual | Contener lógica de juego |
| `AudioManager` | Música y efectos, buses `Master`/`Music`/`SFX` | Decidir cuándo suena algo por reglas de juego |

- **No crees nuevos autoloads** sin justificarlo y pedir confirmación.
- Usa `Events` solo para comunicación **entre sistemas distantes**. Dentro de una misma escena, usa señales locales.

## Composición por componentes

- Prefiere **componer** nodos reutilizables (`InteractableComponent`, `HealthComponent`, `HitboxComponent`)
  antes que jerarquías profundas de herencia (más de 2 niveles).
- Cada componente es una escena o script en `src/components/` con API pública documentada y señales propias.

## Máquinas de estado

- Los actores con comportamiento variable (jugador, jefe, NPC con rutina) usan una máquina de estados.
- Cada estado es una clase (`State`) con `enter()`, `exit()`, `update(delta)` y `physics_update(delta)`, y un
  nodo `StateMachine` gestiona las transiciones.
- Prohibido el `match` gigante de estados dentro de `_physics_process`.

## Datos separados de la lógica

- Diálogos, ítems, misiones y estadísticas son **`Resource` personalizados** (`class_name DialogueData extends Resource`),
  guardados como `.tres` en `src/data/`.
- La lógica lee los datos. Nunca escribas textos ni cifras de balance dentro de los scripts.

## Entrada

- Toda la entrada pasa por **acciones del Input Map** (`move_up`, `interact`, `pause`). Nunca uses teclas literales.
- La UI consume la entrada con `_unhandled_input` y `get_viewport().set_input_as_handled()` para no filtrarla al juego.

## Rendimiento (web)

- Evita trabajo en `_process` si una señal o un `Timer` basta.
- Precarga con `preload` los recursos pequeños y usa `ResourceLoader.load_threaded_request` **solo** si se
  confirma que funciona sin hilos en web. En caso de duda, carga síncrona.
