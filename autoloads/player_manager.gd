extends Node

class MultiplayerPlayerData:
	var player_id: int
	var player_ref: Player
	func _init(peer_id, p_player_ref) -> void:
		player_id = NetworkManager.get_player_id(peer_id)
		player_ref = p_player_ref

var active_players: Dictionary[int, MultiplayerPlayerData] = {}



func add_player_to_active(peer_id: int, player_ref: Player) -> void:
	active_players[peer_id] = MultiplayerPlayerData.new(peer_id, player_ref)






