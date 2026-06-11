class_name LocalGamePanel extends Control

@export var local_server_list: VBoxContainer
@export var refresh_local_server_list_button: Button
@export var join_server_button: Button

@export var local_server_list_item_scene: PackedScene

var server_list: Dictionary = {}

var current_selected_port: int = -1


func _ready() -> void:
	refresh_local_server_list_button.pressed.connect(_on_refresh_local_server_list_button_pressed)
	join_server_button.pressed.connect(_on_join_server_button_pressed)


func _on_refresh_local_server_list_button_pressed() -> void:
	server_list = await NetworkManager.get_local_servers()
	_update_server_list()


func _on_join_server_button_pressed() -> void:
	if current_selected_port > 0:
		NetworkManager.set_local_client_port(current_selected_port)
		var err: Error = await NetworkManager.switch_connection_type(
			NetworkManager.ConnectionType.LOCAL_CLIENT
		)
		if err == OK:
			print("Created local client on port: ", current_selected_port)


func _update_server_list() -> void:
	while local_server_list.get_child_count():
		var c: LocalServerListItem = local_server_list.get_child(-1)
		c.selected.disconnect(_on_server_list_item_selected)
		local_server_list.remove_child(c)
		c.queue_free()

	for s in server_list:
		var list_item: LocalServerListItem = local_server_list_item_scene.instantiate()
		list_item.server_port = s
		list_item.server_name = server_list[s]
		local_server_list.add_child(list_item)
		list_item.selected.connect(_on_server_list_item_selected)


func _on_server_list_item_selected(port: int) -> void:
	current_selected_port = port
