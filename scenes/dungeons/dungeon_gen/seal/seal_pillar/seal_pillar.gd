class_name SealPillar extends Node3D

@export var index: int = 0
@export var fire: CSGMesh3D


func _ready() -> void:
	SignalBus.dungeon.seal_activated.connect(_on_seal_activated)
	index = get_tree().get_nodes_in_group("seal_pillar").size()
	add_to_group("seal_pillar")


func _on_seal_activated(idx: int) -> void:
	if idx == index:
		fire.show()
