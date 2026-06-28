class_name Weapon extends Area3D

# use later for things like collision with walls and particle effects
# and also if knockback or something
@export var shapecast: ShapeCast3D
var data: WeaponData = null
var weilder: Character = null


func _ready() -> void:
	area_entered.connect(_on_target_hit)


func init(weapon_data: WeaponData, weapon_weilder: Character) -> void:
	data = weapon_data
	weilder = weapon_weilder
	if weapon_weilder is Player:
		set_collision_mask_value(6, true)
	else:
		set_collision_mask_value(7, true)


func _on_target_hit(area: Area3D) -> void:
	_calculate_damage(area)


func _calculate_damage(area: Area3D) -> void:
	shapecast.force_shapecast_update()
	if !shapecast.is_colliding():
		return
	if area is Hitbox:
		var damage_data: DamageData = data.damage_data.duplicate()
		# add stuff to damage data if you have buffs and also scaling and stuff
		damage_data.collision_point = shapecast.get_collision_point(0)
		damage_data.collision_normal = shapecast.get_collision_normal(0)
		damage_data.attacker_ref = weilder

		area.relay_damage(damage_data)
