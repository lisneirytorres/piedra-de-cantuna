class_name PlayerStats
extends Resource
## Estadísticas de Cantuña: movimiento, dash y ataque.
##
## Los valores base viven en [code]src/data/player/player_stats.tres[/code]. El jugador
## trabaja sobre una copia, para que las mejoras de la noche no alteren el recurso original.

## Valor mínimo de los tiempos de espera que se reducen con mejoras, para que nunca lleguen a cero.
const MIN_INTERVAL: float = 0.15

@export_group("Movimiento")
@export var move_speed: float = 90.0
## Multiplicador de velocidad mientras carga una piedra.
@export var carry_speed_multiplier: float = 0.6
@export var dash_speed: float = 260.0
@export var dash_duration: float = 0.18
@export var dash_cooldown: float = 1.2

@export_group("Combate")
@export var max_health: int = 100
@export var attack_damage: int = 10
## Segundos entre ataques.
@export var attack_interval: float = 0.9
@export var attack_range: float = 150.0
@export var projectile_count: int = 1
@export var projectile_speed: float = 230.0


## Aplica una mejora a estas estadísticas.
func apply_upgrade(upgrade: UpgradeData) -> void:
	match upgrade.stat:
		UpgradeData.Stat.MOVE_SPEED:
			move_speed += upgrade.amount
		UpgradeData.Stat.ATTACK_DAMAGE:
			attack_damage += roundi(upgrade.amount)
		UpgradeData.Stat.ATTACK_SPEED:
			attack_interval = maxf(attack_interval * (1.0 - upgrade.amount), MIN_INTERVAL)
		UpgradeData.Stat.MAX_HEALTH:
			max_health += roundi(upgrade.amount)
		UpgradeData.Stat.DASH_COOLDOWN:
			dash_cooldown = maxf(dash_cooldown * (1.0 - upgrade.amount), MIN_INTERVAL)
		UpgradeData.Stat.PROJECTILE_COUNT:
			projectile_count += roundi(upgrade.amount)
		UpgradeData.Stat.ATTACK_RANGE:
			attack_range += upgrade.amount
