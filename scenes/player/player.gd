class_name Player extends CharacterBody3D

@onready var camera_rig: Node3D = %CameraRig
@onready var visuals: Node3D = %Visuals
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hud: HUD = %HUD
@onready var interaction_area: Area3D = %InteractionArea

@export var weapon: Area3D
@export var stats: Stats

var current_interactible: Area3D = null


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if weapon:
		weapon.area_entered.connect(_on_weapon_enemy_hit)
	if stats:
		hud.health_bar.init(stats.health, stats.health)
		hud.update_time_essence_label(stats.time_essence)

	interaction_area.area_entered.connect(_on_interaction_area_entered)
	interaction_area.area_exited.connect(_on_interaction_area_exited)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		camera_rig.rotation.y -= event.relative.x * 0.004
		camera_rig.rotation.y = wrapf(camera_rig.rotation.y, 0.0, TAU)

		camera_rig.rotation.x -= event.relative.y * 0.004
		camera_rig.rotation.x = clampf(camera_rig.rotation.x, -PI / 2.5, PI / 2.5)
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


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	var input_vector: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	var horizontal_dir: Vector3 = Vector3(input_vector.x, 0.0, input_vector.y)
	var facing_dir: Vector3 = horizontal_dir.rotated(Vector3.UP, camera_rig.rotation.y).normalized()

	if horizontal_dir.length():
		velocity.x = facing_dir.x * 6.0
		velocity.z = facing_dir.z * 6.0
		var target_angle: float = atan2(-velocity.x, -velocity.z)
		visuals.rotation.y = lerp_angle(visuals.rotation.y, target_angle, 15.0 * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, 20.0)
		velocity.z = move_toward(velocity.z, 0.0, 20.0)
	move_and_slide()


func _on_weapon_enemy_hit(area: Area3D) -> void:
	print_rich("[color=yellow]hit an enemy[/color]")
	var enemy: Enemy = area.get_parent()
	enemy.take_damage(stats.damage, self)
	print("hit the guy")


func change_time_essence_by(amount: int) -> void:
	stats.time_essence += amount
	hud.update_time_essence_label(stats.time_essence)


func attack() -> void:
	#visuals.rotation.y = camera_rig.rotation.y
	animation_player.play("attack")


func take_damage(amount: float) -> void:
	stats.health -= amount
	hud.health_bar.update(stats.health)
	print("Player took ", amount, " of damage; hp ", stats.health)
	if stats.health <= 0:
		queue_free()
		print_rich("[color=red][b]GAME OVER[/b][/color]")


func _on_interaction_area_entered(area: Area3D) -> void:
	#area.interact()
	hud.show_interact_label()
	current_interactible = area


func _on_interaction_area_exited(_area: Area3D) -> void:
	hud.hide_interact_label()
	current_interactible = null
