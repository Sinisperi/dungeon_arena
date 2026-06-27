class_name Weapon extends Area3D


func _ready() -> void:
	area_entered.connect(_on_target_hit)


func _on_target_hit(area) -> void:
	pass
