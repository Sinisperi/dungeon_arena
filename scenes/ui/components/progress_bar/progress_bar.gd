class_name PBar extends Control

@onready var difference_bar: TextureProgressBar = %DifferenceBar
@onready var actual_bar: TextureProgressBar = %ActualBar

var tween: Tween = null


func init(max_value: float, current_value: float) -> void:
	actual_bar.max_value = max_value
	difference_bar.max_value = max_value
	actual_bar.value = current_value
	difference_bar.value = current_value


func update(value: float) -> void:
	if tween:
		tween.kill()
	tween = get_tree().create_tween().set_ease(Tween.EASE_OUT)
	tween.tween_property(actual_bar, "value", value, 0.1)
	tween.tween_property(difference_bar, "value", value, 0.1).set_delay(1.0)
