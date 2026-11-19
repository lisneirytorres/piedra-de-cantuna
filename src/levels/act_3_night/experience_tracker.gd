class_name ExperienceTracker
extends RefCounted
## Lleva el nivel y la experiencia de Cantuña durante la noche.
##
## Es lógica pura (sin nodos), para poder probarla con GUT.

## Nivel actual (empieza en 1).
var level: int = 1
## Experiencia acumulada dentro del nivel actual.
var xp: int = 0

var _base_xp: int = 5
var _xp_growth: int = 3


func _init(base_xp_required: int = 5, xp_growth_per_level: int = 3) -> void:
	_base_xp = maxi(base_xp_required, 1)
	_xp_growth = maxi(xp_growth_per_level, 0)


## Experiencia necesaria para pasar del nivel actual al siguiente.
func get_xp_to_next_level() -> int:
	return _base_xp + _xp_growth * (level - 1)


## Proporción de experiencia del nivel actual, entre 0 y 1.
func get_progress_ratio() -> float:
	return float(xp) / float(get_xp_to_next_level())


## Suma experiencia y devuelve cuántos niveles se ganaron.
func add_xp(amount: int) -> int:
	if amount <= 0:
		return 0
	xp += amount
	var levels_gained: int = 0
	while xp >= get_xp_to_next_level():
		xp -= get_xp_to_next_level()
		level += 1
		levels_gained += 1
	return levels_gained
