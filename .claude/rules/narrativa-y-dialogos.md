---
paths:
  - "src/data/**"
  - "src/dialogue/**"
  - "src/levels/**"
---

# Narrativa y diálogos

## Fidelidad a la leyenda

La leyenda de **Cantuña** debe ser reconocible y central. Elementos que no pueden faltar:

- **Cantuña**, el indígena constructor y protagonista.
- **Los frailes franciscanos**, que encargan el atrio de la iglesia de **San Francisco (Quito)** con un plazo.
- **El pacto con el diablo**: el diablo construye a cambio del alma de Cantuña.
- **La piedra faltante**: Cantuña esconde la última piedra y la obra queda incompleta. El pacto se anula y
  Cantuña salva su alma.
- Ambientación en el **Quito colonial**.

Se permite reinterpretar el punto de vista, la época o los detalles, pero **pregunta antes** de cambiar
cualquiera de estos elementos.

## Estructura y presupuesto de tiempo (meta: unos 12 min, rango válido 10–15)

| Segmento | Duración | Propósito |
|---|---|---|
| Menú principal | — | Botón "Jugar" (activa el audio web) |
| Acto 1: La plaza | ~3 min | Presentar a Cantuña, el encargo de los frailes y el plazo. Tutorial de controles |
| Acto 2: La obra | ~4 min | Reunir y colocar piedras (puzzle). La obra no avanza y el diablo ofrece el pacto (decisión) |
| Acto 3: La noche | ~4 min | Esconder la última piedra (sigilo o puzzle). Confrontación final con el diablo |
| Epílogo + Créditos | ~1 min | Desenlace según las decisiones. Créditos obligatorios |

Si se agrega contenido, indica cuánto tiempo suma y qué segmento se acorta.

## Diálogos

- Cada conversación es un recurso `.tres` (`DialogueData`) en `src/data/dialogue/`, con nombre
  `<acto>_<personaje>_<tema>.tres` (ej. `act_2_devil_pact.tres`).
- Los textos visibles van en **español**, con un registro coherente con la época. Revisa la ortografía.
- Líneas cortas: máximo ~2 renglones en la caja de diálogo.
- Las **decisiones** se guardan como banderas en `GameState` (`&"accepted_pact"`) y deben tener **consecuencias
  visibles** (otro diálogo, otra ruta o el epílogo).
- Ningún diálogo bloquea el avance sin dejar una salida clara al jugador.
