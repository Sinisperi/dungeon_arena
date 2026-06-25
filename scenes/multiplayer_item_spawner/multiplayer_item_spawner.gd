class_name MultiplayerItemSpawner extends Node

@export var ground_item_scene: PackedScene


func _ready() -> void:
	SignalBus.game.item_dropped.connect(_on_item_dropped)
	SignalBus.game.item_picked_up.connect(_on_item_picked_up)


func _on_item_dropped(item_data: ItemData) -> void:
	_request_item_drop.rpc_id(1, item_data.id, Globals.player.global_position)


@rpc("any_peer", "call_local")
func _request_item_drop(item_id: String, spawn_position: Vector3) -> void:
	var item_data: ItemData = ItemDb.get_item(item_id)
	if !item_data:
		return
	var ground_item: GroundItem = ground_item_scene.instantiate()
	ground_item.data = item_data
	ground_item.name = UUID.gen()
	add_child(ground_item, true)
	ground_item.global_position = spawn_position
	_send_spawn_data_to_clients.rpc(item_id, ground_item.name, spawn_position)


@rpc("any_peer", "call_local")
func _send_spawn_data_to_clients(
	item_id: String, item_uuid: String, spawn_position: Vector3
) -> void:
	if multiplayer.is_server():
		return
	var item_data: ItemData = ItemDb.get_item(item_id)
	if !item_data:
		return
	var ground_item: GroundItem = ground_item_scene.instantiate()
	ground_item.data = item_data
	ground_item.name = item_uuid
	add_child(ground_item, true)
	ground_item.global_position = spawn_position


func _on_item_picked_up(item_uuid: String) -> void:
	_sync_item_despawn.rpc(item_uuid)


@rpc("any_peer", "call_local")
func _sync_item_despawn(item_uuid) -> void:
	get_node(item_uuid).despawn()
