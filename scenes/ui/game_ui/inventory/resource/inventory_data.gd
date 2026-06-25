class_name InventoryData extends Resource

@export var weapons: Array[ItemData] = [null, null, null, null, null, null, null, null]
@export var consumables: Array[ItemData] = [null, null, null, null]

var rh_equipped_index: int = 0
var lh_equipped_index: int = 4


func get_inv(type: ItemData.Type) -> Array[ItemData]:
	match type:
		ItemData.Type.WEAPON:
			return weapons
		ItemData.Type.CONSUMABLE:
			return consumables
		_:
			return []


func set_inv(type: ItemData.Type, inv: Array[ItemData]) -> void:
	match type:
		ItemData.Type.WEAPON:
			weapons = inv
		ItemData.Type.CONSUMABLE:
			consumables = inv


func change_equipment(ind: int) -> int:
	var temp: int = 0
	if ind < weapons.size() / 2.0:
		temp = rh_equipped_index
		rh_equipped_index = ind
	else:
		temp = lh_equipped_index
		lh_equipped_index = ind
	return temp
