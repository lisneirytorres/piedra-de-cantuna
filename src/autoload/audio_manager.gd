extends Node
## Reproduce la música y los efectos de sonido.
##
## Gestiona los buses de audio. Las reglas de juego deciden cuándo suena algo; este nodo solo lo
## reproduce.
## Recuerda: en web, el audio solo se activa tras la primera interacción (botón "Jugar").

const MUSIC_BUS: StringName = &"Music"
const SFX_BUS: StringName = &"SFX"
## Cantidad de efectos que pueden sonar a la vez.
const SFX_VOICES: int = 8

var _music_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []
var _next_sfx_voice: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_bus(MUSIC_BUS)
	_ensure_bus(SFX_BUS)
	_music_player = _create_player(MUSIC_BUS)
	for i: int in SFX_VOICES:
		_sfx_players.append(_create_player(SFX_BUS))


## Reproduce [param stream] como música de fondo. Si ya está sonando, no la reinicia.
func play_music(stream: AudioStream) -> void:
	if stream == null:
		push_warning("AudioManager: se pidió reproducir música nula.")
		return
	if _music_player.stream == stream and _music_player.playing:
		return
	_music_player.stream = stream
	_music_player.play()


## Detiene la música de fondo.
func stop_music() -> void:
	_music_player.stop()


## Reproduce un efecto de sonido en la siguiente voz libre (o la más antigua).
func play_sfx(stream: AudioStream) -> void:
	if stream == null:
		return
	var player: AudioStreamPlayer = _sfx_players[_next_sfx_voice]
	_next_sfx_voice = (_next_sfx_voice + 1) % _sfx_players.size()
	player.stream = stream
	player.play()


## Reproduce un [SoundEffect] sintetizado. Ignora efectos nulos (sonido opcional).
func play_effect(effect: SoundEffect) -> void:
	if effect == null:
		return
	play_sfx(effect.get_stream())


func _ensure_bus(bus_name: StringName) -> void:
	if AudioServer.get_bus_index(bus_name) != -1:
		return
	var index: int = AudioServer.bus_count
	AudioServer.add_bus(index)
	AudioServer.set_bus_name(index, bus_name)
	AudioServer.set_bus_send(index, &"Master")


func _create_player(bus_name: StringName) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.bus = bus_name
	add_child(player)
	return player
