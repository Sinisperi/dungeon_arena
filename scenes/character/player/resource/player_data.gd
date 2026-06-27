class_name PlayerData extends CharacterData

signal time_essence_changed(value: int)
# some sort of currency that is going to be called something else
@export var time_essence: int:
	set(value):
		time_essence = max(0, value)
		time_essence_changed.emit(time_essence)
@export var currency: int = 0
@export var xp: int = 0
