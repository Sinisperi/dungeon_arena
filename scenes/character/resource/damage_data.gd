class_name DamageData extends Resource

enum PhysicalType { BLUNT, CUT, PIERCE, SLASH }
@export var status_effects: Array[StatusEffect] = []
@export var physical_damage_type: PhysicalType
@export var physical_damage_amount: float

@export_group("Elemental Damage")
@export var cold_damage: float
@export var lightning_damage: float
@export var fire_damage: float

@export_category("Ailments")
@export var poison_buildup: float
@export var ignite_buildup: float
@export var stun_buildup: float

var attacker_ref: Character
var collision_point: Vector3
var collision_normal: Vector3


func to_dict() -> Dictionary:
	var res: Dictionary = {}
	for property in get_property_list():
		if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			res[property.name] = get(property.name)
	return res


func _to_string() -> String:
	return str(to_dict())
