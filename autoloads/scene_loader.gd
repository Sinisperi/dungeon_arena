extends Node

var current_scene: Node = null

signal scene_loaded_for_peer(peer_id: int, scene: Node)

const START_MENU: String = "uid://bda1xy3kvgf5k"
const MAIN_SCENE: String = "uid://qlcf1huk4gio"


func _ready() -> void:
	current_scene = get_tree().root.get_child(-1)


func _load_scene(peer_id: int, scene_path: String, callback: Callable) -> void:
	if !current_scene:
		return

	if current_scene.scene_file_path != scene_path:
		var new_scene: Node = ResourceLoader.load(scene_path).instantiate()
		get_tree().root.remove_child(current_scene)
		current_scene.call_deferred("queue_free")
		get_tree().root.add_child(new_scene)

		if !new_scene.is_node_ready():
			await new_scene.ready
		current_scene = new_scene

		if not callback.is_null():
			callback.call(current_scene)

		scene_loaded_for_peer.emit(peer_id, current_scene)


func load_scene(peer_id: int, scene_path: String) -> void:
	call_deferred("_load_scene", peer_id, scene_path, Callable())


func load_scene_with_callback(
	peer_id: int, scene_path: String, callback: Callable = Callable()
) -> void:
	call_deferred("_load_scene", peer_id, scene_path, callback)
