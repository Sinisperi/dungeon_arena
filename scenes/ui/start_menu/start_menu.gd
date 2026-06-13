class_name StartMenu extends Control

@export_category("Buttons")
@export var start_button: Button
@export var invite_button: Button
@export var quit_button: Button

@export_category("Pop-ups")
@export var multiplayer_pop_up: MultiplayerPopUp


func _ready() -> void:
	if quit_button:
		quit_button.pressed.connect(_on_quit_button_pressed)
	if invite_button:
		invite_button.pressed.connect(_on_invite_button_pressed)
	if start_button:
		start_button.pressed.connect(_on_start_button_pressed)
	NetworkManager.connected_to_server.connect(_on_connected_to_server)
	NetworkManager.peer_connected.connect(_on_peer_connected)


func _on_start_button_pressed() -> void:
	if multiplayer.is_server():
		_load_peers_to_game.rpc()


@rpc("any_peer", "call_local")
func _load_peers_to_game() -> void:
	SceneLoader.load_scene(multiplayer.get_unique_id(), SceneLoader.MAIN_SCENE)


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_invite_button_pressed() -> void:
	multiplayer_pop_up.show()


func _on_connected_to_server() -> void:
	pass


func _on_peer_connected(peer_id: int, _player_id: int) -> void:
	SignalBus.ui.notification_pop_up_requested.emit(
		SteamManager.get_peer_steam_username(peer_id) + " has joined!", "Rejoice!"
	)
