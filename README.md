# La Piedra de Cantuña

RPG 2D hecho en **Godot 4.7.2** (GDScript) para el **PyWeekend 19na. Edición (ESPOL)**, con la temática
*Leyendas urbanas del Ecuador*.

**Jugar en el navegador:** https://lisneirytorres.github.io/piedra-de-cantuna/
(Chrome o Edge de escritorio)

## La leyenda adaptada

*Cantuña y el atrio de San Francisco (Quito, siglo XVI).* Los frailes franciscanos encargan a Cantuña,
maestro constructor indígena, el atrio de la iglesia con un plazo imposible. Desesperado, Cantuña pacta
con el diablo: sus diablillos terminarán la obra en una noche a cambio de su alma. Pero Cantuña esconde la
última piedra. Al amanecer la obra está incompleta, el pacto se anula y Cantuña salva su alma.

## Cómo se juega

El juego dura de 10 a 15 minutos y tiene tres actos:

1. **La plaza**: habla con fray Jodoco, que te encarga el atrio. Puedes ayudar a don Mateo a encontrar su
   cincel y escuchar los rumores de Juanito. Tus decisiones cambian la noche y el final.
2. **La obra**: lleva cada piedra al hueco del atrio que tenga su misma forma. Al caer la tarde, el diablo
   te ofrece un pacto. ¿Pondrás una condición?
3. **La noche**: resiste las oleadas de diablillos (tus piedrecitas se lanzan solas), sube de nivel y elige
   mejoras. Cuando aparezca la última piedra, róbasela al capataz, escóndela y aguanta hasta el amanecer.

### Controles

| Acción | Teclas |
|---|---|
| Moverse | WASD o flechas |
| Hablar, recoger, avanzar diálogos | E o Enter (también clic en los diálogos) |
| Esquivar (dash, en la noche) | Espacio o Shift |
| Elegir decisión o mejora | 1, 2, 3 o clic |
| Pausa | Esc |

## Integrantes

| Nombre | Usuario de GitHub |
|---|---|
| Lisneiry Torres | [@lisneirytorres](https://github.com/lisneirytorres) |

## Créditos y licencias

- Arte, música, sonido, guion y programación: originales del equipo. El arte y el audio se generan por código.
- Godot Engine (MIT) y GUT (MIT, solo para pruebas).
- Agradecimientos: ESPOL y PyWeekend 19na. Edición.

El detalle de cada recurso está en [CREDITS.md](CREDITS.md).

## Desarrollo

```bash
gdformat --check src test   # formato (pip install "gdtoolkit==4.*")
gdlint src test             # lint
godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://test -ginclude_subdirs -gexit   # pruebas GUT
godot --headless --export-release "Web" docs/index.html                               # exportación web
```

Estructura: `src/` contiene el código y las escenas (autoloads, componentes, actores, diálogos, interfaz y
niveles); `src/data/` contiene los datos (`.tres`); `test/` contiene las pruebas y `docs/` solo la
exportación web.
