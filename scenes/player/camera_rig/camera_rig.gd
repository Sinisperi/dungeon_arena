class_name CameraRig extends Node3D

@export var camera: Camera3D
@export var arm: SpringArm3D
@export var interaction_ray: RayCast3D

var current: bool:
	set(value):
		current = value
		camera.current = value


func get_interaction_ray_hit() -> Dictionary:
	var res: Dictionary = {"position": Vector3.ZERO, "normal": Vector3.ZERO}
	if interaction_ray.is_colliding():
		res.position = interaction_ray.get_collision_point()
		res.normal = interaction_ray.get_collision_normal()
	else:
		print("NOT COLLIDIING CANNOT PLACE MARKER")

	return res
