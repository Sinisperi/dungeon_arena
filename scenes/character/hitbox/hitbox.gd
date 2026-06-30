class_name Hitbox extends Area3D

@export var character_ref: Character


func relay_damage(damage_packet: Resource) -> void:
	character_ref.take_damage(damage_packet)
