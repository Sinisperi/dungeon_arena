class_name Stat extends Resource

signal value_changed(new_value: float)
signal max_value_changed(new_value: float)
signal max_value_reached
signal depleted

# current value
@export var value: float = 0.0:
	set(new_value):
		if value == new_value:
			return
		if max_value > 0:
			value = clamp(new_value, 0.0, max_value)
		else:
			value = new_value
		value_changed.emit(value)
		if value == max_value:
			max_value_reached.emit()
		if value <= 0.0:
			depleted.emit()
	get():
		return value

# max value without any buffs
# gets leveled up
@export var base_max_value: float = 0.0:
	set(new_value):
		if base_max_value == new_value:
			return
		base_max_value = max(0.0, new_value)
		max_value_changed.emit(max_value)
	get():
		return base_max_value

# max value + buffs like passives from talismans etc idk
var max_value: float = 0.0:
	get():
		return base_max_value + _buff_total

var _buff_total: float = 0.0


func apply_buff(amount: float) -> void:
	if amount == 0.0:
		return
	_buff_total += amount
	max_value_changed.emit(max_value)
