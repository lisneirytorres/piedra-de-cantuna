extends GutTest
## Pruebas de DialogueData y validación de todos los diálogos del juego.

const DIALOGUE_DIR: String = "res://src/data/dialogue/"
## Cantidad máxima de caracteres por línea (unos dos renglones en la caja de diálogo).
const MAX_LINE_LENGTH: int = 130


func _make_dialogue() -> DialogueData:
	var dialogue := DialogueData.new()
	dialogue.speakers = PackedStringArray(["Cantuña"])
	dialogue.lines = PackedStringArray(["Hola."])
	dialogue.choices = PackedStringArray(["Sí", "No"])
	dialogue.choice_flags = [&"bargained_pact", &""]
	dialogue.finish_flag = &"met_friar"
	return dialogue


func test_choice_flags_include_choice_and_finish_flag() -> void:
	var flags: Array[StringName] = _make_dialogue().get_flags_to_set(0)
	assert_eq(flags, [&"bargained_pact", &"met_friar"] as Array[StringName])


func test_choice_without_flag_only_sets_finish_flag() -> void:
	var flags: Array[StringName] = _make_dialogue().get_flags_to_set(1)
	assert_eq(flags, [&"met_friar"] as Array[StringName])


func test_no_choice_only_sets_finish_flag() -> void:
	var flags: Array[StringName] = _make_dialogue().get_flags_to_set(DialogueData.NO_CHOICE)
	assert_eq(flags, [&"met_friar"] as Array[StringName])


func test_mismatched_speakers_are_invalid() -> void:
	var dialogue: DialogueData = _make_dialogue()
	dialogue.speakers = PackedStringArray()
	assert_false(dialogue.is_valid())


func test_out_of_range_line_returns_empty_text() -> void:
	assert_eq(_make_dialogue().get_line(5), "")


func test_every_dialogue_resource_is_valid() -> void:
	var files: PackedStringArray = ResourceLoader.list_directory(DIALOGUE_DIR)
	assert_gt(files.size(), 0, "Debe haber diálogos en %s" % DIALOGUE_DIR)
	for file: String in files:
		var dialogue := load(DIALOGUE_DIR + file) as DialogueData
		assert_not_null(dialogue, "%s debe ser un DialogueData" % file)
		if dialogue == null:
			continue
		assert_true(dialogue.is_valid(), "%s tiene datos incoherentes" % file)
		assert_eq(String(dialogue.id), file.get_basename(), "El id de %s debe coincidir" % file)
		for line: String in dialogue.lines:
			assert_lte(line.length(), MAX_LINE_LENGTH, "Línea demasiado larga en %s" % file)
