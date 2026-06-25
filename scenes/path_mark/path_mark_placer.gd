class_name PathMarkPlacer extends Node3D

@export var path_mark_scene: PackedScene


func _ready() -> void:
	SignalBus.dungeon.path_mark_placed.connect(_on_path_mark_placed)


func _on_path_mark_placed(position_data: Dictionary, tex_id: int) -> void:
	if position_data.is_empty():
		return
	var mark: Decal = path_mark_scene.instantiate()
	add_child(mark)
	mark.global_position = position_data.position
	var norm: Vector3 = position_data.normal
	var pos: Vector3 = position_data.position
	var up: Vector3 = position_data.up
	if norm.is_equal_approx(Vector3.UP):
		mark.global_transform.basis = Basis.looking_at(Vector3.DOWN, up)
	elif norm.is_equal_approx(Vector3.DOWN):
		mark.global_transform.basis = Basis.looking_at(Vector3.UP, up)
	else:
		mark.global_transform.basis = Basis.looking_at(norm, up)
	mark.transform = mark.transform.rotated_local(Vector3.RIGHT, deg_to_rad(90))
	#if (
	#	position_data.normal.is_equal_approx(Vector3.UP)
	#	|| position_data.normal.is_equal_approx(Vector3.DOWN)
	#):
	#	mark.look_at(position_data.position + position_data.normal, Vector3.FORWARD)
	#else:
	#	mark.look_at(position_data.position + position_data.normal, Vector3.UP)
