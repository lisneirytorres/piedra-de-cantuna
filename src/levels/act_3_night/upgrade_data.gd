class_name UpgradeData
extends Resource
## Una mejora que el jugador elige al subir de nivel durante la noche.

## Estadística de [PlayerStats] que modifica la mejora.
enum Stat {
	MOVE_SPEED,
	ATTACK_DAMAGE,
	ATTACK_SPEED,
	MAX_HEALTH,
	DASH_COOLDOWN,
	PROJECTILE_COUNT,
	ATTACK_RANGE,
}

@export var id: StringName = &""
## Nombre corto que se muestra en el menú de mejoras.
@export var title: String = ""
## Descripción breve del efecto.
@export var description: String = ""
@export var stat: Stat = Stat.ATTACK_DAMAGE
## Cantidad que se suma. En [constant Stat.ATTACK_SPEED] y [constant Stat.DASH_COOLDOWN] es la
## fracción que se reduce (0.15 = 15 % menos de espera).
@export var amount: float = 1.0
