extends GutTest
## Pruebas de la lógica de la noche: experiencia, reloj, balance y mejoras.


func test_experience_levels_up_when_reaching_threshold() -> void:
	var tracker := ExperienceTracker.new(5, 3)
	assert_eq(tracker.add_xp(4), 0)
	assert_eq(tracker.add_xp(1), 1)
	assert_eq(tracker.level, 2)
	assert_eq(tracker.xp, 0)


func test_experience_can_gain_several_levels_at_once() -> void:
	var tracker := ExperienceTracker.new(5, 3)
	# 5 (nivel 1 a 2) + 8 (nivel 2 a 3) = 13, y sobran 2.
	assert_eq(tracker.add_xp(15), 2)
	assert_eq(tracker.level, 3)
	assert_eq(tracker.xp, 2)


func test_experience_ignores_non_positive_amounts() -> void:
	var tracker := ExperienceTracker.new()
	assert_eq(tracker.add_xp(0), 0)
	assert_eq(tracker.xp, 0)


func test_clock_reaches_dawn_once() -> void:
	var clock: NightClock = autofree(NightClock.new())
	clock.duration = 10.0
	watch_signals(clock)
	clock.start()
	clock.advance(6.0)
	assert_almost_eq(clock.get_progress(), 0.6, 0.001)
	clock.advance(6.0)
	clock.advance(1.0)
	assert_eq(clock.get_remaining(), 0.0)
	assert_signal_emit_count(clock, "dawn_reached", 1)


func test_clock_does_not_advance_when_stopped() -> void:
	var clock: NightClock = autofree(NightClock.new())
	clock.advance(5.0)
	assert_eq(clock.elapsed, 0.0)


func test_work_progress_never_reaches_completion() -> void:
	var config := NightConfig.new()
	config.max_work_progress = 0.99
	assert_almost_eq(config.get_work_progress(1.0), 0.99, 0.001)


func test_difficulty_interpolates_spawn_interval() -> void:
	var config := NightConfig.new()
	config.spawn_interval_start = 1.0
	config.spawn_interval_end = 0.2
	assert_almost_eq(config.get_spawn_interval(0.5), 0.6, 0.001)
	assert_almost_eq(config.get_spawn_interval(2.0), 0.2, 0.001)


func test_attack_speed_upgrade_reduces_interval() -> void:
	var stats := PlayerStats.new()
	stats.attack_interval = 1.0
	var upgrade := UpgradeData.new()
	upgrade.stat = UpgradeData.Stat.ATTACK_SPEED
	upgrade.amount = 0.25
	stats.apply_upgrade(upgrade)
	assert_almost_eq(stats.attack_interval, 0.75, 0.001)


func test_interval_upgrades_have_a_minimum() -> void:
	var stats := PlayerStats.new()
	var upgrade := UpgradeData.new()
	upgrade.stat = UpgradeData.Stat.DASH_COOLDOWN
	upgrade.amount = 0.99
	stats.apply_upgrade(upgrade)
	assert_almost_eq(stats.dash_cooldown, PlayerStats.MIN_INTERVAL, 0.001)


func test_projectile_upgrade_adds_projectiles() -> void:
	var stats := PlayerStats.new()
	var upgrade: UpgradeData = load("res://src/data/upgrades/sling.tres")
	stats.apply_upgrade(upgrade)
	assert_eq(stats.projectile_count, 2)
