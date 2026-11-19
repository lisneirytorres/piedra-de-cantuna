extends GutTest
## Pruebas del sintetizador de efectos de sonido.

const SFX_DIR: String = "res://src/data/sfx/"


func test_stream_length_matches_duration() -> void:
	var effect := SoundEffect.new()
	effect.duration = 0.1
	var stream: AudioStreamWAV = effect.get_stream()
	var expected_bytes: int = int(0.1 * SoundEffect.MIX_RATE) * SoundEffect.BYTES_PER_SAMPLE
	assert_eq(stream.data.size(), expected_bytes)


func test_stream_is_cached() -> void:
	var effect := SoundEffect.new()
	assert_same(effect.get_stream(), effect.get_stream())


func test_every_sound_resource_builds_a_stream() -> void:
	var files: PackedStringArray = ResourceLoader.list_directory(SFX_DIR)
	assert_gt(files.size(), 0)
	for file: String in files:
		var effect := load(SFX_DIR + file) as SoundEffect
		assert_not_null(effect, "%s debe ser un SoundEffect" % file)
		if effect != null:
			assert_gt(effect.get_stream().data.size(), 0, "%s no generó audio" % file)
