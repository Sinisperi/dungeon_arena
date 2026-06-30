class_name Weapon extends Area3D

# use later for things like collision with walls and particle effects
# and also if knockback or something
@export var shapecast: ShapeCast3D
var data: WeaponData = null
var weilder: Character = null

var _hit_targets: Array = []


func _ready() -> void:
	_hit_targets = []
	set_physics_process(false)
	shapecast.enabled = false


func init(weapon_data: WeaponData, weapon_weilder: Character) -> void:
	data = weapon_data
	weilder = weapon_weilder
	shapecast.set_collision_mask_value(1, true)
	if weapon_weilder is Player:
		shapecast.set_collision_mask_value(8, true)
	else:
		shapecast.set_collision_mask_value(7, true)


func _calculate_damage(area: Area3D, collider_ind: int) -> void:
	if !is_multiplayer_authority():
		return
	if area is Hitbox:
		var damage_data: DamageData = data.damage_data.duplicate()
		# add stuff to damage data if you have buffs and also scaling and stuff
		damage_data.collision_point = shapecast.get_collision_point(collider_ind)
		damage_data.collision_normal = shapecast.get_collision_normal(collider_ind)
		damage_data.attacker_ref = weilder

		area.relay_damage(damage_data)
	else:
		print("it is not a hitbox ", area.name)


func begin_swing() -> void:
	_hit_targets = []
	set_physics_process(true)
	shapecast.enabled = true


func end_swing() -> void:
	set_physics_process(false)
	shapecast.enabled = false


func _physics_process(_delta: float) -> void:
	shapecast.force_shapecast_update()
	if shapecast.is_colliding():
		for i in range(shapecast.get_collision_count()):
			var collider = shapecast.get_collider(i)
			if collider is Hitbox && !_hit_targets.has(collider):
				_hit_targets.append(collider)
				_calculate_damage(collider, i)
