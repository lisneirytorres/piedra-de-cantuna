class_name NightClock
extends Node
## Reloj de la noche: cuenta el tiempo hasta el amanecer.
##
## Se detiene solo cuando el juego está en pausa (diálogos, mejoras, menú).

## Avanzó el tiempo. [param progress] va de 0 (anochecer) a 1 (amanecer).
signal time_changed(elapsed: float, remaining: float, progress: float)
## Llegó el amanecer.
signal dawn_reached

## Duración de la noche en segundos.
@export var duration: float = 210.0

## Segundos transcurridos.
var elapsed: float = 0.0
## [code]true[/code] mientras el reloj avanza.
var is_running: bool = false


func _process(delta: float) -> void:
	advance(delta)


## Pone el reloj en marcha desde cero.
func start() -> void:
	elapsed = 0.0
	is_running = true


## Detiene el reloj.
func stop() -> void:
	is_running = false


## Avanza el reloj [param delta] segundos (lo llama [code]_process[/code]; público para las
## pruebas).
func advance(delta: float) -> void:
	if not is_running:
		return
	elapsed = minf(elapsed + delta, duration)
	time_changed.emit(elapsed, get_remaining(), get_progress())
	if elapsed >= duration:
		is_running = false
		dawn_reached.emit()


## Segundos que faltan para el amanecer.
func get_remaining() -> float:
	return maxf(duration - elapsed, 0.0)


## Avance de la noche, de 0 a 1.
func get_progress() -> float:
	if duration <= 0.0:
		return 1.0
	return clampf(elapsed / duration, 0.0, 1.0)
