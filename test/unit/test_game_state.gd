extends GutTest
## Pruebas de las banderas de historia y las condiciones de GameState.

# Los autoloads no tienen class_name (chocaría con el nombre del singleton):
# se instancia una copia aislada desde su script.
const GameStateScript: GDScript = preload("res://src/autoload/game_state.gd")

var _state: Node


func before_each() -> void:
	_state = autofree(GameStateScript.new())


func test_set_flag_activates_flag() -> void:
	assert_false(_state.has_flag(&"bargained_pact"))
	_state.set_flag(&"bargained_pact")
	assert_true(_state.has_flag(&"bargained_pact"))


func test_set_flag_emits_signal_only_on_change() -> void:
	watch_signals(_state)
	_state.set_flag(&"met_friar")
	_state.set_flag(&"met_friar")
	assert_signal_emit_count(_state, "flag_changed", 1)


func test_set_flag_ignores_empty_flag() -> void:
	_state.set_flag(&"")
	assert_false(_state.has_flag(&""))


func test_empty_condition_is_always_met() -> void:
	assert_true(_state.meets_condition(&""))


func test_condition_requires_active_flag() -> void:
	assert_false(_state.meets_condition(&"helped_worker"))
	_state.set_flag(&"helped_worker")
	assert_true(_state.meets_condition(&"helped_worker"))


func test_negated_condition_requires_inactive_flag() -> void:
	assert_true(_state.meets_condition(&"!bargained_pact"))
	_state.set_flag(&"bargained_pact")
	assert_false(_state.meets_condition(&"!bargained_pact"))


func test_reset_clears_flags_and_attempts() -> void:
	_state.set_flag(&"knows_hideout")
	_state.register_night_attempt()
	_state.reset()
	assert_false(_state.has_flag(&"knows_hideout"))
	assert_eq(_state.night_attempts, 0)
