class_name HUD extends Control

@onready var health_bar: PBar = %HealthBar
@onready var interact_label: Label = %InteractLabel

@onready var time_essence_label: Label = %TimeEssenceLabel
@export var fps_label: Label

@export var interaction_display: Control


func init() -> void:
	var player_data: PlayerData = Globals.player.data
	var player_vitals: Vitals = player_data.stats.vitals
	health_bar.init(player_vitals.health.value, player_vitals.health.max_value)
	player_data.time_essence.value_changed.connect(_on_time_essence_value_changed)
	print_debug("Player Name ", Globals.player.name)
	player_vitals.health.value_changed.connect(_on_player_health_changed)
	update_time_essence_label(player_data.time_essence.value)


func show_interact_label(text: String) -> void:
	interaction_display.show()
	interact_label.text = text


func _process(_delta: float) -> void:
	fps_label.text = str(Engine.get_frames_per_second())


func hide_interact_label() -> void:
	interaction_display.hide()


func update_time_essence_label(new_value: float) -> void:
	print_debug("time essence chaged ")
	time_essence_label.text = "%.0f" % new_value


func _on_time_essence_value_changed(new_value: float) -> void:
	update_time_essence_label(new_value)


func _on_player_health_changed(new_value: float) -> void:
	health_bar.update(new_value)
