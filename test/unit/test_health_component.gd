extends GutTest
## Pruebas del componente de vida.

var _health: HealthComponent


func before_each() -> void:
	_health = HealthComponent.new()
	_health.max_health = 50
	add_child_autofree(_health)


func test_starts_at_max_health() -> void:
	assert_eq(_health.current_health, 50)


func test_damage_reduces_health() -> void:
	_health.damage(20)
	assert_eq(_health.current_health, 30)


func test_lethal_damage_emits_died_once() -> void:
	watch_signals(_health)
	_health.damage(80)
	_health.damage(10)
	assert_eq(_health.current_health, 0)
	assert_true(_health.is_dead)
	assert_signal_emit_count(_health, "died", 1)


func test_heal_does_not_exceed_max() -> void:
	_health.damage(10)
	_health.heal(100)
	assert_eq(_health.current_health, 50)


func test_increase_max_also_heals() -> void:
	_health.damage(10)
	_health.increase_max(25)
	assert_eq(_health.max_health, 75)
	assert_eq(_health.current_health, 65)


func test_negative_damage_is_ignored() -> void:
	_health.damage(-5)
	assert_eq(_health.current_health, 50)
