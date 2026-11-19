---
paths:
  - "test/**"
  - "**/*.gd"
---

# Pruebas y calidad

## Pruebas automatizadas (GUT)

- El framework es **GUT 9.x** (usa la versión compatible con Godot 4.7), instalado en `addons/gut/`.
- Las pruebas van en `test/unit/test_<modulo>.gd`, con `extends GutTest`.
- **Qué probar** (lógica pura, sin depender de la escena):
  - `GameState`: banderas, inventario y conteo de piedras.
  - Condiciones de diálogo y decisiones.
  - Funciones de cálculo (daño, progreso de misión).
- **Qué no probar**: animaciones, posiciones visuales o detalles de UI. Eso se verifica jugando.
- Sigue el patrón **Arrange-Act-Assert**, con una sola idea por prueba y nombres descriptivos en inglés:

```gdscript
extends GutTest

# Los autoloads no tienen class_name (chocaría con el nombre del singleton):
# se instancia una copia aislada desde su script.
const GameStateScript: GDScript = preload("res://src/autoload/game_state.gd")

var _state: Node

func before_each() -> void:
	_state = autofree(GameStateScript.new())

func test_set_flag_activates_flag() -> void:
	# Arrange (preparar)
	assert_false(_state.has_flag(&"accepted_pact"))
	# Act (actuar)
	_state.set_flag(&"accepted_pact")
	# Assert (verificar)
	assert_true(_state.has_flag(&"accepted_pact"))
```

- Prueba siempre una **instancia nueva** del script, nunca el singleton global, para que las pruebas no
  compartan estado.

- Si cambias lógica cubierta, actualiza o agrega pruebas en el mismo cambio. Si corriges un bug, agrega primero
  una prueba que lo reproduzca.
- Diseña la lógica para que se pueda probar: los autoloads de estado no dependen del árbol de escenas.

Ejecución:
```bash
godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://test -ginclude_subdirs -gexit
```

## Calidad estática

- `gdformat --check src test` y `gdlint src test` pasan **sin errores** antes de cada commit o PR.
- El editor de Godot no debe mostrar warnings en los scripts nuevos. `project.godot` ya activa como Warn
  `untyped_declaration` y las advertencias `unsafe_*`. No las desactives para silenciar un aviso: corrige el código.

## Prueba manual antes de cada release o hito

1. Juega de principio a fin **cronometrando**: el resultado debe estar entre 10 y 15 minutos.
2. Prueba en **Chrome y Edge** con la versión publicada en Pages, no solo en el editor.
3. Comprueba que el audio arranca tras "Jugar", que no hay bloqueos de progreso y que los créditos aparecen al final.
4. Anota los bugs como issues en GitHub.
