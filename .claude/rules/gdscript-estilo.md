---
paths:
  - "**/*.gd"
---

# Estilo de GDScript

Basado en la [guía de estilo oficial de GDScript](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
para Godot 4.7. El formato lo impone `gdformat` y las reglas las verifica `gdlint`.

## Orden dentro de un script

Respeta siempre este orden:

1. `@tool` / `@icon` (si aplica)
2. `class_name` y `extends`
3. Docstring de clase `##` (en español)
4. `signal`
5. `enum`
6. `const`
7. `@export` (agrupados con `@export_group` si son muchos)
8. Variables públicas, luego privadas (`_`)
9. `@onready`
10. Métodos virtuales: `_init`, `_enter_tree`, `_ready`, `_process`, `_physics_process`, `_input`/`_unhandled_input`
11. Métodos públicos
12. Métodos privados (`_`)
13. Callbacks de señales (`_on_<emisor>_<señal>`)

## Nombres

| Elemento | Convención | Ejemplo |
|---|---|---|
| Archivos y carpetas | `snake_case` | `player_controller.gd` |
| `class_name`, nodos | `PascalCase` | `class_name DialogueBox` |
| Funciones y variables | `snake_case` | `func collect_stone() -> void:` |
| Privados | prefijo `_` | `var _current_state: State` |
| Constantes y valores de enum | `UPPER_CASE` | `const MAX_STONES: int = 12` |
| Señales | verbo en pasado | `signal stone_collected(stone_id: StringName)` |
| Booleanos | prefijo `is_`, `has_`, `can_` | `var is_talking: bool` |

Los identificadores van **en inglés**; los comentarios y docstrings **en español**.

## Tipado estático (obligatorio)

- Tipa toda variable, parámetro y retorno, incluido `-> void`.
- Usa arrays y diccionarios tipados (`Array[Item]`, `Dictionary[StringName, int]`).
- Usa `:=` solo cuando el tipo es evidente en la misma línea.

```gdscript
# ✅
@export var walk_speed: float = 90.0
var _inventory: Dictionary[StringName, int] = {}

func add_item(item_id: StringName, amount: int = 1) -> void:
	_inventory[item_id] = _inventory.get(item_id, 0) + amount

# ❌
var speed = 90
func add_item(id, amount = 1):
	inventory[id] += amount
```

**Por qué**: el tipado detecta errores en el editor, mejora el autocompletado y es lo primero que nota un juez al leer el código.

## Claridad y robustez

- **Sin números mágicos**: usa `const` o `@export` con un nombre descriptivo.
- **Funciones cortas** (≤ ~40 líneas), con una sola responsabilidad. Si necesitas un comentario para separar
  bloques, extrae una función.
- **Retornos tempranos** en lugar de `if` anidados.
- **Nunca falles en silencio**: usa `push_error()` / `push_warning()` en los casos inesperados y `assert()` para
  validar invariantes en desarrollo.
- Usa `StringName` (`&"id"`) para claves e IDs que se comparan a menudo.
- No dejes `print()` de depuración en el código integrado a `main`. Si un log es útil, ponlo detrás de una
  bandera de depuración.
- Comenta **por qué**, no **qué**. Cada clase y función pública lleva docstring `##`.
- `@abstract` (4.5+) solo para clases base que de verdad no deben instanciarse, como `State`.
- Elimina el código comentado antes del commit. Para eso está el historial de Git.
