extends GutTest
## Pruebas del secuenciador de música sintetizada.

const MUSIC_DIR: String = "res://src/data/music/"


func test_a4_is_440_hz() -> void:
	assert_almost_eq(MusicTrack.midi_to_frequency(69), 440.0, 0.001)


func test_one_octave_up_doubles_frequency() -> void:
	assert_almost_eq(MusicTrack.midi_to_frequency(81), 880.0, 0.001)


func test_stream_loops_over_the_whole_melody() -> void:
	var track := MusicTrack.new()
	track.melody = PackedInt32Array([60, MusicTrack.REST, 64, 67])
	var stream: AudioStreamWAV = track.get_stream()
	var expected_samples: int = 4 * track.get_samples_per_step()
	assert_eq(stream.loop_mode, AudioStreamWAV.LOOP_FORWARD)
	assert_eq(stream.loop_end, expected_samples)
	assert_eq(stream.data.size(), expected_samples * MusicTrack.BYTES_PER_SAMPLE)


func test_every_music_resource_builds_a_loop() -> void:
	var files: PackedStringArray = ResourceLoader.list_directory(MUSIC_DIR)
	assert_gt(files.size(), 0)
	for file: String in files:
		var track := load(MUSIC_DIR + file) as MusicTrack
		assert_not_null(track, "%s debe ser un MusicTrack" % file)
		if track == null:
			continue
		var started_at: int = Time.get_ticks_msec()
		var stream: AudioStreamWAV = track.get_stream()
		gut.p("%s generado en %d ms" % [file, Time.get_ticks_msec() - started_at])
		assert_gt(stream.data.size(), 0, "%s no generó audio" % file)
