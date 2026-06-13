class_name MultiplayerPlayerSpawner extends Node

@export var players_container: Node
@export var player_scene: PackedScene
@export var character_spawn_area: CollisionShape3D


func _ready() -> void:
	SceneLoader.scene_loaded_for_peer.connect(_on_scene_loaded)


# everywhere
func _on_scene_loaded(peer_id: int, _current_scene: Node) -> void:
	_request_player_spawn.rpc_id(1, peer_id)


# on the host
@rpc("any_peer", "call_local")
func _request_player_spawn(peer_id: int) -> void:
	# spawn requested player on host
	var player: Player = _create_player(peer_id)
	player.multiplayer_synchronizer.set_visibility_for(1, true)
	PlayerManager.add_player_to_active(peer_id, player)

	if player.is_node_ready():
		await player.ready

	if peer_id >= 0:
		var players_data: Dictionary = {}
		for peer in PlayerManager.active_players.keys():
			var p: Player = PlayerManager.active_players[peer].player_ref
			players_data[peer] = {
				"position":
				{"x": p.global_position.x, "y": p.global_position.y, "z": p.global_position.z}
			}
		var data: Dictionary = {
			"players_data": players_data, "active_peers": multiplayer.get_peers()
		}
		_send_spawn_response_to_peer.rpc_id(peer_id, data)


# on the client
@rpc("any_peer", "call_local")
func _send_spawn_response_to_peer(data: Dictionary) -> void:
	var player: Player = _create_player(multiplayer.get_unique_id(), data)
	for peer in data.active_peers:
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
	_update_active_peers.rpc(multiplayer.get_remote_sender_id())


# on the client
@rpc("any_peer", "call_remote")
func _update_active_peers(new_peer_id: int) -> void:
	if new_peer_id == multiplayer.get_unique_id():
		return
	var new_peer_player: Player = _create_player(new_peer_id)
	if new_peer_player:
		Globals.player.multiplayer_synchronizer.set_visibility_for(new_peer_id, true)


func _create_player(peer_id, data: Dictionary = {}) -> Player:
	if players_container.has_node("./" + str(peer_id)):
		return null
	var player: Player = player_scene.instantiate()
	player.name = str(peer_id)
	player.set_multiplayer_authority(peer_id)
	players_container.add_child(player, true)
	if !data.is_empty():
		player.global_position = Vector3(data.position.x, data.position.y, data.position.z)
	else:
		player.global_position = character_spawn_area.global_position + pick_random_point()

	return player


func pick_random_point() -> Vector3:
	var radius: float = character_spawn_area.shape.radius

	var r: float = radius * sqrt(randf())
	var theta: float = randf() * TAU  # TAU is exactly 2 * PI (a full 360-degree rotation)

	# 2. Convert polar coordinates (radius, angle) back into local 3D X and Z floor planes
	var local_x: float = r * cos(theta)
	var local_z: float = r * sin(theta)

	# 3. Give it a tiny local vertical boost (Y = 0.5) so they drop cleanly onto the floor
	return Vector3(local_x, 0.5, local_z)
