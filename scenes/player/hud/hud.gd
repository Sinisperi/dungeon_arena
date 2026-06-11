class_name HUD extends CanvasLayer

@onready var health_bar: PBar = %HealthBar
@onready var interact_label: Label = %InteractLabel
@onready var time_essence_label: Label = %TimeEssenceLabel
@export var fps_label: Label


func show_interact_label() -> void:
	interact_label.show()


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_O:
			if event.is_pressed():
				SignalBus.crash_game.emit()


func _process(delta: float) -> void:
	fps_label.text = str(Engine.get_frames_per_second())


func hide_interact_label() -> void:
	interact_label.hide()


func update_time_essence_label(value: int) -> void:
	time_essence_label.text = str(value)
