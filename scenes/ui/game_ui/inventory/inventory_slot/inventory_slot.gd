class_name InventorySlot extends ColorRect

signal selected(slot: InventorySlot)

@export var item_display: TextureRect
@export var selector: TextureRect
@export var equipped_icon: TextureRect

var index: int = -1
var type: ItemData.Type = ItemData.Type.WEAPON

var data: ItemData = null
var is_equipped: bool = false


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if !event.is_pressed():
			return
		elif event.button_index == MOUSE_BUTTON_LEFT:
			selected.emit(self)


func init(item_data: ItemData) -> void:
	data = item_data
	if data:
		item_display.texture = data.texture


func display_item(item_data: ItemData) -> void:
	data = item_data
	if item_data:
		item_display.texture = data.texture
	else:
		item_display.texture = null


func clear_slot() -> void:
	data = null
	item_display.texture = null
	unequip()


func get_selected() -> void:
	selector.show()


func get_deselected() -> void:
	selector.hide()


func display_item_picked() -> void:
	item_display.modulate.a = 0.5


func display_item_placed() -> void:
	selector.hide()
	item_display.modulate.a = 1.0


func equip() -> void:
	if !data:
		return
	is_equipped = true
	equipped_icon.show()
	if index >= 4:
		equipped_icon.modulate = Color.ROYAL_BLUE
	else:
		equipped_icon.modulate = Color.WHITE


func unequip() -> void:
	is_equipped = false
	equipped_icon.hide()
