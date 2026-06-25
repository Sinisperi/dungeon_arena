class_name Hub extends Node3D

# this is a main Hub
# acts also as a loading screen
# you select the dungeon here
# you start a ritual of teleportation or something
# animation takes time, and meanwhile, the dungeon is loading

# when dungeon is loaded, hub is still there, but under the dungeon

@export var player_spawn_area: EntitySpawnArea


func _ready() -> void:
	SignalBus.dungeon.boss_defeated.connect(_on_boss_defeated)


func _on_boss_defeated() -> void:
	Globals.player.global_position = player_spawn_area.get_spawn_position()
