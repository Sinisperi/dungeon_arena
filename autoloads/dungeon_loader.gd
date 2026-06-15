extends Node

const FIRST_DUNGEON: String = "uid://cjo82n66lneur"

signal dungeon_scene_loaded(dungeon_scene: PackedScene)

var _new_dungeon_uid: String = ""
var _is_loading: bool = false

var _loading_progress: float = 0.0


func load_dungeon(uid: String) -> void:
	if _is_loading:
		return

	_new_dungeon_uid = uid
	_is_loading = true

	var err: Error = ResourceLoader.load_threaded_request(_new_dungeon_uid, "", true)
	if err != OK:
		print("Failed to load the dungeon")
		_is_loading = false


func _process(_delta: float) -> void:
	if !_is_loading:
		return
	var progress: Array = []
	var status = ResourceLoader.load_threaded_get_status(_new_dungeon_uid, progress)
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			_loading_progress = progress[0] * 100.0
		ResourceLoader.THREAD_LOAD_LOADED:
			_is_loading = false
			print("Dungeon loaded")
			var dungeon_scene: PackedScene = ResourceLoader.load_threaded_get(_new_dungeon_uid)
			dungeon_scene_loaded.emit(dungeon_scene)
		ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			_is_loading = false
			print("Background thread crashed or file path is invalid")
