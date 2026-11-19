@tool
class_name Prop
extends Node2D
## Objeto del escenario con el que se interactúa: una piedra, un hueco del atrio, un escondite o un
## objeto de misión.
##
## No decide qué pasa al usarlo: emite [signal used] y el nivel aplica las reglas.

## El jugador usó este objeto.
signal used(prop: Prop)

## Qué representa el objeto.
enum Kind { STONE, SLOT, HIDEOUT, ITEM }
## Forma de la piedra o del hueco (el puzzle exige que coincidan).
enum StoneShape { SQUARE, LONG, ARCH }

const STONE_COLOR: Color = Color("a39a8c")
const STONE_EDGE_COLOR: Color = Color("5e574f")
const SLOT_COLOR: Color = Color(0.1, 0.08, 0.1, 0.55)
const HIDEOUT_COLOR: Color = Color("57525a")
const ITEM_COLOR: Color = Color("8a8f96")
const HANDLE_COLOR: Color = Color("6b4a2f")
const HIGHLIGHT_COLOR: Color = Color(1.0, 0.85, 0.35, 0.35)
const HIGHLIGHT_RADIUS: float = 14.0
const SHAPE_SIZES: Array[Vector2] = [Vector2(12, 12), Vector2(20, 8), Vector2(16, 12)]

@export var kind: Kind = Kind.STONE:
	set(value):
		kind = value
		queue_redraw()
@export var stone_shape: StoneShape = StoneShape.SQUARE:
	set(value):
		stone_shape = value
		queue_redraw()
## Dibuja un halo para llamar la atención del jugador.
@export var is_highlighted: bool = false:
	set(value):
		is_highlighted = value
		queue_redraw()
## Verbo del aviso de interacción.
@export var prompt_text: String = "Usar"

## [code]true[/code] cuando un hueco ya recibió su piedra o un escondite ya se usó.
var is_filled: bool = false

@onready var _interactable: InteractableComponent = $InteractableComponent


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_interactable.prompt_text = prompt_text
	_interactable.interacted.connect(_on_interactable_interacted)


func _draw() -> void:
	if is_highlighted:
		draw_circle(Vector2.ZERO, HIGHLIGHT_RADIUS, HIGHLIGHT_COLOR)
	match kind:
		Kind.STONE:
			_draw_stone(STONE_COLOR)
		Kind.SLOT:
			_draw_slot()
		Kind.HIDEOUT:
			_draw_hideout()
		Kind.ITEM:
			_draw_item()


## Muestra u oculta el objeto y su interacción.
func set_active(value: bool) -> void:
	visible = value
	_interactable.is_enabled = value


## Marca el hueco o escondite como lleno: se dibuja la piedra y ya no se puede usar.
func fill() -> void:
	is_filled = true
	is_highlighted = false
	_interactable.is_enabled = false
	queue_redraw()


func _shape_rect() -> Rect2:
	var size: Vector2 = SHAPE_SIZES[stone_shape]
	return Rect2(-size * 0.5, size)


func _draw_stone(color: Color) -> void:
	var rect: Rect2 = _shape_rect()
	draw_rect(rect.grow(1.0), STONE_EDGE_COLOR)
	draw_rect(rect, color)
	if stone_shape == StoneShape.ARCH:
		draw_circle(Vector2(0, rect.end.y), rect.size.x * 0.25, STONE_EDGE_COLOR)


func _draw_slot() -> void:
	if is_filled:
		_draw_stone(STONE_COLOR.darkened(0.1))
		return
	var rect: Rect2 = _shape_rect()
	draw_rect(rect, SLOT_COLOR)
	draw_rect(rect, STONE_COLOR, false, 1.0)
	if stone_shape == StoneShape.ARCH:
		draw_circle(Vector2(0, rect.end.y), rect.size.x * 0.25, STONE_COLOR)


func _draw_hideout() -> void:
	draw_rect(Rect2(-9, -6, 18, 12), HIDEOUT_COLOR.darkened(0.3))
	draw_rect(Rect2(-8, -5, 16, 10), HIDEOUT_COLOR)
	draw_line(Vector2(-8, 0), Vector2(8, 0), HIDEOUT_COLOR.darkened(0.4))
	if is_filled:
		draw_rect(Rect2(-4, -2, 8, 4), STONE_COLOR)


func _draw_item() -> void:
	draw_rect(Rect2(-6, -1, 9, 2), ITEM_COLOR)
	draw_rect(Rect2(3, -2, 4, 4), HANDLE_COLOR)


func _on_interactable_interacted(_by: Node2D) -> void:
	used.emit(self)
