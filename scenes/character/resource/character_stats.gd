class_name CharacterStats extends Resource

signal status_effect_added(status_effect: StatusEffect)
signal status_effect_removed(status_effect: StatusEffect)
signal health_changed(value: float)
signal stamina_changed(value: float)
signal mana_changed(value: float)



@export_group("Vitals")

@export var health: Stat

@export var stamina: Stat

@export var mana: Stat

@export_category("Resistances")
@export var resistances: Resistances

@export_category("Ailments")
@export var ailment_status: AilmentStatus

#========BUFFS==================================



var _active_status_effects: Dictionary[String, StatusEffect] = {}
func process_status_effects(delta: float) -> void:
	if !_active_status_effects.size():
		return
	for status_effect_id: String in _active_status_effects.keys().duplicate():
		_active_status_effects[status_effect_id].update(self, delta)


func add_status_effect(status_effect: StatusEffect) -> void:
	var status_effect_dup: StatusEffect = status_effect.duplicate()
	status_effect_dup.apply(self)
	_active_status_effects[status_effect.id] = status_effect_dup
	status_effect_dup.expired.connect(_on_status_effect_expired)
	status_effect_added.emit(status_effect_dup)


func _on_status_effect_expired(status_effect: StatusEffect) -> void:
	remove_status_effect(status_effect)


func remove_status_effect(status_effect: StatusEffect) -> void:
	_active_status_effects.erase(status_effect.id)
	status_effect.remove(self)
	status_effect.expired.disconnect(_on_status_effect_expired)
	status_effect_removed.emit(status_effect)
#========BUFFS==================================

func update(delta) -> void:
	process_status_effects(delta)
	ailment_status.process_ailments_decay(delta, resistances)

func init() -> void:
	ailment_status.init()
