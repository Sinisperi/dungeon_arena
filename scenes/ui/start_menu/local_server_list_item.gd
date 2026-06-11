class_name LocalServerListItem extends VBoxContainer
signal selected(ref: Node)

@export var server_name_label: Label
@export var server_port_label: Label

var server_port: int = 0
var server_name: String = "Unnamed Server"


func _ready() -> void:
	gui_input.connect(_on_gui_input)
	server_name_label.text = server_name
	server_port_label.text = str(server_port)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			selected.emit(server_port)
