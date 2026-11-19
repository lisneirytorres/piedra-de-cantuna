extends Control
## Créditos finales: equipo, recursos, ESPOL, PyWeekend y la leyenda (obligatorios por las bases).
##
## El texto sube solo; [code]interact[/code] lo acelera y, al terminar, vuelve al menú principal.

const HEADING_FONT: int = 13
const LINE_FONT: int = 10
const SCROLL_SPEED: float = 22.0
const FAST_MULTIPLIER: float = 4.0
const LINE_SEPARATION: int = 4

@export var credits: CreditsData
@export var music: MusicTrack
@export_file("*.tscn") var main_menu_scene: String
@export var hint_text: String = "Mantén E para acelerar · Esc para salir"

var _column: VBoxContainer
var _has_finished: bool = false


func _ready() -> void:
	_build_layout()
	AudioManager.play_track(music)


func _process(delta: float) -> void:
	if _has_finished:
		return
	var speed: float = SCROLL_SPEED
	if Input.is_action_pressed(&"interact"):
		speed *= FAST_MULTIPLIER
	_column.position.y -= speed * delta
	if _column.position.y + _column.size.y < 0.0:
		_finish()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause"):
		get_viewport().set_input_as_handled()
		_finish()


func _finish() -> void:
	if _has_finished:
		return
	_has_finished = true
	SceneManager.change_scene(main_menu_scene)


func _build_layout() -> void:
	_column = VBoxContainer.new()
	_column.add_theme_constant_override(&"separation", LINE_SEPARATION)
	_column.position = Vector2(0.0, get_viewport_rect().size.y)
	_column.custom_minimum_size.x = get_viewport_rect().size.x
	add_child(_column)
	if credits == null:
		push_error("Credits: faltan los datos de créditos.")
		return
	for line: String in credits.lines:
		_column.add_child(_make_line(line))
	var hint: Label = UiFactory.make_label(hint_text, LINE_FONT - 2, UiFactory.TEXT_COLOR)
	hint.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	hint.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	hint.grow_vertical = Control.GROW_DIRECTION_BEGIN
	add_child(hint)


func _make_line(line: String) -> Label:
	var is_heading: bool = CreditsData.is_heading(line)
	var label: Label = UiFactory.make_label(
		CreditsData.strip_heading(line),
		HEADING_FONT if is_heading else LINE_FONT,
		UiFactory.ACCENT_COLOR if is_heading else UiFactory.TEXT_COLOR
	)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return label
