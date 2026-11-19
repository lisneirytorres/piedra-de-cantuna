---
paths:
  - "**/*.tscn"
  - "**/*.tres"
---

# Escenas y recursos

- **Una escena, un script raíz**, con el mismo nombre de archivo: `player.tscn` ↔ `player.gd`, en la misma carpeta.
- **Instancia, no dupliques**: si dos escenas comparten estructura, extrae una subescena reutilizable o usa
  escenas heredadas.
- **Nodos en `PascalCase`** y con nombres descriptivos (`InteractionArea`, no `Area2D2`).
- Usa **solo rutas `res://` o `uid://`**, nunca rutas absolutas del sistema. No muevas archivos fuera del editor
  de Godot, porque rompe referencias. Si se mueven, verifica los UIDs.
- `preload()` para recursos fijos conocidos en compilación. `load()` solo para rutas dinámicas.
- Marca como **"Editable Children"** o "Make Local" solo cuando sea imprescindible.
- **No edites `.tscn` ni `.tres` a mano** salvo cambios triviales y seguros (un valor de propiedad, un texto).
  Para cambios estructurales, describe los pasos en el editor o crea los nodos por código en `_ready()`.
- Los recursos compartidos que se modifican en tiempo de ejecución deben usar `duplicate()` o tener
  `resource_local_to_scene = true`, para no alterar el original de todas las instancias.
- Los `.tres` de datos van en `src/data/<tipo>/`, por ejemplo `src/data/dialogue/act_1_friar.tres`.
