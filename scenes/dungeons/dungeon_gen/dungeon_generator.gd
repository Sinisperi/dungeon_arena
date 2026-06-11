@tool
class_name DungeonGenerator extends Node3D

@export var root_socket: Socket
@export var room_container: Node3D
@export var room_scenes: Array[PackedScene]
@export var corridor_scenes: Array[PackedScene]
@export var wall_cap_scenes: Array[PackedScene]
@export var seal_room_scenes: Array[PackedScene]
@export var vault_room_scenes: Array[PackedScene]

@export var max_depth: int = 5

var placed_rooms: Array[Room] = []
var socket_queue: Array[Socket] = []
var is_seal_spawned: bool = false
var is_finished: bool = false
var current_depth: int = 0
@export_tool_button("Generate", "") var gen: Callable = generate


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	#generate()


func generate() -> void:
	reset()

	socket_queue.append(root_socket)

	while socket_queue.size() > 0:
		var active_socket: Socket = socket_queue.pop_front()
		place_room(active_socket)


func init_socket_queue() -> void:
	reset()
	socket_queue.append(root_socket)


func generate_step() -> int:
	if is_finished:
		return 0
	var active_socket: Socket = socket_queue.pop_front()
	if active_socket == null:
		is_finished = true
		return 1
	place_room(active_socket)
	if !is_finished:
		is_finished = socket_queue.size() <= 0 || current_depth >= max_depth

	return int(is_finished)


func place_room(socket: Socket) -> void:
	current_depth += 1
	var next_room_type: Room.RoomType = Room.RoomType.NONE
	if current_depth >= max_depth:
		if !is_seal_spawned:
			is_seal_spawned = true
			next_room_type = Room.RoomType.SEAL
		else:
			next_room_type = Room.RoomType.WALL_CAP
	else:
		var conn = socket.possible_connections.pick_random()
		if conn:
			next_room_type = conn

	var room_pool: Array[PackedScene] = []
	match next_room_type:
		Room.RoomType.ROOM:
			room_pool = room_scenes
		Room.RoomType.CORRIDOR:
			current_depth -= 1
			room_pool = corridor_scenes
		Room.RoomType.WALL_CAP:
			room_pool = wall_cap_scenes
		Room.RoomType.SEAL:
			room_pool = seal_room_scenes
		Room.RoomType.VAULT:
			room_pool = vault_room_scenes
		_:
			room_pool = wall_cap_scenes
	var next_room_scene: PackedScene = room_pool.pick_random()
	var next_room: Room = next_room_scene.instantiate()
	var next_room_socket: Socket = next_room.sockets.pick_random()
	next_room.depth = current_depth + 1
	var t: Transform3D = socket.global_transform
	var rotated_t: Transform3D = Transform3D(Basis().rotated(Vector3.UP, PI), Vector3.ZERO)
	var target_t: Transform3D = t * rotated_t
	next_room.global_transform = target_t * next_room_socket.transform.inverse()
	room_container.add_child(next_room)
	next_room.force_update_transform()
	if !check_collision(next_room):
		#room_container.add_child(next_room)
		placed_rooms.append(next_room)

		for s in next_room.sockets:
			if s != next_room_socket:
				socket_queue.append(s)
	else:
		room_container.remove_child(next_room)
		next_room.free()
		if next_room_type == Room.RoomType.SEAL:
			is_seal_spawned = false
		place_wall_cap(socket)


func check_collision(next_room: Room) -> bool:
	var room_boundary: Area3D = next_room.room_boundary
	if !room_boundary:
		return false
	var col_shape: CollisionShape3D = room_boundary.get_child(0) as CollisionShape3D

	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state

	var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
	query.shape = col_shape.shape

	query.transform = col_shape.global_transform
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var exclusions: Array[RID] = [room_boundary.get_rid()]
	#query.exclude = [room_boundary.get_rid()]
	for ex in next_room.custom_collision_exclusions:
		exclusions.append(ex.get_rid())
	query.exclude = exclusions

	var results: Array[Dictionary] = space_state.intersect_shape(query, 1)

	if results.size() > 0:
		return true

	return false


func place_wall_cap(socket) -> void:
	var wall_cap_scene: PackedScene = wall_cap_scenes.pick_random()
	var wall_cap: Room = wall_cap_scene.instantiate()
	var wall_cap_socket: Socket = wall_cap.sockets[0]

	var target_transform: Transform3D = (
		socket.global_transform * Transform3D(Basis().rotated(Vector3.UP, PI), Vector3.ZERO)
	)
	wall_cap.global_transform = target_transform * wall_cap_socket.transform.inverse()
	room_container.add_child(wall_cap)
	placed_rooms.append(wall_cap)


func reset() -> void:
	while room_container.get_child_count():
		var r: Room = room_container.get_child(-1)
		room_container.remove_child(r)
		r.free()
	placed_rooms = []
	socket_queue = []
	is_seal_spawned = false
	is_finished = false
	current_depth = 0


func finalize() -> bool:
	if !socket_queue.size():
		print("Subdungeon ", name, " has finished generation. Seal spawned: ", is_seal_spawned)
		return is_seal_spawned
	if is_seal_spawned:
		for socket in socket_queue:
			place_wall_cap(socket)
	else:
		for socket in socket_queue:
			if !is_seal_spawned:
				var success: bool = place_room_type(socket, Room.RoomType.SEAL)
				if !success:
					place_wall_cap(socket)
			else:
				var success: bool = place_room_type(socket, Room.RoomType.VAULT)
				if !success:
					place_wall_cap(socket)
	return is_seal_spawned


func place_room_type(socket: Socket, room_type: Room.RoomType) -> bool:
	var room_pool: Array[PackedScene] = []
	match room_type:
		Room.RoomType.ROOM:
			room_pool = room_scenes
		Room.RoomType.CORRIDOR:
			room_pool = corridor_scenes
		Room.RoomType.WALL_CAP:
			room_pool = wall_cap_scenes
		Room.RoomType.SEAL:
			is_seal_spawned = true
			room_pool = seal_room_scenes
		Room.RoomType.VAULT:
			room_pool = vault_room_scenes
		_:
			room_pool = wall_cap_scenes
	var next_room_scene: PackedScene = room_pool.pick_random()
	var next_room: Room = next_room_scene.instantiate()
	var next_room_socket: Socket = next_room.sockets.pick_random()
	next_room.depth = current_depth + 1
	var t: Transform3D = socket.global_transform
	var rotated_t: Transform3D = Transform3D(Basis().rotated(Vector3.UP, PI), Vector3.ZERO)
	var target_t: Transform3D = t * rotated_t
	next_room.global_transform = target_t * next_room_socket.transform.inverse()
	room_container.add_child(next_room)
	next_room.force_update_transform()
	if !check_collision(next_room):
		placed_rooms.append(next_room)
		return true
	else:
		room_container.remove_child(next_room)
		next_room.free()
		if room_type == Room.RoomType.SEAL:
			is_seal_spawned = false
		place_wall_cap(socket)
		return false
