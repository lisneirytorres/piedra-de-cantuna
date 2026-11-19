extends GutTest
## Pruebas del epílogo: los párrafos dependen de las decisiones del jugador.

const GameStateScript: GDScript = preload("res://src/autoload/game_state.gd")
const EPILOGUE_PATH: String = "res://src/data/epilogue/epilogue.tres"

var _state: Node
var _epilogue: EpilogueData


func before_each() -> void:
	_state = autofree(GameStateScript.new())
	_epilogue = load(EPILOGUE_PATH)


func test_epilogue_resource_is_valid() -> void:
	assert_true(_epilogue.is_valid())


func test_bargained_pact_changes_the_ending() -> void:
	var plain: PackedStringArray = _epilogue.get_paragraphs(_state.meets_condition)
	_state.set_flag(&"bargained_pact")
	var bargained: PackedStringArray = _epilogue.get_paragraphs(_state.meets_condition)
	assert_eq(plain.size(), bargained.size())
	assert_ne(plain, bargained)


func test_helping_the_worker_adds_a_paragraph() -> void:
	var before: int = _epilogue.get_paragraphs(_state.meets_condition).size()
	_state.set_flag(&"helped_worker")
	assert_eq(_epilogue.get_paragraphs(_state.meets_condition).size(), before + 1)
