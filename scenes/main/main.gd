extends Node

var _current_dungeon: Dungeon = null
@export var dungeon_container: Node


func _ready() -> void:
	seed(69)
	DungeonLoader.dungeon_scene_loaded.connect(_on_dungeon_scene_loaded)


func _on_dungeon_scene_loaded(dungeon_scene: PackedScene) -> void:
	if _current_dungeon:
		dungeon_container.remove_child(_current_dungeon)
		_current_dungeon.queue_free()
		_current_dungeon = null

	_current_dungeon = dungeon_scene.instantiate()
	dungeon_container.add_child(_current_dungeon)
	await _current_dungeon.dungeon_loading_complete
	SignalBus.game.dungeon_loaded.emit(_current_dungeon.get_player_spawn_position())
