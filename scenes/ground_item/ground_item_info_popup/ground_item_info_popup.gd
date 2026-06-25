class_name GroundItemInfoPopup extends Node3D

@export var item_info: ItemInfo
var tween: Tween = null
var fade_speed: float = 0.08


func display(item_data: ItemData) -> void:
	if item_data:
		item_info.modulate.a = 0.0
		show()
		item_info.display(item_data)
		if tween:
			tween.kill()
		tween = create_tween().set_ease(Tween.EASE_OUT)
		tween.tween_property(item_info, "modulate:a", 1.0, fade_speed)


func dissapear() -> void:
	if tween:
		if tween.is_running():
			await tween.finished
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT)
	tween.tween_property(item_info, "modulate:a", 0.0, fade_speed)
	await tween.finished
	hide()
	call_deferred("queue_free")
