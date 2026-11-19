# Bases del concurso — checklist de cumplimiento

Fuente: `referencias/Bases_para_el_PyWeekend_19na.pdf`. Incumplir cualquier punto **descalifica** al equipo.
Ante cualquier duda, gana el PDF.

## Condiciones del juego

- [ ] La leyenda de Cantuña es el **eje central** de la historia y se reconoce, aunque se reinterprete.
- [ ] Es un **RPG**: el jugador explora, interactúa con personajes, toma decisiones o enfrenta retos.
- [ ] Una partida normal dura **entre 10 y 15 minutos** hasta el final.
- [ ] Todos los recursos son **propios o Creative Commons**. Ninguno es pagado.
- [ ] Hay **créditos al final**: integrantes, artistas colaboradores, ESPOL, PyWeekend y la leyenda adaptada.
- [ ] Se recomienda sumar elementos de reto: niveles de dificultad creciente, mini-jefes, batalla final,
  puzzles y diálogos con decisiones.

## Contenido del repositorio

- [ ] Un único **repositorio público**, creado por el capitán, con todos los integrantes como colaboradores.
- [ ] El proyecto fuente completo de Godot (`project.godot`, escenas, scripts, recursos) en la raíz.
- [ ] La carpeta `/docs` contiene la exportación web (`index.html`, `.wasm`, `.pck`, `.js`, `.gdignore`, `.nojekyll`).
- [ ] Ningún archivo supera **100 MB**.
- [ ] `README.md` en la raíz con: **nombre del juego, leyenda adaptada, enlace a GitHub Pages, integrantes
  (nombre + usuario de GitHub), controles, créditos y licencias de recursos de terceros**.

## Entrega

- [ ] El juego es jugable en `https://<usuario>.github.io/<repositorio>/`, probado en **Chrome o Edge de escritorio**.
- [ ] Existe el **release `v1.0-pyweekend`** sobre `main`, con el **ejecutable de Windows en .zip** adjunto.
  Los jueces evalúan **solo** ese release.
- [ ] Hay un **video en Instagram** de máximo 1 minuto que muestra cómo se juega.
- [ ] El capitán registra en el formulario: el enlace del repo, el enlace de Pages, el enlace del release,
  el hash del commit y el video.

## Hitos (2026, 23:55)

| Fecha | Obligación |
|---|---|
| 06-dic | **Prueba de despliegue** en Pages registrada. Sin ella no se puede hacer la entrega final |
| 13-dic | **Entrega final** y registro en el formulario |
| 13 al 18-dic | **Congelamiento**: ningún push a la rama publicada |

**Por qué**: la prueba de despliegue temprana evita sorpresas de última hora (pantalla negra, 404, tamaño excesivo).
Mantén `main` siempre exportable desde la primera semana.

## Criterios de calificación (guía para priorizar)

1. Originalidad de la idea y fidelidad o creatividad en la adaptación de la leyenda.
2. Funcionalidad y usabilidad (experiencia del usuario).
3. Complejidad de la trama y de las mecánicas RPG.
4. **Estándares y buenas prácticas de programación**: los jueces leen el código fuente.
5. Estética (concepto creativo).
6. Cumplimiento de la duración de 10 a 15 minutos.
7. *(Extra)* Originalidad de los recursos audiovisuales propios.

Al decidir entre dos opciones, elige la que asegure un juego **completo, jugable de inicio a créditos y dentro
del tiempo**. Las funciones vistosas pero incompletas restan puntos.
