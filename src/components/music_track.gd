class_name MusicTrack
extends Resource
## Pista de música sintetizada por código: una melodía y un bajo que se repiten en bucle.
##
## Las notas son números MIDI (60 = do central) en una grilla de corcheas; [constant REST] es un
## silencio. Es música original del juego, sin archivos externos. Cada pista vive en
## [code]src/data/music/<nombre>.tres[/code] y se genera una sola vez.

## Nota que indica silencio.
const REST: int = -1
## Frecuencia de muestreo (más baja que la de los efectos para generar la pista más rápido).
const MIX_RATE: int = 16000
const MAX_SAMPLE: float = 32767.0
const BYTES_PER_SAMPLE: int = 2
const STEPS_PER_BEAT: int = 2
const A4_MIDI: int = 69
const A4_FREQUENCY: float = 440.0
const SEMITONES_PER_OCTAVE: float = 12.0

@export var tempo_bpm: float = 110.0
## Melodía: una nota MIDI por corchea.
@export var melody: PackedInt32Array = PackedInt32Array()
## Bajo: una nota MIDI cada [member steps_per_bass_note] corcheas.
@export var bass: PackedInt32Array = PackedInt32Array()
@export var steps_per_bass_note: int = 4
@export var melody_waveform: SoundEffect.Waveform = SoundEffect.Waveform.TRIANGLE
@export var bass_waveform: SoundEffect.Waveform = SoundEffect.Waveform.SQUARE
@export_range(0.0, 1.0) var melody_volume: float = 0.18
@export_range(0.0, 1.0) var bass_volume: float = 0.08

var _stream: AudioStreamWAV


## Devuelve la pista lista para reproducir en bucle (la genera una sola vez).
func get_stream() -> AudioStreamWAV:
	if _stream == null:
		_stream = _build_stream()
	return _stream


## Frecuencia en Hz de la nota MIDI [param note].
static func midi_to_frequency(note: int) -> float:
	return A4_FREQUENCY * pow(2.0, (note - A4_MIDI) / SEMITONES_PER_OCTAVE)


## Cantidad de muestras de cada corchea.
func get_samples_per_step() -> int:
	return int(MIX_RATE * 60.0 / (tempo_bpm * STEPS_PER_BEAT))


func _build_stream() -> AudioStreamWAV:
	var samples_per_step: int = get_samples_per_step()
	var total: int = maxi(melody.size(), 1) * samples_per_step
	var data := PackedByteArray()
	data.resize(total * BYTES_PER_SAMPLE)
	var rng := RandomNumberGenerator.new()
	var melody_phase: float = 0.0
	var bass_phase: float = 0.0
	for step: int in melody.size():
		var melody_note: int = melody[step]
		var bass_note: int = _bass_note_at(step)
		# El avance de fase por muestra es constante dentro de cada nota: se calcula una sola vez.
		var melody_increment: float = _phase_increment(melody_note)
		var bass_increment: float = _phase_increment(bass_note)
		for j: int in samples_per_step:
			var value: float = 0.0
			if melody_note != REST:
				melody_phase = fmod(melody_phase + melody_increment, 1.0)
				var envelope: float = pow(1.0 - float(j) / samples_per_step, 1.5) * melody_volume
				value += SoundEffect.sample_wave(melody_waveform, melody_phase, rng) * envelope
			if bass_note != REST:
				bass_phase = fmod(bass_phase + bass_increment, 1.0)
				value += SoundEffect.sample_wave(bass_waveform, bass_phase, rng) * bass_volume
			var sample_index: int = step * samples_per_step + j
			data.encode_s16(sample_index * BYTES_PER_SAMPLE, int(value * MAX_SAMPLE))
	return _make_looping_stream(data, total)


func _phase_increment(note: int) -> float:
	if note == REST:
		return 0.0
	return midi_to_frequency(note) / MIX_RATE


func _bass_note_at(step: int) -> int:
	if bass.is_empty():
		return REST
	return bass[(step / maxi(steps_per_bass_note, 1)) % bass.size()]


func _make_looping_stream(data: PackedByteArray, sample_count: int) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.data = data
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = sample_count
	return stream
