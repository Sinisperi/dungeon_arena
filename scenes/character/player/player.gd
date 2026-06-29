class_name Player extends Character

@onready var interaction_area: Area3D = %InteractionArea

@export var camera_rig: CameraRig
# NOTE remove

var current_interactible: Area3D = null

# NOTE on weapons keep the aniation and then do that
#animation_player.get_animation_library("").add_animation("attack", anim)


func _ready() -> void:
	super._ready()
	if is_multiplayer_authority():
		_enable()
	else:
		_disable_logic()

	character_died.connect(_on_character_died)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				if animation_player.is_playing():
					return
				attack()
	if event is InputEventKey:
		if event.keycode == KEY_E && event.is_pressed():
			if current_interactible:
				current_interactible.interact(self)
		if event.keycode == KEY_G && event.is_pressed():
			place_path_mark()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	var input_vector: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	var horizontal_dir: Vector3 = Vector3(input_vector.x, 0.0, input_vector.y)
	var facing_dir: Vector3 = horizontal_dir.rotated(Vector3.UP, camera_rig.rotation.y).normalized()

	if horizontal_dir.length():
		velocity.x = facing_dir.x * 16.0
		velocity.z = facing_dir.z * 16.0
		var target_angle: float = atan2(-velocity.x, -velocity.z)
		visuals.rotation.y = lerp_angle(visuals.rotation.y, target_angle, 15.0 * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, 20.0)
		velocity.z = move_toward(velocity.z, 0.0, 20.0)
	move_and_slide()


func _on_weapon_enemy_hit(area: Area3D) -> void:
	print_rich("[color=yellow]hit an enemy[/color]")
	var enemy: Node = area.get_parent()
	if enemy is Enemy:
		#enemy.take_damage({"raw_damage": 10.0})
		pass
	else:
		print_debug("player hit a player for 1mil dmg")
		#enemy.take_damage(1000000.0)
	print("hit the guy")


func change_time_essence_by(amount: int) -> void:
	data.stats.time_essence += amount
	Globals.game_ui.hud.update_time_essence_label(data.stats.time_essence)


func change_xp_by(amount: int) -> void:
	data.xp += amount


func attack() -> void:
	animation_player.play("attack")


func _on_character_died() -> void:
	#play death animation or something
	_die_request.rpc(int(name))


@rpc("any_peer", "call_local")
func _die_request(peer_id: int) -> void:
	Globals.player_spawner._on_player_died(peer_id)


@rpc("any_peer", "call_local")
func _send_ui_update(hp: float) -> void:
	Globals.game_ui.hud.health_bar.update(hp)


func _on_interaction_area_entered(area: Interactible) -> void:
	current_interactible = area


func _on_interaction_area_exited(_area: Interactible) -> void:
	current_interactible = null


func place_path_mark() -> void:
	var position_data: Dictionary = camera_rig.get_interaction_ray_hit()
	print(position_data)
	_request_path_mark_placement.rpc(position_data, 0)


@rpc("any_peer", "call_local")
func _request_path_mark_placement(position_data: Dictionary, tex_id: int) -> void:
	SignalBus.dungeon.path_mark_placed.emit(position_data, tex_id)


func _disable_logic() -> void:
	super._disable_logic()
	interaction_area.monitoring = false
	interaction_area.monitorable = false


func _enable() -> void:
	Globals.player = self
	camera_rig.current = true
	if data.stats:
		Globals.game_ui.hud.health_bar.init(
			data.stats.vitals.health.value, data.stats.vitals.health.max_value
		)
		Globals.game_ui.hud.update_time_essence_label(data.time_essence)
		Globals.game_ui.inventory.init()

	interaction_area.area_entered.connect(_on_interaction_area_entered)
	interaction_area.area_exited.connect(_on_interaction_area_exited)
