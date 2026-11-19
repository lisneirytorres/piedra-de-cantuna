---
paths:
  - "assets/**"
  - "CREDITS.md"
---

# Assets y licencias

## Licencias (requisito de las bases)

- Solo se aceptan assets **creados por el equipo** o con licencia **Creative Commons** (CC0, CC BY, CC BY-SA).
  **Prohibido** usar assets pagados, "free for personal use" sin licencia clara o sin autoría identificable.
- **Todo asset de terceros** se registra en `CREDITS.md` **en el mismo commit** que lo agrega:

  ```markdown
  | Recurso | Autor | Licencia | Fuente |
  |---|---|---|---|
  | assets/audio/music/act_1_plaza.ogg | Nombre Autor | CC BY 4.0 | https://... |
  ```

- Los créditos del juego (`src/ui/credits`) y el README se alimentan de `CREDITS.md`, que es la fuente única.

**Por qué**: un asset sin licencia descalifica, y los jueces otorgan puntos extra por recursos propios.

## Formatos y tamaño

| Tipo | Formato | Notas |
|---|---|---|
| Música | `.ogg` (Vorbis) | Bucles con loop activado en la importación |
| Efectos | `.ogg` o `.wav` corto | `.wav` solo si dura menos de 1 s |
| Sprites / tiles | `.png` | Pixel art: filtro **Nearest** en la importación |
| Fondos grandes | `.webp` o `.png` comprimido | — |
| Fuentes | `.ttf` / `.otf` | Con licencia OFL o CC |

- El peso total objetivo es de **40–60 MB**. Ningún archivo puede superar **100 MB** (límite de GitHub).
- **Sin Git LFS**: GitHub Pages no sirve archivos LFS.
- Nombres en `snake_case`, descriptivos y con prefijo de categoría si ayuda: `npc_friar_idle.png`, `sfx_stone_place.ogg`.
- Estructura: `assets/sprites/`, `assets/tilesets/`, `assets/audio/music/`, `assets/audio/sfx/`, `assets/fonts/`.
- Los archivos fuente de edición (`.aseprite`, `.psd`, `.kra`) van fuera del repo o en `referencias/arte/`
  si son livianos.
