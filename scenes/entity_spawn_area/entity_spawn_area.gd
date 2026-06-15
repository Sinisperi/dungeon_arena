class_name EntitySpawnArea extends Area3D

@export var spawn_area: CollisionShape3D


func _ready() -> void:
	if !spawn_area:
		push_error("No collision shape was provided to EntitySpawnArea ", get_path())
		return


func get_spawn_position() -> Vector3:
	var radius: float = spawn_area.shape.radius

	var r: float = radius * sqrt(randf())
	var theta: float = randf() * TAU  # TAU is exactly 2 * PI (a full 360-degree rotation)

	# 2. Convert polar coordinates (radius, angle) back into local 3D X and Z floor planes
	var local_x: float = r * cos(theta)
	var local_z: float = r * sin(theta)

	# 3. Give it a tiny local vertical boost (Y = 0.5) so they drop cleanly onto the floor
	return global_position + Vector3(local_x, 0.5, local_z)
