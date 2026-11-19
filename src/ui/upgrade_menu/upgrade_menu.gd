class_name UpgradeMenu
extends CanvasLayer
## Menú que ofrece mejoras al subir de nivel en la noche.
##
## El nivel pausa el juego y llama a [method open]; el menú emite [signal upgrade_chosen] con la
## elección (clic, Enter o las teclas 1, 2 y 3).

## El jugador eligió [param upgrade].
signal upgrade_chosen(upgrade: UpgradeData)

const TITLE_FONT: int = 14
const OPTION_FONT: int = 10
const OPTION_WIDTH: float = 260.0
const DIM_COLOR: Color = Color(0.0, 0.0, 0.0, 0.5)
const CHOICE_ACTIONS: Array[StringName] = [&"select_1", &"select_2", &"select_3"]

@export var title_text: String = "¡Subiste de nivel! Elige una mejora"
@export var option_format: String = "%d. %s — %s"
## Sonido al subir de nivel (opcional).
@export var open_sound: SoundEffect

var _options: Array[UpgradeData] = []
var _root: ColorRect
var _options_box: VBoxContainer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 55
	_build_layout()
	_root.hide()


func _unhandled_input(event: InputEvent) -> void:
	if not _root.visible:
		return
	for i: int in mini(CHOICE_ACTIONS.size(), _options.size()):
		if event.is_action_pressed(CHOICE_ACTIONS[i]):
			get_viewport().set_input_as_handled()
			_choose(i)
			return


## Muestra las mejoras [param options] para que el jugador elija una.
func open(options: Array[UpgradeData]) -> void:
	if options.is_empty():
		push_warning("UpgradeMenu: no hay mejoras para ofrecer.")
		return
	_options = options
	for child: Node in _options_box.get_children():
		child.queue_free()
	for i: int in options.size():
		var upgrade: UpgradeData = options[i]
		var button: Button = UiFactory.make_button(
			option_format % [i + 1, upgrade.title, upgrade.description], OPTION_FONT
		)
		button.custom_minimum_size.x = OPTION_WIDTH
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.pressed.connect(_choose.bind(i))
		_options_box.add_child(button)
	_root.show()
	AudioManager.play_effect(open_sound)
	(_options_box.get_child(0) as Button).call_deferred(&"grab_focus")


## [code]true[/code] mientras el menú está abierto.
func is_open() -> bool:
	return _root.visible


func _choose(index: int) -> void:
	if not _root.visible:
		return
	_root.hide()
	upgrade_chosen.emit(_options[index])


func _build_layout() -> void:
	_root = ColorRect.new()
	_root.color = DIM_COLOR
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
	_options_box = VBoxContainer.new()
	_options_box.add_theme_constant_override(&"separation", 4)
	column.add_child(_options_box)
