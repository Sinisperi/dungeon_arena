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
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func init() -> void:
	_init_grid(weapon_grid, ItemData.Type.WEAPON)
	_init_grid(consumables_grid, ItemData.Type.CONSUMABLE)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey && event.is_pressed():
		if event.keycode == KEY_Q:
			_drop_selected_item()
		elif event.keycode == KEY_R:
			print("pressing r")
			_swap_selected_item()
		elif event.keycode == KEY_E:
			_equip_selected_item()


func add_item(item_data: ItemData) -> bool:
	var index: int = Globals.player.data.inventory.get_inv(item_data.type).find(null)
	if index >= 0:
		Globals.player.data.inventory.get_inv(item_data.type)[index] = item_data
		#inventory.data[item_data.type][index] = item_data
		var grid: GridContainer = weapon_grid
		if item_data.type == ItemData.Type.CONSUMABLE:
			grid = consumables_grid
		_add_item_to_grid(item_data, grid, index)
		return true
	return false


func _add_item_to_grid(item_data: ItemData, grid: GridContainer, index: int) -> void:
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
			if !_current_selected_slot.type == slot.type:
				return

			var temp_data: ItemData = null
			if slot.data:
				temp_data = slot.data.duplicate()

			var prev_ind: int = _current_selected_slot.index
			var new_ind: int = slot.index
			var inv: InventoryData = Globals.player.data.inventory
			inv.get_inv(_current_selected_slot.type)[prev_ind] = temp_data
			inv.get_inv(_current_selected_slot.type)[new_ind] = _current_selected_slot.data

			slot.display_item(_current_selected_slot.data)
			_current_selected_slot.display_item(temp_data)
			_current_selected_slot.display_item_placed()
			_is_in_swap_mode = false

		_current_selected_slot.get_deselected()

	_current_selected_slot = slot
	_current_selected_slot.get_selected()


func _drop_selected_item() -> void:
	if !_current_selected_slot:
		return
	var slot_ind: int = _current_selected_slot.index
	var slot_type: ItemData.Type = _current_selected_slot.type
	# TODO maybe if there are some passive effects on the item, disable them
	Globals.player.data.inventory.get_inv(slot_type)[slot_ind] = null
	var dropped_item_data: ItemData = _current_selected_slot.data
	SignalBus.game.item_dropped.emit(dropped_item_data)
	_current_selected_slot.clear_slot()


func _swap_selected_item() -> void:
	if !_current_selected_slot:
		return
	_current_selected_slot.display_item_picked()
	_is_in_swap_mode = true


func _equip_selected_item() -> void:
	if !_current_selected_slot:
		return
	var inventory: InventoryData = Globals.player.data.inventory
	var previous_equipped_index: int = inventory.change_equipment(_current_selected_slot.index)
	var previous_equipped_slot: InventorySlot = weapon_grid.get_child(previous_equipped_index)
	previous_equipped_slot.unequip()

	_current_selected_slot.equip()
