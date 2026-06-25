class_name BossSpawner extends Node3D

@export var boss_scene: PackedScene

@export var seals_total: int = 5


func _ready() -> void:
	SignalBus.dungeon.seal_activated.connect(_on_seal_activated)


func _on_seal_activated(_ind: int) -> void:
	seals_total -= 1
	if seals_total <= 0:
		if multiplayer.is_server():
			await get_tree().create_timer(3).timeout
			_spawn_boss_request.rpc()


@rpc("any_peer", "call_local")
func _spawn_boss_request() -> void:
	var boss: CharacterBody3D = load("uid://rs2cda7s84ox").instantiate()
	boss.scale *= 8.0
	boss.name = "Capsule of Despair"
	add_child(boss, true)
	boss.died.connect(_on_boss_died)
	SignalBus.dungeon.boss_spawned.emit()


func _on_boss_died() -> void:
	await get_tree().create_timer(3).timeout
	SignalBus.dungeon.boss_defeated.emit()
