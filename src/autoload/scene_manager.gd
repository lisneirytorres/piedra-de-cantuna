extends Node
## Cambia de escena de forma centralizada.
##
## Punto único para las transiciones (el fade se agregará aquí). No contiene lógica de juego.

## Se emite justo después de cargar la nueva escena.
signal scene_changed(scene_path: String)


## Cambia a la escena indicada por su ruta [code]res://[/code].
func change_scene(scene_path: String) -> void:
	if not ResourceLoader.exists(scene_path):
		push_error("SceneManager: no existe la escena '%s'." % scene_path)
		return
	var error: Error = get_tree().change_scene_to_file(scene_path)
	if error != OK:
		push_error("SceneManager: no se pudo cambiar a '%s' (error %d)." % [scene_path, error])
		return
	scene_changed.emit(scene_path)
