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
	NetworkManager.connected_to_server.connect(_on_connected_to_server)
	NetworkManager.peer_connected.connect(_on_peer_connected)


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_invite_button_pressed() -> void:
	multiplayer_pop_up.show()


func _on_connected_to_server() -> void:
	pass


func _on_peer_connected(peer_id: int) -> void:
	print("peer connected ", peer_id)
	pass
