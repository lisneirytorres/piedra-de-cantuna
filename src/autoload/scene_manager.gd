extends Node
## Cambia de escena de forma centralizada, con un fundido a negro.
##
## Punto único para las transiciones. No contiene lógica de juego.

## Se emite justo después de cargar la nueva escena.
signal scene_changed(scene_path: String)

## Duración de cada mitad del fundido (oscurecer y aclarar), en segundos.
const FADE_DURATION: float = 0.35
## Capa del fundido: por encima de cualquier interfaz del juego.
const FADE_LAYER: int = 100

## [code]true[/code] mientras hay una transición en curso.
var is_changing: bool = false

var _fade_rect: ColorRect


func _ready() -> void:
	# Las transiciones deben funcionar aunque el juego esté en pausa (por ejemplo, desde el menú de
	# pausa).
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_fade_layer()


## Cambia a la escena indicada por su ruta [code]res://[/code], con fundido.
func change_scene(scene_path: String) -> void:
	if is_changing:
		return
	if not ResourceLoader.exists(scene_path):
		push_error("SceneManager: no existe la escena '%s'." % scene_path)
		return
	is_changing = true
	await _fade_to(1.0)
	get_tree().paused = false
	var error: Error = get_tree().change_scene_to_file(scene_path)
	if error != OK:
		push_error("SceneManager: no se pudo cambiar a '%s' (error %d)." % [scene_path, error])
	else:
		scene_changed.emit(scene_path)
	await _fade_to(0.0)
	is_changing = false


## Vuelve a cargar la escena actual (por ejemplo, para reintentar la noche).
func reload_current_scene() -> void:
	var current: Node = get_tree().current_scene
	if current == null:
		push_error("SceneManager: no hay escena actual que recargar.")
		return
	change_scene(current.scene_file_path)


func _build_fade_layer() -> void:
	var layer := CanvasLayer.new()
	layer.layer = FADE_LAYER
	add_child(layer)
	_fade_rect = ColorRect.new()
	_fade_rect.color = Color(0.0, 0.0, 0.0, 0.0)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(_fade_rect)


func _fade_to(alpha: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(_fade_rect, "color:a", alpha, FADE_DURATION)
	await tween.finished
