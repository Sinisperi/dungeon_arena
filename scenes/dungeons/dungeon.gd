@tool
class_name Dungeon extends Node3D

@export var sub_dungeons: Array[DungeonGenerator] = []
@export var navigaion_region: NavigationRegion3D
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
	navigaion_region.bake_navigation_mesh(true)
	await navigaion_region.bake_finished
	print("bake finished")
	SignalBus.dungeon.navigation_bake_finished.emit()
	

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
