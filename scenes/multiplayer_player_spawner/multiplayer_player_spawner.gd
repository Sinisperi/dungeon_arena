class_name MultiplayerPlayerSpawner extends Node

signal client_player_cleared
#@export var players_container: Node
@export var player_scene: PackedScene
@export var player_spawn_area: EntitySpawnArea


func _ready() -> void:
	Globals.player_spawner = self
	SceneLoader.scene_loaded_for_peer.connect(_on_scene_loaded)
	NetworkManager.peer_disconnected.connect(_on_peer_disconnected)
	SignalBus.game.player_died.connect(_on_player_died)


# everywhere
func _on_scene_loaded(peer_id: int, current_scene: Node) -> void:
	if !is_inside_tree():
		await tree_entered

	#await Engine.get_main_loop().process_frame

	if is_inside_tree():
		_request_player_spawn.rpc_id(1, peer_id)
	else:
		if current_scene && current_scene.is_inside_tree():
			_request_player_spawn.rpc_id(1, peer_id)


# on the host
@rpc("any_peer", "call_local")
func _request_player_spawn(peer_id: int) -> void:
	# spawn requested player on host
	var player: Player = _create_player(peer_id)
	player.multiplayer_synchronizer.set_visibility_for(1, true)
	PlayerManager.add_player_to_active(peer_id, player)

	if !player.is_node_ready():
		await player.ready

	if peer_id > 1:
		var players_data: Dictionary = {}
		for peer in PlayerManager.active_players.keys():
			var p: Player = PlayerManager.active_players[peer].player_ref
			players_data[peer] = {
				"position":
				{"x": p.global_position.x, "y": p.global_position.y, "z": p.global_position.z}
			}
		print("player data", players_data)
		var data: Dictionary = {"players_data": players_data}
		_send_spawn_response_to_peer.rpc_id(peer_id, data)


# on the client
@rpc("any_peer", "call_local")
func _send_spawn_response_to_peer(data: Dictionary) -> void:
	var player: Player = _create_player(
		multiplayer.get_unique_id(), data.players_data[multiplayer.get_unique_id()]
	)
	for peer in data.players_data:
		if peer != multiplayer.get_unique_id():
			var new_peer_player: Player = _create_player(peer, data.players_data[peer])
			new_peer_player.multiplayer_synchronizer.set_visibility_for(peer, true)
			player.multiplayer_synchronizer.set_visibility_for(peer, true)
	_client_spawn_finished.rpc_id(1)


# on the host
@rpc("any_peer", "call_local")
func _client_spawn_finished() -> void:
	var new_peer_id: int = multiplayer.get_remote_sender_id()
	for peer in PlayerManager.active_players.keys():
		var peer_player: Player = PlayerManager.active_players[peer].player_ref
		peer_player.multiplayer_synchronizer.set_visibility_for(new_peer_id, true)
		if peer <= 1:
			continue
		_update_active_peers.rpc_id(peer, multiplayer.get_remote_sender_id())


# on the client
@rpc("any_peer", "call_remote")
func _update_active_peers(new_peer_id: int) -> void:
	if new_peer_id == multiplayer.get_unique_id():
		return
	var new_peer_player: Player = _create_player(new_peer_id)
	if new_peer_player:
		Globals.player.multiplayer_synchronizer.set_visibility_for(new_peer_id, true)


func _create_player(peer_id, data: Dictionary = {}) -> Player:
	if has_node("./" + str(peer_id)):
		return null
	var player: Player = player_scene.instantiate()
	player.name = str(peer_id)
	player.set_multiplayer_authority(peer_id)
	add_child(player, true)
	if !data.is_empty():
		player.global_position = Vector3(data.position.x, data.position.y, data.position.z)
	else:
		player.global_position = player_spawn_area.get_spawn_position()

	return player


func _on_peer_disconnected(peer_id: int, _player_id: int) -> void:
	if multiplayer.is_server():
		var player: Player = PlayerManager.remove_player_from_active(peer_id)
		remove_child(player)
		player.queue_free.call_deferred()
	else:
		var player: Player = get_node_or_null("./" + str(peer_id))
		if player:
			player.queue_free.call_deferred()


# I DONT NEED TO DELETE THE PLAYER
# later something else to be able to revivie or something idk
func _on_player_died(peer_id: int) -> void:
	respawn()


func respawn() -> void:
	print_rich("[color=red]You died[/color]")
