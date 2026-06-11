class_name Seal extends Area3D


func interact(player_ref: Player) -> void:
	SignalBus.dungeon.seal_activated.emit(player_ref)
