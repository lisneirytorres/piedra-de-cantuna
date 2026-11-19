class_name PauseMenu
extends CanvasLayer
## Menú de pausa: se abre con la acción [code]pause[/code] (Esc o P).
##
## No se abre si el juego ya está pausado por otro sistema (por ejemplo, el menú de mejoras).

const TITLE_FONT: int = 16
const BUTTON_FONT: int = 11
const BUTTON_WIDTH: float = 140.0
const DIM_COLOR: Color = Color(0.0, 0.0, 0.0, 0.55)

@export var title_text: String = "Pausa"
@export var resume_text: String = "Continuar"
@export var quit_text: String = "Volver al menú"
@export_file("*.tscn") var main_menu_scene: String = "res://src/ui/main_menu/main_menu.tscn"

var _root: Control
var _resume_button: Button


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 60
	_build_layout()
	_root.hide()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed(&"pause"):
		return
	if _root.visible:
		get_viewport().set_input_as_handled()
		_resume()
	elif not get_tree().paused and not SceneManager.is_changing:
		get_viewport().set_input_as_handled()
		_open()


func _open() -> void:
	get_tree().paused = true
	_root.show()
	_resume_button.grab_focus()


func _resume() -> void:
	_root.hide()
	get_tree().paused = false


func _build_layout() -> void:
	_root = ColorRect.new()
	(_root as ColorRect).color = DIM_COLOR
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_root)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.add_child(center)
	var panel: PanelContainer = UiFactory.make_panel()
	center.add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", 6)
	panel.add_child(column)
	var title: Label = UiFactory.make_label(title_text, TITLE_FONT, UiFactory.ACCENT_COLOR)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	_resume_button = UiFactory.make_button(resume_text, BUTTON_FONT)
	_resume_button.custom_minimum_size.x = BUTTON_WIDTH
	_resume_button.pressed.connect(_resume)
	column.add_child(_resume_button)
	var quit_button: Button = UiFactory.make_button(quit_text, BUTTON_FONT)
	quit_button.pressed.connect(_on_quit_button_pressed)
	column.add_child(quit_button)


func _on_quit_button_pressed() -> void:
	SceneManager.change_scene(main_menu_scene)
