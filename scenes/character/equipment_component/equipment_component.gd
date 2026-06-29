class_name EquipmentComponent extends Node3D

## Responsible for instantiating weapon scenes
@export var left_hand_marker: Marker3D
@export var right_hand_marker: Marker3D

@export var character_ref: Character

var lh_weapon: Weapon
var rh_weapon: Weapon


func begin_rh_swing() -> void:
	if rh_weapon:
		rh_weapon.begin_swing()


func end_rh_swing() -> void:
	if rh_weapon:
		rh_weapon.end_swing()


func begin_lh_swing() -> void:
	if lh_weapon:
		lh_weapon.begin_swing()


func end_lh_swing() -> void:
	if lh_weapon:
		lh_weapon.end_swing()


func init() -> void:
	if is_multiplayer_authority():
		character_ref.data.inventory.right_hand_weapon_equipped.connect(
			_on_right_hand_weapon_equipped
		)

		character_ref.data.inventory.left_hand_weapon_equipped.connect(
			_on_left_hand_weapon_equipped
		)

		character_ref.data.inventory.consumable_equipped.connect(_on_consumable_equippped)
		init_eqiupment()


func _on_right_hand_weapon_equipped(weapon_data: WeaponData) -> void:
	var weapon_resource_id: String = ""
	if weapon_data:
		weapon_resource_id = weapon_data.id
	_sync_right_hand_weapon.rpc(weapon_resource_id)


func _on_left_hand_weapon_equipped(weapon_data: WeaponData) -> void:
	var weapon_resource_id: String = ""
	if weapon_data:
		weapon_resource_id = weapon_data.id
	_sync_left_hand_weapon.rpc(weapon_resource_id)


@rpc("any_peer", "call_local", "reliable")
func _sync_right_hand_weapon(weapon_resource_id: String) -> void:
	rh_weapon = _equip_weapon(weapon_resource_id, rh_weapon, right_hand_marker)


@rpc("any_peer", "call_local", "reliable")
func _sync_left_hand_weapon(weapon_resource_id: String) -> void:
	lh_weapon = _equip_weapon(weapon_resource_id, lh_weapon, left_hand_marker)


func _equip_weapon(weapon_resource_id, weapon_ref: Weapon, hand_marker: Marker3D) -> Weapon:
	print("equipping weapon ", weapon_resource_id)
	if weapon_ref != null:
		# TODO play unequip animation here
		weapon_ref.queue_free()
		weapon_ref = null
	if weapon_resource_id == "":
		return
	var weapon_data: WeaponData = ItemDb.get_item(weapon_resource_id) as WeaponData
	weapon_ref = weapon_data.scene.instantiate()
	hand_marker.add_child(weapon_ref, true)
	weapon_ref.init(weapon_data, character_ref)
	var anim_player: AnimationPlayer = character_ref.animation_player
	if anim_player.has_animation_library("weapon"):
		anim_player.remove_animation_library("weapon")
	character_ref.animation_player.add_animation_library("weapon", weapon_data.animation_set)
	return weapon_ref


func _on_consumable_equippped(consumable: ItemData) -> void:
	pass


@rpc("any_peer", "call_local", "reliable")
func _sync_equipment() -> void:
	var inventory: InventoryData = character_ref.data.inventory
	var rh_weapon_data: WeaponData = inventory.get_rh_weapon()
	rh_weapon = _equip_weapon(rh_weapon_data.id, rh_weapon, right_hand_marker)
	var lh_weapon_data: WeaponData = inventory.get_lh_weapon()
	lh_weapon = _equip_weapon(lh_weapon_data.id, lh_weapon, left_hand_marker)


func init_eqiupment() -> void:
	await get_tree().process_frame
	_sync_equipment.rpc()
