@tool


# NOTE there should be something that lets you to deposit money you collect
# but with a -30% if you know you won't get out because you will loose everything
# if you die in the dungeon


class_name Dungeon extends Node3D

signal dungeon_loading_complete

# NOTE temp, later will make doors and animate them and stuff
@export var doors_pivot: Node3D

@export var sub_dungeons: Array[DungeonGenerator] = []
@export var navigaion_region: NavigationRegion3D
@export var player_spawn_area: EntitySpawnArea

@export var shrine_of_time: ShrineOfTime

@export var enemy_container: Node3D

@export_tool_button("Generate", "") var gen = generate
@export_tool_button("Crash Editor", "") var gen_crash = func() -> void:
	for i in range(11):
		generate()

var gen_attempts: int = 0

var enemies: int = 0

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	Globals.active_dungeon = self
	generate()
	SignalBus.crash_game.connect(func() -> void:
			print(SignalBus.enemies))
	await get_tree().process_frame
	#navigaion_region.bake_navigation_mesh(true)
	#await navigaion_region.bake_finished
	print("bake finished")
	SignalBus.dungeon.navigation_bake_finished.emit()

	dungeon_loading_complete.emit()
	shrine_of_time.activated.connect(_on_shrine_of_time_activated)
	

func generate() -> void:
	gen_attempts += 1

	for sub_d in sub_dungeons:
		sub_d.init_socket_queue()

	var retries: int = 5

	for t in retries:
		if attempt_generation():
			break

	var success: bool = false

	for sub_d in sub_dungeons:
		success = true
		if !sub_d.finalize():
			print("Did not manage to place the seal")
			success = false
			break

	if success:
		return
	if gen_attempts > 10:
		return



func attempt_generation() -> bool:
	for sub_d in sub_dungeons:
		sub_d.init_socket_queue()
	var dungeons_remaining: int = sub_dungeons.size()
	var i: int = 0
	while dungeons_remaining:
		for sub_d in sub_dungeons:
			dungeons_remaining -= sub_d.generate_step()
		i += 1
		if i >= 1000:
			push_error("Dungeon went into infinite loop! ", i)
			return false
	return true


func get_player_spawn_position() -> Vector3:
	return player_spawn_area.get_spawn_position()


var door_tween: Tween = null
func open_doors() -> Signal:
	if door_tween:
		door_tween.kill()
	door_tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	door_tween.tween_property(doors_pivot, "position:y", 8.0, 3.0)
	return door_tween.finished

func close_doors() -> void:
	if door_tween:
		door_tween.kill()
	door_tween = create_tween().set_ease(Tween.EASE_IN)
	door_tween.tween_property(doors_pivot, "position:y", 0.0, 0.4)



func _on_shrine_of_time_activated() -> void:
	await open_doors()
	shrine_of_time.start_count_down()
