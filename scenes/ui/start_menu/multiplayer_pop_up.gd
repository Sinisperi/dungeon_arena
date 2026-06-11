class_name MultiplayerPopUp extends Control

@export var close_button: Button

@export_category("Create server UI")
@export var create_server_tab_button: Button
@export var create_server_tab: PanelContainer
@export var steam_game_check_box: CheckBox
@export var local_game_check_box: CheckBox
@export var host_server_button: Button
@export var lobby_code_input: TextEdit

@export_category("Join server UI")
@export var join_server_tab: PanelContainer
@export var join_server_tab_button: Button
@export var join_lobby_code_input: TextEdit
@export var join_steam_lobby_button: Button
@export var local_game_panel: Control

var is_steam_game: bool = true


func _ready() -> void:
	close_button.pressed.connect(_on_close_button_pressed)
	create_server_tab_button.pressed.connect(_on_create_server_tab_button_pressed)
	steam_game_check_box.toggled.connect(_on_steam_check_box_toggled)
	local_game_check_box.toggled.connect(_on_local_check_box_toggled)
	host_server_button.pressed.connect(_on_host_server_button_pressed)

	join_server_tab_button.pressed.connect(_on_join_server_tab_button_pressed)
	join_steam_lobby_button.pressed.connect(_on_join_steam_lobby_button_pressed)

	SteamManager.lobby_created.connect(_on_steam_lobby_created)
	SteamManager.lobby_joined.connect(_on_steam_lobby_joined)

	NetworkManager.local_host_created.connect(_on_local_host_created)


func _on_create_server_tab_button_pressed() -> void:
	create_server_tab.show()
	join_server_tab.hide()


func _on_join_server_tab_button_pressed() -> void:
	create_server_tab.hide()
	join_server_tab.show()


func _on_steam_check_box_toggled(value: bool) -> void:
	is_steam_game = value


func _on_local_check_box_toggled(value: bool) -> void:
	is_steam_game = !value


func _on_host_server_button_pressed() -> void:
	if is_steam_game:
		var err: Error = await NetworkManager.switch_connection_type(
			NetworkManager.ConnectionType.MULTIPLAYER_HOST
		)

		if err == OK:
			SteamManager.create_lobby(NetworkManager.LobbyType.FRIENDS_ONLY, 4)
	else:
		var err: Error = await NetworkManager.switch_connection_type(
			NetworkManager.ConnectionType.LOCAL_HOST
		)
		if err == OK:
			NetworkManager.start_broadcast()
			print("Successfuly created local host")


func _on_close_button_pressed() -> void:
	hide()


func _on_steam_lobby_created(response: int, lobby_id: int) -> void:
	if response == 1:
		SignalBus.ui.notification_pop_up_requested.emit("Success!", "Lobby created, very good")
		lobby_code_input.text = str(lobby_id)
	else:
		SignalBus.ui.notification_pop_up_requested.emit(
			"Fail", "Something went wrong, while trying to create steam lobby"
		)


func _on_join_steam_lobby_button_pressed() -> void:
	SteamManager.join_lobby(str(join_lobby_code_input.text))
	#print_rich("[color=orange]Not implemented, test locally for now[/color]")


func _on_local_host_created(port: int) -> void:
	SignalBus.ui.notification_pop_up_requested.emit(
		"Success!", "Created local host on port: " + str(port)
	)


func _on_steam_lobby_joined() -> void:
	SignalBus.ui.notification_pop_up_requested.emit("Success!", "Joined lobby")
