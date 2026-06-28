class_name AilmentStatus extends Resource
signal ailment_inflicted(ailment: int)
signal ailment_cured(ailment: int)
signal ailment_buildup_value_changed(ailment: int, value: float)

enum { NONE = 0, POISON = 1 << 0, IGNITE = 1 << 1, STUN = 1 << 2 }

@export var poison_buildup: Stat
@export var ignite_buildup: Stat
@export var stun_buildup: Stat

var current_ailment: int = NONE

var resistance_decay_mult: float = 0.05
var poison_decay_delay: float = 3.0
var current_poison_decay_delay: float = 0.0
var ignite_decay_delay: float = 2.0
var current_ignite_decay_delay: float = 0.0
var stun_decay_delay: float = 5.0
var current_stun_decay_delay: float = 0.0


func has_ailment(ailment: int) -> bool:
	return current_ailment & ailment


func add_ailment(ailment: int) -> void:
	current_ailment |= ailment
	ailment_inflicted.emit(ailment)


func remove_ailment(ailment: int) -> void:
	current_ailment &= ~ailment
	ailment_cured.emit(ailment)


func init() -> void:
	poison_buildup.value_changed.connect(
		func(value: float) -> void: _on_buildup_changed(POISON, value)
	)
	ignite_buildup.value_changed.connect(
		func(value: float) -> void: _on_buildup_changed(IGNITE, value)
	)
	stun_buildup.value_changed.connect(func(value: float) -> void: _on_buildup_changed(STUN, value))

	poison_buildup.max_value_reached.connect(func() -> void: _on_max_value_reached(POISON))
	ignite_buildup.max_value_reached.connect(func() -> void: _on_max_value_reached(IGNITE))
	stun_buildup.max_value_reached.connect(func() -> void: _on_max_value_reached(STUN))

	poison_buildup.depleted.connect(func() -> void: _on_buildup_depleted(POISON))
	ignite_buildup.depleted.connect(func() -> void: _on_buildup_depleted(IGNITE))
	stun_buildup.depleted.connect(func() -> void: _on_buildup_depleted(STUN))


func increase_ailment_buildup(type: int, value: float) -> void:
	if has_ailment(type):
		return
	match type:
		POISON:
			poison_buildup.value += value
			current_poison_decay_delay = poison_decay_delay
		IGNITE:
			ignite_buildup.value += value
			current_ignite_decay_delay = ignite_decay_delay
		STUN:
			stun_buildup.value += value
			current_stun_decay_delay = stun_decay_delay
		_:
			return


func _on_buildup_changed(type: int, value: float) -> void:
	ailment_buildup_value_changed.emit(type, value)


func _on_max_value_reached(type: int) -> void:
	add_ailment(type)
	ailment_inflicted.emit(type)
	if type == STUN:
		stun_buildup.value = 0.0


func _on_buildup_depleted(type: int) -> void:
	remove_ailment(type)
	ailment_cured.emit(type)


func process_ailments_decay(delta: float, resistances: Resistances) -> void:
	if !has_ailment(POISON):
		if current_poison_decay_delay <= 0.0:
			poison_buildup.value -= resistances.res_poison.value * resistance_decay_mult * delta
	if !has_ailment(IGNITE):
		if current_ignite_decay_delay <= 0.0:
			ignite_buildup.value -= resistances.res_ignite.value * resistance_decay_mult * delta
	if !has_ailment(STUN):
		if current_stun_decay_delay <= 0.0:
			stun_buildup.value -= resistances.res_stun.value * resistance_decay_mult * delta

	current_poison_decay_delay -= delta
	current_ignite_decay_delay -= delta
	current_stun_decay_delay -= delta
