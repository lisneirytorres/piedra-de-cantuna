class_name SoundEffect
extends Resource
## Efecto de sonido sintetizado por código (estilo retro): una onda con barrido de frecuencia y
## caída de volumen.
##
## Es audio original del juego, sin archivos externos. El sonido se genera la primera vez que se
## pide y queda en caché. Cada efecto vive en [code]src/data/sfx/<nombre>.tres[/code].

## Forma de la onda.
enum Waveform { SQUARE, TRIANGLE, SINE, NOISE }

## Frecuencia de muestreo del sonido generado.
const MIX_RATE: int = 22050
## Valor máximo de una muestra de 16 bits.
const MAX_SAMPLE: float = 32767.0
const BYTES_PER_SAMPLE: int = 2

@export var waveform: Waveform = Waveform.SQUARE
## Frecuencia al empezar, en Hz.
@export var start_frequency: float = 440.0
## Frecuencia al terminar, en Hz.
@export var end_frequency: float = 220.0
## Duración en segundos.
@export var duration: float = 0.12
## Volumen, de 0 a 1.
@export_range(0.0, 1.0) var volume: float = 0.3

var _stream: AudioStreamWAV


## Devuelve el sonido listo para reproducir (lo genera una sola vez).
func get_stream() -> AudioStreamWAV:
	if _stream == null:
		_stream = _build_stream()
	return _stream


func _build_stream() -> AudioStreamWAV:
	var sample_count: int = maxi(int(duration * MIX_RATE), 1)
	var data := PackedByteArray()
	data.resize(sample_count * BYTES_PER_SAMPLE)
	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	var phase: float = 0.0
	for i: int in sample_count:
		var progress: float = float(i) / float(sample_count)
		phase = fmod(phase + lerpf(start_frequency, end_frequency, progress) / MIX_RATE, 1.0)
		var envelope: float = pow(1.0 - progress, 2.0)
		var value: float = _sample_wave(phase, rng) * envelope * volume
		data.encode_s16(i * BYTES_PER_SAMPLE, int(value * MAX_SAMPLE))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.data = data
	return stream


func _sample_wave(phase: float, rng: RandomNumberGenerator) -> float:
	match waveform:
		Waveform.SQUARE:
			return 1.0 if phase < 0.5 else -1.0
		Waveform.TRIANGLE:
			return 4.0 * absf(phase - 0.5) - 1.0
		Waveform.SINE:
			return sin(phase * TAU)
	return rng.randf_range(-1.0, 1.0)
