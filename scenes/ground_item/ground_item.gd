class_name GroundItem extends Interactible

@export var info_popup_scene: PackedScene

var info_popup: GroundItemInfoPopup = null
@export var data: ItemData


func _ready() -> void:
	super._ready()


func interact(_player_ref: Player) -> void:
	print("picking up ", data.item_name)
	var success: bool = Globals.game_ui.inventory.add_item(data)
	if info_popup:
		await info_popup.dissapear()
		SignalBus.game.item_picked_up.emit(name)


func _on_player_in_proximity() -> void:
	if !info_popup:
		info_popup = info_popup_scene.instantiate()
		add_child(info_popup)
		info_popup.display(data)


func _on_player_left_proximity() -> void:
	if info_popup:
		info_popup.dissapear()
		info_popup = null


func despawn() -> void:
	if info_popup:
		info_popup.dissapear()
		info_popup = null
	call_deferred("queue_free")
