class_name Seal extends Interactible

var index: int = 0
@export var is_main_seal: bool = false


func _ready() -> void:
	super._ready()
	if !is_main_seal:
		index = get_tree().get_nodes_in_group("seal").size()
		add_to_group("seal")


func interact(_player_ref: Player) -> void:
	_break_seal_request.rpc_id(1)


@rpc("call_local", "any_peer")
func _break_seal_request() -> void:
	_send_seal_update.rpc()


@rpc("call_local", "any_peer")
func _send_seal_update() -> void:
	SignalBus.dungeon.seal_activated.emit(index)
