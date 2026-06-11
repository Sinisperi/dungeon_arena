class_name NotificationPopUp extends Control

@export var notification_title_label: Label
@export var notification_body_label: Label

@onready var start_position: Vector2 = global_position
var tween: Tween = null


func _ready() -> void:
	SignalBus.ui.notification_pop_up_requested.connect(_on_notification_pop_up_requested)


func _on_notification_pop_up_requested(title: String, body: String) -> void:
	print("recieved request to pop")
	print(start_position)
	notification_title_label.text = title
	notification_body_label.text = body

	if tween && tween.is_valid():
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "global_position:y", start_position.y - size.y, 0.1)
	tween.tween_interval(1.5)
	tween.tween_property(self, "global_position:y", start_position.y, 0.04)
