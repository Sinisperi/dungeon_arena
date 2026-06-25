class_name Interactible extends Area3D

@export var interaction_text: String


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


func interact(player_ref: Player) -> void:
	pass


func _on_area_entered(_area: Area3D) -> void:
	Globals.game_ui.hud.show_interact_label(interaction_text)
	_on_player_in_proximity()


func _on_area_exited(_area: Area3D) -> void:
	Globals.game_ui.hud.hide_interact_label()
	_on_player_left_proximity()


func _on_player_in_proximity() -> void:
	pass


func _on_player_left_proximity() -> void:
	pass
