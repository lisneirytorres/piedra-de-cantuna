class_name NightConfig
extends Resource
## Balance de la noche: duración, oleadas de diablillos, experiencia y jefe.
##
## Los valores viven en [code]src/data/night/night_config.tres[/code]. La dificultad va de 0
## (anochecer) a 1 (amanecer) y se interpola entre los valores de inicio y de fin.

@export_group("Tiempo")
## Duración de la noche, en segundos.
@export var duration: float = 210.0
## Segundo en el que aparece la última piedra (y el capataz).
@export var stone_appear_time: float = 110.0
## Avance máximo de la obra antes del amanecer: nunca llega al 100 % porque falta una piedra.
@export var max_work_progress: float = 0.99

@export_group("Oleadas")
@export var spawn_interval_start: float = 1.3
@export var spawn_interval_end: float = 0.3
@export var max_enemies: int = 70
## Distancia al jugador a la que aparecen los diablillos (fuera de la pantalla).
@export var spawn_distance: float = 250.0

@export_group("Diablillos")
@export var imp_health_start: int = 18
@export var imp_health_end: int = 55
@export var imp_speed_start: float = 36.0
@export var imp_speed_end: float = 60.0
@export var imp_damage: int = 7

@export_group("Experiencia y jefe")
@export var xp_base: int = 4
@export var xp_growth: int = 3
@export var foreman_health: int = 260
## Mejoras que se ofrecen en cada subida de nivel.
@export var upgrade_choices: int = 3


## Segundos entre apariciones de diablillos según la [param difficulty].
func get_spawn_interval(difficulty: float) -> float:
	return lerpf(spawn_interval_start, spawn_interval_end, clampf(difficulty, 0.0, 1.0))


## Vida de un diablillo según la [param difficulty].
func get_imp_health(difficulty: float) -> int:
	return roundi(lerpf(imp_health_start, imp_health_end, clampf(difficulty, 0.0, 1.0)))


## Velocidad de un diablillo según la [param difficulty].
func get_imp_speed(difficulty: float) -> float:
	return lerpf(imp_speed_start, imp_speed_end, clampf(difficulty, 0.0, 1.0))


## Avance visible de la obra según el avance de la noche [param night_progress].
func get_work_progress(night_progress: float) -> float:
	return minf(clampf(night_progress, 0.0, 1.0), max_work_progress)
