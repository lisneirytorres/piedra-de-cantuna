extends Control
## Epílogo: narra el desenlace según las decisiones del jugador y pasa a los créditos.
##
## Muestra un párrafo a la vez con un fundido; [code]interact[/code] o clic avanza.

const PARAGRAPH_FONT: int = 12
const HINT_FONT: int = 8
const FADE_DURATION: float = 0.6
const TEXT_WIDTH: float = 460.0

@export var epilogue: EpilogueData
@export var music: MusicTrack
@export_file("*.tscn") var credits_scene: String
@export var hint_text: String = "E / clic ▸"

var _paragraphs: PackedStringArray = PackedStringArray()
var _index: int = -1
var _label: Label
var _tween: Tween


func _ready() -> void:
	_build_layout()
	AudioManager.play_track(music)
	if epilogue == null or not epilogue.is_valid():
		push_error("Epilogue: los datos del epílogo faltan o son incoherentes.")
		return
	_paragraphs = epilogue.get_paragraphs(GameState.meets_condition)
	_show_next()


func _unhandled_input(event: InputEvent) -> void:
	var mouse := event as InputEventMouseButton
	var is_click: bool = mouse != null and mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT
	if event.is_action_pressed(&"interact") or event.is_action_pressed(&"ui_accept") or is_click:
		get_viewport().set_input_as_handled()
		_show_next()


func _show_next() -> void:
	if _tween != null and _tween.is_running():
		return
	_index += 1
	if _index >= _paragraphs.size():
		SceneManager.change_scene(credits_scene)
		return
	_label.text = _paragraphs[_index]
	_label.modulate.a = 0.0
	_tween = create_tween()
	_tween.tween_property(_label, "modulate:a", 1.0, FADE_DURATION)


func _build_layout() -> void:
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	_label = UiFactory.make_label("", PARAGRAPH_FONT)
	_label.custom_minimum_size.x = TEXT_WIDTH
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(_label)
	var hint: Label = UiFactory.make_label(hint_text, HINT_FONT)
	hint.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	hint.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	hint.grow_vertical = Control.GROW_DIRECTION_BEGIN
	add_child(hint)
