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


func _to_string() -> String:
	var res: Dictionary = {}
	#res["attacker"] = attacker_ref.name
	res["collision_point"] = collision_point
	res["collision_normal"] = collision_normal
	res["physical_damage_amount"] = physical_damage_amount
	return str(res)
