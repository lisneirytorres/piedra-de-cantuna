# CLAUDE.md — Piedra de Cantuña

Guía para Claude Code (y el equipo) al trabajar en este repositorio.

## Proyecto

- **Qué es**: un RPG 2D para el **PyWeekend 19na. Edición (ESPOL)**, cuya temática es *Leyendas urbanas del Ecuador*.
- **Leyenda**: *Cantuña y el atrio de San Francisco (Quito)*. Cantuña pacta con el diablo para terminar el atrio a
  tiempo y salva su alma escondiendo la última piedra.
- **Motor**: Godot **4.7.2-stable** (todo el equipo usa esta versión exacta), lenguaje **GDScript** únicamente.
- **Despliegue**: GitHub Pages desde `main` → carpeta `/docs` (`https://<usuario>.github.io/<repositorio>/`).
- **Bases oficiales**: `referencias/Bases_para_el_PyWeekend_19na.pdf`. Es la fuente de verdad ante cualquier duda.

### Fechas clave (2026, hora límite 23:55)

| Fecha | Hito |
|---|---|
| 23-nov | Cierre de inscripción |
| **06-dic** | **Prueba de despliegue** en GitHub Pages (obligatoria, aunque sea una sola escena) |
| **13-dic** | **Entrega final**: release `v1.0-pyweekend` + .zip de Windows. A partir de aquí el repo queda congelado |
| 18-dic | Final de Titanes (el repo sigue congelado hasta entonces) |

## Restricciones innegociables (de las bases)

Incumplir cualquiera de estas reglas **descalifica** al equipo. Nunca las rompas, ni siquiera "temporalmente".

1. **Solo GDScript.** Prohibido C#/.NET (no exporta a web). *(Modalidad y plataforma)*
2. **`project.godot` va en la raíz del repo.** *(Anexo §1.1)*
3. **`docs/` está reservada a la exportación web** (`index.html`, `.wasm`, `.pck`, `.js`, `.gdignore`, `.nojekyll`).
   Ahí no va ningún otro archivo. *(Formato de entrega §3, Anexo §1.3)*
4. **Exportación web con Thread Support desactivado.** Si está activado, el juego muestra pantalla negra en
   GitHub Pages. *(Formato de entrega §4)*
5. **Ningún archivo puede superar 100 MB**; el objetivo es 40–60 MB en total. *(Formato de entrega §5)*
6. **Assets 100 % originales o con licencia Creative Commons.** Nada pagado ni sin licencia. *(Condiciones §4)*
7. **Créditos al final del juego**: equipo, artistas, **ESPOL**, **PyWeekend** y la **leyenda**. *(Condiciones §6)*
8. **Duración de 10 a 15 minutos** de juego normal hasta el final. *(Condiciones §3)*
9. **Pantalla de inicio con botón "Jugar"**, porque el audio web solo se activa tras la primera interacción. *(Anexo §3.4)*
10. **Debe ser un RPG**: exploración, interacción con NPCs, decisiones y retos. *(Condiciones §2)*

## Convención de idioma

- **Código en inglés**: nombres de variables, funciones, clases, señales, archivos, nodos y escenas.
- **Español** en comentarios, docstrings (`##`), mensajes de commit, PRs, README y textos del juego.

## Mapa de carpetas

```
project.godot            # raíz del proyecto Godot
src/
  autoload/              # singletons: GameState, SceneManager, AudioManager, Events
  components/            # componentes reutilizables (interactable, health, hitbox…)
  actors/                # player/, npcs/, enemies/ (escena + script + estados)
  dialogue/              # sistema de diálogos y su UI
  ui/                    # main_menu, hud, pause_menu, credits
  levels/                # escenas de cada acto
  data/                  # Resources .tres (diálogos, ítems, misiones)
assets/                  # sprites/, tilesets/, audio/{music,sfx}/, fonts/
test/unit/               # pruebas GUT (test_*.gd)
addons/gut/              # framework de pruebas GUT
docs/                    # SOLO la exportación web
referencias/             # bases del concurso y notas de diseño (solo lectura, .gdignore)
```

## Comandos

```bash
gdformat src test                    # formatear GDScript (gdtoolkit; pip install "gdtoolkit==4.*")
gdformat --check src test            # verificar el formato sin modificar
gdlint src test                      # lint de GDScript
godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://test -ginclude_subdirs -gexit   # pruebas GUT
godot --headless --export-release "Web" docs/index.html                               # exportación web
godot --headless --export-release "Windows Desktop" build/windows/piedra_de_cantuna.exe # respaldo Windows
```

## Cómo debe trabajar Claude en este repo

- **Lee antes de editar**: revisa la escena o script existente y sus señales antes de proponer cambios.
- **Cambios pequeños y enfocados**: una tarea por cambio, sin refactors no pedidos.
- **Después de editar `.gd`**: ejecuta `gdformat` y `gdlint` sobre los archivos tocados y las pruebas GUT si
  cambió lógica cubierta. Reporta los resultados tal cual.
- **No toques `docs/`** salvo al exportar el juego. **No modifiques `referencias/`.**
- **No hagas commit ni push** sin que te lo pidan. Nunca uses `push --force`.
- **Pregunta antes** de cambiar la narrativa, la estructura de actos o el alcance del juego.
- **Prioriza** según los criterios de calificación: jugabilidad completa > duración correcta > buenas prácticas > estética.
- Si una petición choca con las bases, **avisa y no la ejecutes**.

## Reglas detalladas (`.claude/rules/`)

- `bases-concurso.md`: checklist de entregables, hitos y criterios de calificación (siempre se carga).
- `git-y-colaboracion.md`: ramas, commits, PRs y congelamiento (siempre se carga).
- `gdscript-estilo.md`: estilo y tipado de GDScript (`*.gd`).
- `arquitectura-godot.md`: patrones, autoloads, señales y componentes (`src/**`).
- `escenas-y-recursos.md`: convenciones de `.tscn` y `.tres`.
- `narrativa-y-dialogos.md`: fidelidad a la leyenda, actos y diálogos.
- `assets-y-licencias.md`: formatos, tamaños y registro de licencias.
- `exportacion-y-despliegue.md`: presets, GitHub Pages y release.
- `testing-y-calidad.md`: GUT, lint y prueba cronometrada.
