class_name Hud
extends CanvasLayer
## Interfaz durante el juego: objetivo y mensajes y, en la noche, vida, nivel, dash, reloj del
## amanecer, avance de la obra y la barra del capataz.
##
## No lee el estado del juego: el nivel le pasa los valores con sus métodos públicos.

const MESSAGE_DURATION: float = 2.5
const MESSAGE_FADE: float = 0.4
const MARGIN: float = 6.0
const SMALL_FONT: int = 9
const NORMAL_FONT: int = 10
const BAR_SIZE: Vector2 = Vector2(96, 7)
const SMALL_BAR_SIZE: Vector2 = Vector2(96, 3)
const WIDE_BAR_SIZE: Vector2 = Vector2(200, 6)
const HEALTH_COLOR: Color = Color("d8433b")
const DASH_COLOR: Color = Color("6fc3d8")
const WORK_COLOR: Color = Color("c26a2c")
const BOSS_COLOR: Color = Color("a3243b")
const SECONDS_PER_MINUTE: int = 60

## Muestra el panel de la noche (vida, reloj, obra).
@export var is_night_mode: bool = false
@export var level_format: String = "Nv %d · %d diablillos"
@export var health_format: String = "%d/%d"
@export var clock_format: String = "Amanecer en %d:%02d"
@export var work_format: String = "Obra de los diablillos %d%%"

var _objective_label: Label
var _message_label: Label
var _message_tween: Tween
var _night_root: Control
var _health_bar: ProgressBar
var _health_label: Label
var _dash_bar: ProgressBar
var _level_label: Label
var _xp_bar: ProgressBar
var _clock_label: Label
var _work_bar: ProgressBar
var _work_label: Label
var _boss_box: VBoxContainer
var _boss_label: Label
var _boss_bar: ProgressBar


func _ready() -> void:
	_build_objective()
	_build_message()
	_build_night_panel()
	_night_root.visible = is_night_mode


## Muestra el objetivo actual en la esquina.
func set_objective(text: String) -> void:
	_objective_label.text = text


## Muestra un mensaje breve en el centro, que se desvanece solo.
func show_message(text: String) -> void:
	_message_label.text = text
	_message_label.modulate.a = 1.0
	if _message_tween != null:
		_message_tween.kill()
	_message_tween = create_tween()
	_message_tween.tween_interval(MESSAGE_DURATION)
	_message_tween.tween_property(_message_label, "modulate:a", 0.0, MESSAGE_FADE)


## Actualiza la barra de vida.
func set_health(current: int, maximum: int) -> void:
	_health_bar.value = float(current) / float(maxi(maximum, 1))
	_health_label.text = health_format % [current, maximum]


## Actualiza la recarga del dash (0 a 1).
func set_dash_charge(ratio: float) -> void:
	_dash_bar.value = ratio


## Actualiza el nivel, la experiencia y los diablillos derrotados.
func set_progress(level: int, xp_ratio: float, kills: int) -> void:
	_level_label.text = level_format % [level, kills]
	_xp_bar.value = xp_ratio


## Actualiza el reloj del amanecer.
func set_clock(remaining_seconds: float) -> void:
	var seconds: int = ceili(maxf(remaining_seconds, 0.0))
	_clock_label.text = clock_format % [seconds / SECONDS_PER_MINUTE, seconds % SECONDS_PER_MINUTE]


## Actualiza el avance de la obra de los diablillos (0 a 1).
func set_work_progress(ratio: float) -> void:
	_work_bar.value = ratio
	_work_label.text = work_format % floori(ratio * 100.0)


## Muestra la barra de vida del jefe con su nombre.
func show_boss(boss_name: String) -> void:
	_boss_label.text = boss_name
	_boss_bar.value = 1.0
	_boss_box.show()


## Actualiza la vida del jefe.
func set_boss_health(current: int, maximum: int) -> void:
	_boss_bar.value = float(current) / float(maxi(maximum, 1))


## Oculta la barra del jefe.
func hide_boss() -> void:
	_boss_box.hide()


func _build_objective() -> void:
	_objective_label = UiFactory.make_label("", NORMAL_FONT, UiFactory.ACCENT_COLOR)
	_objective_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_objective_label.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_objective_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_objective_label.position = Vector2(-MARGIN, MARGIN)
	add_child(_objective_label)


func _build_message() -> void:
	_message_label = UiFactory.make_label("", NORMAL_FONT + 2, UiFactory.ACCENT_COLOR)
	_message_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_message_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message_label.position.y = 70.0
	_message_label.modulate.a = 0.0
	add_child(_message_label)


func _build_night_panel() -> void:
	_night_root = Control.new()
	_night_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_night_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_night_root)
	_build_player_panel()
	_build_night_center()
	_build_boss_panel()


func _build_player_panel() -> void:
	var column := VBoxContainer.new()
	column.position = Vector2(MARGIN, MARGIN)
	column.add_theme_constant_override(&"separation", 1)
	_night_root.add_child(column)
	_health_bar = UiFactory.make_bar(HEALTH_COLOR, BAR_SIZE)
	column.add_child(_health_bar)
	_health_label = UiFactory.make_label("", SMALL_FONT)
	_health_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_health_bar.add_child(_health_label)
	_level_label = UiFactory.make_label("", SMALL_FONT)
	column.add_child(_level_label)
	_xp_bar = UiFactory.make_bar(Color("7fd8e8"), SMALL_BAR_SIZE)
	column.add_child(_xp_bar)
	_dash_bar = UiFactory.make_bar(DASH_COLOR, SMALL_BAR_SIZE)
	_dash_bar.value = 1.0
	column.add_child(_dash_bar)


func _build_night_center() -> void:
	var column := VBoxContainer.new()
	column.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	column.grow_horizontal = Control.GROW_DIRECTION_BOTH
	column.position.y = MARGIN
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	_night_root.add_child(column)
	_clock_label = UiFactory.make_label("", NORMAL_FONT, UiFactory.ACCENT_COLOR)
	_clock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(_clock_label)
	_work_bar = UiFactory.make_bar(WORK_COLOR, WIDE_BAR_SIZE)
	column.add_child(_work_bar)
	_work_label = UiFactory.make_label("", SMALL_FONT)
	_work_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(_work_label)


func _build_boss_panel() -> void:
	_boss_box = VBoxContainer.new()
	_boss_box.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_boss_box.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_boss_box.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_boss_box.position.y -= MARGIN
	_night_root.add_child(_boss_box)
	_boss_label = UiFactory.make_label("", SMALL_FONT, Color("f08a8a"))
	_boss_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_boss_box.add_child(_boss_label)
	_boss_bar = UiFactory.make_bar(BOSS_COLOR, WIDE_BAR_SIZE)
	_boss_box.add_child(_boss_bar)
	_boss_box.hide()
