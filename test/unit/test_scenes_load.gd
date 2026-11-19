extends GutTest
## Prueba de humo: cada escena principal se carga, se instancia y corre unos cuadros sin errores.

const SCENES: Array[String] = [
	"res://src/ui/main_menu/main_menu.tscn",
	"res://src/levels/act_1_plaza/act_1_plaza.tscn",
	"res://src/levels/act_2_site/act_2_site.tscn",
	"res://src/levels/act_3_night/act_3_night.tscn",
	"res://src/levels/epilogue/epilogue.tscn",
	"res://src/ui/credits/credits.tscn",
]
const FRAMES_TO_RUN: int = 10


func after_each() -> void:
	get_tree().paused = false


func test_scenes_instantiate_and_run() -> void:
	for path: String in SCENES:
		var packed := load(path) as PackedScene
		assert_not_null(packed, "No se pudo cargar %s" % path)
		if packed == null:
			continue
		var scene: Node = packed.instantiate()
		add_child_autofree(scene)
		await wait_physics_frames(FRAMES_TO_RUN)
		assert_true(is_instance_valid(scene), "%s se liberó sola" % path)
		scene.queue_free()
		await wait_process_frames(2)
