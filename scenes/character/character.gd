class_name Character extends CharacterBody3D

signal character_died

@export_category("Visuals")
@export var visuals: Node3D
@export var animation_player: AnimationPlayer
@export var equipment_component: Node3D
@export_category("Multiplayer")
@export var multiplayer_synchronizer: MultiplayerSynchronizer

@export_category("Data")
@export var data: CharacterData


func _ready() -> void:
	if !data:
		push_error("No data was provided to ", name)
	if !data.stats:
		push_error("No stats were provided to character data in", name)
	data.stats.init()
	data.inventory.init()
	data.stats.vitals.health.depleted.connect(_on_health_depleted)


func _process(delta: float) -> void:
	if multiplayer.is_server():
		data.stats.update(delta)


# used in npcs only
func equip_weapon(_weapon_data: Resource) -> void:
	# var weapon = weapon_scene.instantiate()
	#_equipped_weapon = weapon
	pass


func take_damage(damage_data: Resource) -> void:
	if !multiplayer.is_server():
		return
	print(damage_data)
	pass


func _on_health_depleted() -> void:
	pass


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
