class_name EquipmentComponent extends Node3D

## Responsible for instantiating weapon scenes
@export var left_hand_marker: Marker3D
@export var right_hand_marker: Marker3D

@export var character_ref: Character

var lh_weapon: Weapon
var rh_weapon: Weapon


func _ready() -> void:
	character_ref.data.inventory.right_hand_weapon_equipped.connect(_on_right_hand_weapon_equipped)

	character_ref.data.inventory.left_hand_weapon_equipped.connect(_on_left_hand_weapon_equipped)

	character_ref.data.inventory.consumable_equipped.connect(_on_consumable_equippped)
	init_eqiupment()


func _on_right_hand_weapon_equipped(weapon_data: WeaponData) -> void:
	print(weapon_data)
	if rh_weapon != null:
		# TODO play unequip animation here
		rh_weapon.queue_free()
		rh_weapon = null
	if weapon_data == null:
		return
	rh_weapon = weapon_data.scene.instantiate()
	rh_weapon.init(weapon_data, character_ref)
	right_hand_marker.add_child(rh_weapon, true)


func _on_left_hand_weapon_equipped(weapon_data: WeaponData) -> void:
	if lh_weapon != null:
		# TODO play unequip animation here
		lh_weapon.queue_free()
		lh_weapon = null

	if weapon_data == null:
		return
	lh_weapon = weapon_data.scene.instantiate()

	lh_weapon.init(weapon_data, character_ref)
	left_hand_marker.add_child(lh_weapon, true)


func _on_consumable_equippped(consumable: ItemData) -> void:
	pass


func init_eqiupment() -> void:
	var inventory: InventoryData = character_ref.data.inventory

	var rh_weapon_data: WeaponData = inventory.get_rh_weapon()
	if rh_weapon_data:
		rh_weapon = rh_weapon_data.scene.instantiate()
		right_hand_marker.add_child(rh_weapon, true)

	var lh_weapon_data: WeaponData = inventory.get_lh_weapon()
	if lh_weapon_data:
		lh_weapon = lh_weapon_data.scene.instantiate()
		left_hand_marker.add_child(lh_weapon, true)
