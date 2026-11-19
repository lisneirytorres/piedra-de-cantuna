extends Control
## Menú principal con el botón "Jugar".
##
## En web el audio solo se activa tras la primera interacción, por eso la partida empieza con un
## clic.

const TITLE_FONT: int = 28
const SUBTITLE_FONT: int = 10
const BUTTON_FONT: int = 12
const BUTTON_WIDTH: float = 150.0

@export var title_text: String = "La Piedra de Cantuña"
@export_multiline var subtitle_text: String = ""
@export var play_text: String = "Jugar"
@export var credits_text: String = "Créditos"
@export var controls_text: String = ""
@export_file("*.tscn") var first_scene: String
@export_file("*.tscn") var credits_scene: String
@export var music: MusicTrack

var _play_button: Button


func _ready() -> void:
	_build_layout()
	_play_button.grab_focus()
	# En web, el navegador retiene el audio hasta la primera interacción (el clic en "Jugar").
	AudioManager.play_track(music)


func _build_layout() -> void:
	var column := VBoxContainer.new()
	column.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	column.grow_horizontal = Control.GROW_DIRECTION_BOTH
	column.grow_vertical = Control.GROW_DIRECTION_BOTH
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override(&"separation", 8)
	add_child(column)
	column.add_child(_make_centered_label(title_text, TITLE_FONT, UiFactory.ACCENT_COLOR))
	column.add_child(_make_centered_label(subtitle_text, SUBTITLE_FONT, UiFactory.TEXT_COLOR))
	_play_button = _make_menu_button(play_text, _on_play_button_pressed)
	column.add_child(_play_button)
	column.add_child(_make_menu_button(credits_text, _on_credits_button_pressed))
	column.add_child(_make_centered_label(controls_text, SUBTITLE_FONT - 1, UiFactory.TEXT_COLOR))


func _make_centered_label(text: String, font_size: int, color: Color) -> Label:
	var label: Label = UiFactory.make_label(text, font_size, color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return label


func _make_menu_button(text: String, callback: Callable) -> Button:
	var button: Button = UiFactory.make_button(text, BUTTON_FONT)
	button.custom_minimum_size.x = BUTTON_WIDTH
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.pressed.connect(callback)
	return button


func _on_play_button_pressed() -> void:
	GameState.reset()
	SceneManager.change_scene(first_scene)


func _on_credits_button_pressed() -> void:
	SceneManager.change_scene(credits_scene)
