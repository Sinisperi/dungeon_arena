class_name EquipmentComponent extends Node3D

## Responsible for instantiating weapon scenes
@export var left_hand_marker: Marker3D
@export var right_hand_marker: Marker3D

@export var character_ref: Character


func _ready() -> void:
	character_ref.data.inventory.right_hand_weapon_equipped.connect(_on_right_hand_weapon_equipped)

	character_ref.data.inventory.left_hand_weapon_equipped.connect(_on_left_hand_weapon_equipped)

	character_ref.data.inventory.consumable_equipped.connect(_on_consumable_equippped)


func _on_right_hand_weapon_equipped(weapon_data: WeaponData) -> void:
	pass


func _on_left_hand_weapon_equipped(weapon_data: WeaponData) -> void:
	pass


func _on_consumable_equippped(consumable: ItemData) -> void:
	pass
