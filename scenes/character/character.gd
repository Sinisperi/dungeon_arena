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
	data = data.duplicate_deep(Resource.DeepDuplicateMode.DEEP_DUPLICATE_ALL)
	data.stats.init(name)
	data.inventory.init()
	equipment_component.init()
	data.stats.vitals.health.depleted.connect(_on_health_depleted)
	print_debug("Character ", name, " has ", data.stats.vitals.stamina.value, " hp")


func _process(delta: float) -> void:
	if is_multiplayer_authority():
		data.stats.update(delta)


# used in npcs only
func equip_weapon(_weapon_data: Resource) -> void:
	pass


func take_damage(damage_data: DamageData) -> void:
	_notify_take_damage.rpc(damage_data.to_dict())


@rpc("any_peer", "call_local", "reliable")
func _notify_take_damage(damage_data: Dictionary) -> void:
	data.stats.vitals.health.value -= damage_data.physical_damage_amount


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
