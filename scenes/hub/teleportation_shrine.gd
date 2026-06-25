class_name TeleportationShrine extends Interactible

@export var player_counter_area: Area3D

var player_count: int = 0


func _ready() -> void:
	super._ready()
	player_counter_area.body_entered.connect(_on_player_entered)
	player_counter_area.body_exited.connect(_on_player_exited)
	SignalBus.game.dungeon_loaded.connect(_on_dungeon_loaded)


func interact(player_ref: Player) -> void:
	if !multiplayer.is_server():
		print_rich("[color=red]You don't hold the power to commence the ritual[/color]")
		return
	if player_count == PlayerManager.active_players.size():
		print_rich("[color=green]Teleportation ritual has commenced[/color]")
		_request_dungeon_load.rpc(DungeonLoader.FIRST_DUNGEON)
	else:
		print_rich("[color=yellow]Teleportation ritual requires more willing[/color]")


func _on_player_entered(body: Node) -> void:
	if body is Player:
		player_count += 1


func _on_player_exited(body: Node) -> void:
	if body is Player:
		player_count -= 1


func _on_dungeon_loaded(spawn_position: Vector3) -> void:
	Globals.player.global_position = spawn_position


@rpc("any_peer", "call_local")
func _request_dungeon_load(dungeon_uid: String) -> void:
	DungeonLoader.load_dungeon(dungeon_uid)
