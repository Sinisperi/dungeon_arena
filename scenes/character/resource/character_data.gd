class_name CharacterData extends Resource

@export var stats: CharacterStats
@export var inventory: InventoryData


func update(delta: float) -> void:
	stats.update(delta)
