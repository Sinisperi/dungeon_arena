class_name TeleportationShrine extends Interactible

@export var player_counter_area: Area3D

var player_count: int = 0


func _ready() -> void:
	player_counter_area.body_entered.connect(_on_player_entered)
	player_counter_area.body_exited.connect(_on_player_exited)


func interact(player_ref: Player) -> void:
	if !multiplayer.is_server():
		print_rich("[color=red]You don't hold the power to commence the ritual[/color]")
		return
	if player_count == PlayerManager.active_players.size():
		print_rich("[color=green]Teleportation ritual has commenced[/color]")
	else:
		print_rich("[color=yellow]Teleportation ritual requires more willing[/color]")


func _on_player_entered(body: Node) -> void:
	if body is Player:
		player_count += 1


func _on_player_exited(body: Node) -> void:
	if body is Player:
		player_count -= 1
