class_name InventoryData extends Resource
signal right_hand_weapon_equipped(weapon_data: WeaponData)
signal left_hand_weapon_equipped(weapon_data: WeaponData)
signal consumable_equipped(item_data: ItemData)

@export var weapons: Array[ItemData] = [null, null, null, null, null, null, null, null]
@export var consumables: Array[ItemData] = [null, null, null, null]

var rh_equipped_index: int = 0:
	set(value):
		rh_equipped_index = value
		var item: ItemData = null
		if rh_equipped_index != -1:
			item = weapons[rh_equipped_index]
		right_hand_weapon_equipped.emit(item)
		print("rh_equipped_index", rh_equipped_index)

# needs to be set according to wether there is something in the 4 slot
var lh_equipped_index: int = 4:
	set(value):
		lh_equipped_index = value
		var item: ItemData = null
		if lh_equipped_index != -1:
			item = weapons[lh_equipped_index]
		left_hand_weapon_equipped.emit(item)
		print("lh_equipped_index", lh_equipped_index)

var equipped_consumable_index: int = 0:
	set(value):
		equipped_consumable_index = value
		var item: ItemData = null
		if equipped_consumable_index != -1:
			item = consumables[equipped_consumable_index]
		consumable_equipped.emit(item)


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


func change_equipment(ind: int, type: ItemData.Type) -> int:
	var temp: int = -1
	if type == ItemData.Type.CONSUMABLE:
		if ind == equipped_consumable_index:
			temp = equipped_consumable_index
			equipped_consumable_index = -1
			return temp
		if ind >= consumables.size() || ind < 0:
			return temp
		temp = equipped_consumable_index
		equipped_consumable_index = ind
	elif type == ItemData.Type.WEAPON:
		if ind == lh_equipped_index:
			temp = lh_equipped_index
			lh_equipped_index = -1
			return temp
		if ind == rh_equipped_index:
			temp = rh_equipped_index
			rh_equipped_index = -1
			return temp
		if ind >= weapons.size() || ind < 0:
			return -1
		if ind < int(weapons.size() / 2.0):
			temp = rh_equipped_index
			rh_equipped_index = ind
		else:
			temp = lh_equipped_index
			lh_equipped_index = ind

	return temp


func change_weapon(ind: int) -> int:
	if ind == lh_equipped_index || ind == rh_equipped_index:
		return -1
	var temp: int = 0
	if ind >= weapons.size() || ind < 0:
		return -1
	if ind < int(weapons.size() / 2.0):
		temp = rh_equipped_index
		rh_equipped_index = ind
	else:
		temp = lh_equipped_index
		lh_equipped_index = ind
	return temp


func change_consumable(ind: int) -> int:
	var temp: int = 0
	if ind < 0 || ind >= consumables.size():
		return -1
	temp = equipped_consumable_index
	equipped_consumable_index = ind
	return temp


func swap_items(ind_to: int, ind_from: int, inv_type: ItemData.Type) -> void:
	var inv: Array = weapons
	if inv_type == ItemData.Type.CONSUMABLE:
		inv = consumables
	var temp: ItemData = inv[ind_to]
	inv[ind_to] = inv[ind_from]
	inv[ind_from] = temp
	if inv_type == ItemData.Type.WEAPON:
		if ind_to == rh_equipped_index || ind_from == rh_equipped_index:
			right_hand_weapon_equipped.emit(inv[rh_equipped_index])
		if ind_to == lh_equipped_index || ind_from == lh_equipped_index:
			left_hand_weapon_equipped.emit(inv[lh_equipped_index])
	elif inv_type == ItemData.Type.CONSUMABLE:
		if ind_to == equipped_consumable_index || ind_from == equipped_consumable_index:
			consumable_equipped.emit(inv[equipped_consumable_index])


func add_item(item_data: ItemData) -> int:
	var inv: Array = get_inv(item_data.type)
	var index: int = inv.find(null)
	if index >= 0:
		inv[index] = item_data
	_check_for_equipment_change(item_data.type, index)
	return index


func remove_item(type: ItemData.Type, ind: int) -> ItemData:
	# TODO maybe if there are some passive effects on the item, disable them
	var res: ItemData = get_inv(type)[ind]
	get_inv(type)[ind] = null
	_check_for_equipment_change(type, ind)
	return res


func replace_item(ind: int, item_data: ItemData) -> ItemData:
	var inv: Array = get_inv(item_data.type)
	var item: ItemData = null
	if ind >= 0 && ind < inv.size():
		item = inv[ind]
		inv[ind] = item_data
	_check_for_equipment_change(item_data.type, ind)
	return item


func _check_for_equipment_change(type: ItemData.Type, ind: int) -> void:
	var inv: Array = get_inv(type)
	if type == ItemData.Type.WEAPON:
		if ind == rh_equipped_index:
			right_hand_weapon_equipped.emit(inv[rh_equipped_index] as WeaponData)
		if ind == lh_equipped_index:
			left_hand_weapon_equipped.emit(inv[lh_equipped_index] as WeaponData)
	elif type == ItemData.Type.CONSUMABLE:
		if ind == equipped_consumable_index:
			consumable_equipped.emit(inv[equipped_consumable_index])


func get_rh_weapon() -> ItemData:
	return weapons[rh_equipped_index]


func get_lh_weapon() -> ItemData:
	return weapons[lh_equipped_index]


func is_equipped(ind: int, type: ItemData.Type) -> bool:
	if type == ItemData.Type.WEAPON:
		return ind == rh_equipped_index || ind == lh_equipped_index
	else:
		return ind == equipped_consumable_index


func init() -> void:
	if lh_equipped_index >= 0 && weapons[lh_equipped_index] == null:
		lh_equipped_index = -1
	if rh_equipped_index >= 0 && weapons[rh_equipped_index] == null:
		rh_equipped_index = -1
	if equipped_consumable_index >= 0 && consumables[equipped_consumable_index] == null:
		equipped_consumable_index = -1
