@tool
class_name Room extends Node3D

@export var sockets: Array[Marker3D] = []
@export var room_boundary: Area3D
@export var custom_collision_exclusions: Array[Area3D]
enum RoomType { NONE, ROOM, CORRIDOR, WALL_CAP, SEAL, VAULT }
var depth: int = -1:
	set(value):
		depth = value
		for socket in sockets:
			socket.depth = value
