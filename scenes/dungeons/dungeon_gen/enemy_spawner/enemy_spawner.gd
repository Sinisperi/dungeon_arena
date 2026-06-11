class_name EnemySpawner extends Area3D

@export var enemy_scenes: Array[PackedScene] = []
@export var spawn_area: CollisionShape3D
@export var amount: int = 0
@export var enabled: bool = false


func _ready() -> void:
	if enabled:
		SignalBus.dungeon.navigation_bake_finished.connect(_on_navigation_bake_finished)


func _on_navigation_bake_finished() -> void:
	for i in range(amount):
		for e in enemy_scenes:
			var enemy: Enemy = e.instantiate()
			enemy.position = global_position + pick_random_point()
			Globals.active_dungeon.enemy_container.add_child(enemy)


func pick_random_point() -> Vector3:
	var radius: float = spawn_area.shape.radius

	# 1. Use square root of randf to ensure a uniform distribution across the circle area.
	# (Without sqrt, enemies would bunch up heavily right in the center point)
	var r: float = radius * sqrt(randf())
	var theta: float = randf() * TAU  # TAU is exactly 2 * PI (a full 360-degree rotation)

	# 2. Convert polar coordinates (radius, angle) back into local 3D X and Z floor planes
	var local_x: float = r * cos(theta)
	var local_z: float = r * sin(theta)

	# 3. Give it a tiny local vertical boost (Y = 0.5) so they drop cleanly onto the floor
	return Vector3(local_x, 0.5, local_z)
