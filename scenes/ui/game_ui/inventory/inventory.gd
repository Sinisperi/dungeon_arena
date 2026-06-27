class_name Inventory extends Control

# needs to be small and quick to navigate
# separate things for weapons and consumables
# no armor
# slot for a sigil placer pathfinder mark thing
# slot for a time essence cointainer, bottle, flask
# slot for hp and mana flasks

# slot 4 types ( weapon, consumable)
# item data for those types
# draggable item

@export var weapon_grid: GridContainer

@export var consumables_grid: GridContainer

var _current_selected_slot: InventorySlot = null
var _is_in_swap_mode: bool = false


func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)


func _on_visibility_changed() -> void:
	if !visible:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		_refresh_state()
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func init() -> void:
	_init_grid(weapon_grid, ItemData.Type.WEAPON)
	_init_grid(consumables_grid, ItemData.Type.CONSUMABLE)


func _unhandled_input(event: InputEvent) -> void:
	if !visible || !_current_selected_slot:
		return
	if event is InputEventKey && event.is_pressed():
		match event.keycode:
			KEY_Q:
				_drop_selected_item()
			KEY_R:
				_swap_selected_item()
			KEY_E:
				_equip_selected_item()


func add_item(item_data: ItemData) -> bool:
	var inv: InventoryData = Globals.player.data.inventory
	var index: int = inv.add_item(item_data)
	if index >= 0:
		var grid: GridContainer = weapon_grid
		if item_data.type == ItemData.Type.CONSUMABLE:
			grid = consumables_grid
		_add_item_to_grid(grid, item_data, index)
		return true
	print("Not enough space in inventory, need to display the inventory and\
			also put it in a swap mode that lets you choose which one to swap")
	return false


func _add_item_to_grid(grid: GridContainer, item_data: ItemData, index: int) -> void:
	var slot: InventorySlot = grid.get_child(index)
	if slot:
		slot.display_item(item_data)


func _init_grid(grid: GridContainer, type: ItemData.Type) -> void:
	var inventory: InventoryData = Globals.player.data.inventory
	for i in grid.get_child_count():
		var slot: InventorySlot = grid.get_child(i)

		slot.index = i
		slot.type = type
		slot.display_item(inventory.get_inv(type)[i])
		slot.selected.connect(_on_slot_selected)
		if type == ItemData.Type.WEAPON:
			if i == inventory.rh_equipped_index || i == inventory.lh_equipped_index:
				slot.equip()


func _on_slot_selected(slot: InventorySlot) -> void:
	if _current_selected_slot:
		if _is_in_swap_mode:
			_switch_items(slot, _current_selected_slot)
			_current_selected_slot.display_item_placed()
			_is_in_swap_mode = false
		_current_selected_slot.get_deselected()

	_current_selected_slot = slot
	_current_selected_slot.get_selected()


func _switch_items(slot_to: InventorySlot, slot_from: InventorySlot) -> void:
	if !slot_to.type == slot_from.type || slot_from.data == null:
		return
	var item_type: ItemData.Type = slot_to.type
	var temp_data: ItemData = null
	if slot_to.data:
		temp_data = slot_to.data.duplicate()

	var inv: InventoryData = Globals.player.data.inventory
	inv.swap_items(slot_to.index, slot_from.index, item_type)

	slot_to.display_item(slot_from.data)
	slot_from.display_item(temp_data)


func _drop_selected_item() -> void:
	if !_current_selected_slot:
		return
	var slot_ind: int = _current_selected_slot.index
	var slot_type: ItemData.Type = _current_selected_slot.type
	var inv: InventoryData = Globals.player.data.inventory
	var dropped_item_data: ItemData = inv.remove_item(slot_type, slot_ind)
	SignalBus.game.item_dropped.emit(dropped_item_data)
	_current_selected_slot.clear_slot()


func _swap_selected_item() -> void:
	if !_current_selected_slot:
		return
	_current_selected_slot.display_item_picked()
	_is_in_swap_mode = true


func _equip_selected_item() -> void:
	if !_current_selected_slot || !_current_selected_slot.data:
		return
	var inventory: InventoryData = Globals.player.data.inventory
	var item_type: ItemData.Type = _current_selected_slot.type
	var grid: GridContainer = weapon_grid
	if item_type == ItemData.Type.CONSUMABLE:
		grid = consumables_grid
	var item_index: int = _current_selected_slot.index

	var previous_equipped_index: int = inventory.change_equipment(item_index, item_type)
	var previous_equipped_slot: InventorySlot = grid.get_child(previous_equipped_index)
	previous_equipped_slot.unequip()

	_current_selected_slot.equip()


func _refresh_state() -> void:
	var inv: InventoryData = Globals.player.data.inventory
	var rh_index: int = inv.rh_equipped_index
	var lh_index: int = inv.lh_equipped_index
	var consumable_index: int = inv.equipped_consumable_index
	weapon_grid.get_child(rh_index).equip()
	weapon_grid.get_child(lh_index).equip()
	consumables_grid.get_child(consumable_index).equip()
	if _current_selected_slot:
		_current_selected_slot.get_deselected()
		_current_selected_slot.display_item_placed()
		_current_selected_slot = null
	_is_in_swap_mode = false
