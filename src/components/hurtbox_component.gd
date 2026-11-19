class_name HurtboxComponent
extends Area2D
## Zona que recibe daño de los [HitboxComponent] que la tocan.
##
## Con [member invulnerability_time] mayor que cero, después de cada golpe ignora el daño
## durante ese tiempo y luego vuelve a revisar si sigue tocando un hitbox (daño por contacto
## continuo).

## Recibió un golpe de [param amount] puntos.
signal hurt(amount: int)

## Segundos de invulnerabilidad tras cada golpe (0 = sin invulnerabilidad).
@export var invulnerability_time: float = 0.0

var _is_in_iframes: bool = false
var _is_ignoring_hits: bool = false
var _iframes_timer: Timer


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	if invulnerability_time > 0.0:
		_iframes_timer = Timer.new()
		_iframes_timer.one_shot = true
		_iframes_timer.wait_time = invulnerability_time
		_iframes_timer.timeout.connect(_on_iframes_timer_timeout)
		add_child(_iframes_timer)


## Activa o desactiva la inmunidad manual (por ejemplo, durante el dash).
func set_ignoring_hits(value: bool) -> void:
	_is_ignoring_hits = value
	if not value:
		_check_overlapping_hitboxes()


## [code]true[/code] si ahora mismo no puede recibir daño.
func is_invulnerable() -> bool:
	return _is_in_iframes or _is_ignoring_hits


func _try_take_hit(area: Area2D) -> bool:
	var hitbox := area as HitboxComponent
	if hitbox == null or not hitbox.is_active or is_invulnerable():
		return false
	hitbox.register_hit(self)
	hurt.emit(hitbox.damage)
	if _iframes_timer != null:
		_is_in_iframes = true
		_iframes_timer.start()
	return true


func _check_overlapping_hitboxes() -> void:
	for area: Area2D in get_overlapping_areas():
		if _try_take_hit(area):
			return


func _on_area_entered(area: Area2D) -> void:
	_try_take_hit(area)


func _on_iframes_timer_timeout() -> void:
	_is_in_iframes = false
	_check_overlapping_hitboxes()
