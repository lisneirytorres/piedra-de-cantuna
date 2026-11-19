# Git y colaboración

## Ramas

- `main` está **siempre jugable y exportable**, porque es la rama que publica GitHub Pages.
- El trabajo se hace en ramas cortas: `feature/<descripcion>`, `fix/<descripcion>`, `docs/<descripcion>`,
  `art/<descripcion>` (en inglés y kebab-case, ej. `feature/dialogue-system`).
- La integración a `main` se hace por **Pull Request** con revisión de **otro integrante**.

## Commits (Conventional Commits, en español)

```
<tipo>(<ámbito opcional>): <resumen en imperativo, minúsculas, sin punto final>
```

Tipos: `feat`, `fix`, `refactor`, `docs`, `test`, `style`, `chore`, `build` (exportaciones), `assets`.

```
✅ feat(dialogue): agrega decisiones al diálogo del pacto
✅ build: exporta versión web para prueba de despliegue
❌ cambios
❌ arreglé cosas del jugador y el menú y los sonidos
```

- Un commit = un cambio lógico. No mezcles una exportación en `docs/` con cambios de código.
- No incluyas secretos, `.godot/`, `build/` ni archivos personales (`CLAUDE.local.md`, `.claude/settings.local.json`).

## Reglas para Claude

- **No hagas commit ni push** salvo que se pida explícitamente.
- **Nunca** uses `git push --force`, `reset --hard` sobre trabajo ajeno ni reescribas historia publicada.
- Antes de un commit: `gdformat --check`, `gdlint` y las pruebas GUT deben pasar.
- Si estás en `main` y piden un cambio no trivial, propón crear una rama.

## Congelamiento

Desde el **13-dic-2026 a las 23:55** hasta el final del **18-dic-2026**, **prohibido hacer push** a la rama
publicada o modificar el release `v1.0-pyweekend`. Si te piden un cambio en ese período, avisa del
congelamiento y no lo ejecutes.
