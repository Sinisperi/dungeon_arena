class_name Enemy extends CharacterBody3D

@onready var visuals: Node3D = $Visuals

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var hit_box: Area3D = %Hitbox
@onready var player_detector: Area3D = %PlayerDetector
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var health_bar: PBar = %HealthBar
@export var weapon: Area3D

@export var base_stats: Stats
var stats: Stats
var player_ref: Player = null

var target_nav_position: Vector3 = Vector3.ZERO
var target_compute_delay: float = 0.1
var since_last_compute: float = 0.0

enum State { IDLE, CHASING, COMBAT, DEAD }

var current_state: State = State.IDLE

@onready var chase_timer: Timer = Timer.new()
@onready var attack_timer: Timer = Timer.new()


func _ready() -> void:
	stats = base_stats.duplicate()
	health_bar.init(stats.health, stats.health)
	player_detector.area_entered.connect(_on_player_detected)
	player_detector.area_exited.connect(_on_player_exited)

	weapon.area_entered.connect(_on_weapon_enemy_hit)

	nav_agent.velocity_computed.connect(_on_velocity_computed)

	add_child(chase_timer)
	chase_timer.one_shot = true
	chase_timer.wait_time = 4.0
	chase_timer.timeout.connect(_on_chase_timer_timeout)

	add_child(attack_timer)
	attack_timer.one_shot = false
	attack_timer.wait_time = 1.4
	attack_timer.timeout.connect(_on_attack_timer_timeout)

	#==========================
	SignalBus.dungeon.seal_activated.connect(_on_seal_activated)
	SignalBus.enemies += 1


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= 9.8 * delta
		move_and_slide()
	since_last_compute += delta
	if since_last_compute >= target_compute_delay:
		since_last_compute = 0
		do_state()


func _on_velocity_computed(target_velocity: Vector3) -> void:
	var velocity_y = velocity.y
	velocity = target_velocity
	velocity.y = velocity_y
	move_and_slide()


func _on_player_detected(area: Area3D) -> void:
	nav_agent.process_mode = Node.PROCESS_MODE_INHERIT
	chase_timer.stop()
	player_ref = area.get_parent()
	nav_agent.avoidance_enabled = true
	await get_tree().process_frame
	nav_agent.target_position = player_ref.global_position
	print(player_ref.global_position, global_position)
	current_state = State.CHASING
	print("player detected starting chase")


func _on_player_exited(area: Area3D) -> void:
	if current_state == State.DEAD:
		print("aaaaaaaaa")
		return
	if is_instance_valid(player_ref):
		current_state = State.CHASING
		print("player left, starting chase")
		chase_timer.start()
	else:
		current_state = State.IDLE
		print("could not find player, going idle")
		player_ref = null
	# do a timer and continue chasing
	# if player enters before timout stop chasing and stop timer

	# otherwise player_ref = null
	pass


func do_state() -> void:
	match current_state:
		State.IDLE:
			attack_timer.stop()
			chase_timer.stop()
			return
		State.CHASING:
			if is_instance_valid(player_ref):
				nav_agent.target_position = player_ref.global_position
			else:
				player_ref = null
				current_state = State.IDLE
				return
			if nav_agent.is_navigation_finished():
				velocity.x = move_toward(velocity.x, 0.0, 4.0)
				velocity.z = move_toward(velocity.z, 0.0, 4.0)
				move_and_slide()
				current_state = State.COMBAT
				print("reached player after chase, starting combat")
				if attack_timer.is_stopped():
					attack_timer.start()
				return
			if velocity.length():
				print(velocity)
				var look_target = Vector3(
					player_ref.global_position.x, 0, player_ref.global_position.z
				)
				visuals.look_at(look_target, Vector3.UP)
			target_nav_position = nav_agent.get_next_path_position()
			var new_velocity: Vector3 = (target_nav_position - global_position).normalized() * 4.0
			#NEW VELOCITY IS 0, 0, 0 HERE
			nav_agent.set_velocity(new_velocity)
		State.COMBAT:
			if !is_instance_valid(player_ref):
				current_state = State.IDLE
				player_ref = null
				return
			var look_target: Vector3 = player_ref.global_position
			visuals.look_at(Vector3(look_target.x, global_position.y, look_target.z))

			if (
				is_instance_valid(player_ref)
				and global_position.distance_to(player_ref.global_position) > 3.0
			):
				current_state = State.CHASING
				print("started chasing from combat")
				nav_agent.target_position = player_ref.global_position
				attack_timer.stop()
			if !is_instance_valid(player_ref):
				attack_timer.stop()
				current_state = State.IDLE


func _on_chase_timer_timeout() -> void:
	print("stopped chasing, no player around")
	current_state = State.IDLE
	player_ref = null
	nav_agent.set_velocity(Vector3.ZERO)


func _on_attack_timer_timeout() -> void:
	if animation_player.is_playing():
		return
	print("attacking shit")
	animation_player.play("attack")


func take_damage(amount: float, from_whomst: Node = null) -> void:
	stats.health -= amount
	health_bar.update(stats.health)

	print("took ", amount, " of damage; hp ", stats.health)
	if stats.health <= 0:
		current_state = State.DEAD
		queue_free()
		if from_whomst is Player:
			from_whomst.change_time_essence_by(stats.time_essence)
	pass


func _on_weapon_enemy_hit(area: Area3D) -> void:
	var enemy: Node = area.get_parent()
	if enemy:
		print("asdfasdfasdf")
		enemy.take_damage(stats.damage)


func _on_seal_activated(player: Player) -> void:
	if is_instance_valid(player):
		if player.global_position.distance_to(global_position) < 32.0:
			player_ref = player
			current_state = State.CHASING
			nav_agent.target_position = player_ref.global_position
			print("player left, starting chase")
			chase_timer.start()
