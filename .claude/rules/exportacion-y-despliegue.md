---
paths:
  - "docs/**"
  - "export_presets.cfg"
  - "project.godot"
---

# Exportación y despliegue

Procedimiento basado en el **Anexo** de las bases (Godot 4.3+; en este proyecto, 4.7.2).

## Estructura obligatoria

- `docs/` contiene **solo**: `index.html`, `index.js`, `index.wasm`, `index.pck`, otros archivos generados
  por la exportación, `.gdignore` (vacío, para que Godot no la importe) y `.nojekyll` (vacío, para que Pages
  sirva los archivos tal cual).
- `export_presets.cfg` **se versiona**, porque garantiza que todos exporten igual.
- Las builds de Windows van en `build/` (ignorada por Git) y solo se suben como .zip al release.

## Preset "Web"

- **Variant → Thread Support: desactivado.** Es indispensable: con hilos activados, el juego queda en pantalla
  negra o da error de `SharedArrayBuffer` en GitHub Pages.
- Ruta de exportación: `docs/index.html` (el archivo debe llamarse `index.html`).
- Versión final: **sin "Exportar con depuración"**.
- Renderer: **Compatibility** (`gl_compatibility`), que es el único soportado en web.

## Preset "Windows Desktop"

- Ruta: `build/windows/piedra_de_cantuna.exe`. Activa "Embed PCK" para tener un solo ejecutable.
- Se comprime en `.zip` y se adjunta al release `v1.0-pyweekend`.

## Publicar en GitHub Pages

1. Exporta (desde el editor o con `godot --headless --export-release "Web" docs/index.html`).
2. Prueba localmente con "Ejecutar en el navegador" antes de subir.
3. Haz commit y push de `docs/` a `main`.
4. Configuración (una sola vez): Settings → Pages → *Deploy from a branch* → `main` / `/docs`.
5. Verifica en **Chrome o Edge de escritorio, en una ventana de incógnito**, en `https://<usuario>.github.io/<repositorio>/`.

## Release final

1. Exporta Web y Windows desde el mismo commit.
2. Verifica que el juego funcione en Pages.
3. Releases → *Draft a new release* → etiqueta **`v1.0-pyweekend`** sobre `main`, adjunta el .zip de Windows y publica.
4. Copia el hash del commit para el formulario. No hagas push después del **13-dic 23:55**.

## Problemas frecuentes

| Síntoma | Causa y solución |
|---|---|
| Pantalla negra / `SharedArrayBuffer` | Thread Support activado o Godot anterior a 4.3 → reexportar sin hilos |
| Error 404 | En Pages no está seleccionado `/docs`, o el archivo no se llama `index.html` |
| Se ve una versión vieja | Espera a que termine el despliegue (pestaña Actions) y recarga con Ctrl+F5 |
| GitHub rechaza el push | Hay un archivo de más de 100 MB → comprimir audio o imágenes |
| Sin sonido | Falta interacción previa → el menú debe tener el botón "Jugar" |
