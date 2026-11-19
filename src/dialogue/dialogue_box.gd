class_name DialogueBox
extends CanvasLayer
## Caja de diálogo: muestra las conversaciones que se piden por
## [code]Events.dialogue_requested[/code].
##
## Escribe el texto letra por letra, avanza con [code]interact[/code] o clic y, al final, ofrece las
## decisiones (con clic o con las teclas 1, 2 y 3). Al terminar activa las banderas de la decisión
## en
## [code]GameState[/code] y emite [code]Events.dialogue_finished[/code].

const CHARACTERS_PER_SECOND: float = 50.0
const BOX_HEIGHT: float = 78.0
const SCREEN_MARGIN: float = 8.0
const SPEAKER_FONT_SIZE: int = 11
const TEXT_FONT_SIZE: int = 11
const HINT_FONT_SIZE: int = 8
const NARRATOR_COLOR: Color = Color("b9c4d6")
const CHOICE_ACTIONS: Array[StringName] = [&"select_1", &"select_2", &"select_3"]

## Texto de ayuda en la esquina de la caja.
@export var continue_hint: String = "E / clic ▸"
## Formato de cada decisión: número y texto.
@export var choice_format: String = "%d. %s"
## Sonido al mostrar cada línea (opcional).
@export var line_sound: SoundEffect

var _dialogue: DialogueData
var _line_index: int = 0
var _visible_characters: float = 0.0
var _is_choosing: bool = false

var _panel: PanelContainer
var _speaker_label: Label
var _text_label: Label
var _choices_box: VBoxContainer
var _hint_label: Label


func _ready() -> void:
	# La caja debe funcionar aunque el nivel pause el juego durante la conversación.
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_layout()
	_panel.hide()
	Events.dialogue_requested.connect(start)


func _process(delta: float) -> void:
	if not is_active() or not _is_typing():
		return
	_visible_characters += CHARACTERS_PER_SECOND * delta
	_text_label.visible_characters = int(_visible_characters)


func _unhandled_input(event: InputEvent) -> void:
	if not is_active():
		return
	if _is_choosing:
		_handle_choice_input(event)
		return
	if (
		event.is_action_pressed(&"interact")
		or event.is_action_pressed(&"ui_accept")
		or _is_click(event)
	):
		get_viewport().set_input_as_handled()
		_advance()


## [code]true[/code] mientras hay una conversación en pantalla.
func is_active() -> bool:
	return _dialogue != null


## Empieza a mostrar [param dialogue]. Se ignora si ya hay otra conversación en curso.
func start(dialogue: DialogueData) -> void:
	if is_active() or dialogue == null:
		return
	if not dialogue.is_valid():
		push_error("DialogueBox: el diálogo '%s' tiene datos incoherentes." % dialogue.id)
		return
	_dialogue = dialogue
	_line_index = 0
	_panel.show()
	Events.dialogue_started.emit(dialogue)
	_show_line()


func _is_typing() -> bool:
	return (
		_text_label.visible_characters >= 0
		and _text_label.visible_characters < _text_label.text.length()
	)


func _is_click(event: InputEvent) -> bool:
	var mouse := event as InputEventMouseButton
	return mouse != null and mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT


func _advance() -> void:
	if _is_typing():
		_text_label.visible_characters = -1
		return
	_line_index += 1
	if _line_index < _dialogue.get_line_count():
		_show_line()
	elif _dialogue.has_choices():
		_show_choices()
	else:
		_finish(DialogueData.NO_CHOICE)


func _show_line() -> void:
	var speaker: String = _dialogue.get_speaker(_line_index)
	_speaker_label.text = speaker
	_speaker_label.visible = not speaker.is_empty()
	_text_label.text = _dialogue.get_line(_line_index)
	var text_color: Color = UiFactory.TEXT_COLOR if not speaker.is_empty() else NARRATOR_COLOR
	_text_label.add_theme_color_override(&"font_color", text_color)
	_visible_characters = 0.0
	_text_label.visible_characters = 0
	_hint_label.show()
	AudioManager.play_effect(line_sound)


func _show_choices() -> void:
	_is_choosing = true
	_hint_label.hide()
	for i: int in _dialogue.choices.size():
		var button: Button = UiFactory.make_button(
			choice_format % [i + 1, _dialogue.choices[i]], TEXT_FONT_SIZE
		)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.pressed.connect(_finish.bind(i))
		_choices_box.add_child(button)
	(_choices_box.get_child(0) as Button).grab_focus()


func _handle_choice_input(event: InputEvent) -> void:
	for i: int in mini(CHOICE_ACTIONS.size(), _dialogue.choices.size()):
		if event.is_action_pressed(CHOICE_ACTIONS[i]):
			get_viewport().set_input_as_handled()
			_finish(i)
			return


func _finish(choice_index: int) -> void:
	var finished: DialogueData = _dialogue
	for flag: StringName in finished.get_flags_to_set(choice_index):
		GameState.set_flag(flag)
	for child: Node in _choices_box.get_children():
		child.queue_free()
	_is_choosing = false
	_dialogue = null
	_panel.hide()
	Events.dialogue_finished.emit(finished, choice_index)


func _build_layout() -> void:
	_panel = UiFactory.make_panel()
	_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_panel.offset_left = SCREEN_MARGIN
	_panel.offset_right = -SCREEN_MARGIN
	_panel.offset_top = -BOX_HEIGHT - SCREEN_MARGIN
	_panel.offset_bottom = -SCREEN_MARGIN
	_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	add_child(_panel)
	var column := VBoxContainer.new()
	_panel.add_child(column)
	_speaker_label = UiFactory.make_label("", SPEAKER_FONT_SIZE, UiFactory.ACCENT_COLOR)
	column.add_child(_speaker_label)
	_text_label = UiFactory.make_label("", TEXT_FONT_SIZE)
	_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(_text_label)
	_choices_box = VBoxContainer.new()
	column.add_child(_choices_box)
	_hint_label = UiFactory.make_label(continue_hint, HINT_FONT_SIZE, NARRATOR_COLOR)
	_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	column.add_child(_hint_label)
