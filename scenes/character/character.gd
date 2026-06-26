class_name Character extends CharacterBody3D

signal health_changed(new_health)
signal character_died

@export_category("Visuals")
@export var visuals: Node3D
@export var animation_player: AnimationPlayer
@export_category("Multiplayer")
@export var multiplayer_synchronizer: MultiplayerSynchronizer

@export_category("Data")
@export var data: CharacterData

var _equipped_weapon: Node = null


func _disable_logic() -> void:
	set_process(false)
	set_physics_process(false)
	set_process_input(false)
	set_process_unhandled_input(false)
	set_process_unhandled_key_input(false)


func _enable_logic() -> void:
	set_process(true)
	set_physics_process(true)
	set_process_input(true)
	set_process_unhandled_input(true)
	set_process_unhandled_key_input(true)


func equip_weapon(_weapon_data: Resource) -> void:
	# var weapon = weapon_scene.instantiate()
	#_equipped_weapon = weapon
	pass


func take_damage(amount: float) -> void:
	if !multiplayer.is_server():
		return
	data.stats.health = max(0, data.stats.health - amount)
	health_changed.emit(data.stats.health)
	if data.stats.health <= 0:
		character_died.emit()
