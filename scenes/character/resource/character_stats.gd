class_name CharacterStats extends Resource

signal buff_added(buff: Buff)
signal buff_removed(buff: Buff)
signal ailment_inflicted(ailment: Ailment)
signal ailment_cured(ailment: Ailment)
signal health_changed(value: float)
signal stamina_changed(value: float)
signal mana_changed(value: float)



@export_group("Vitals")

@export var health: Stat

@export var stamina: Stat

@export var mana: Stat

@export_group("Resistances")
#=======================================================
@export_category("Temp")

@export var damage: float:
	get():
		push_warning("Damage should be a thing that is calculated instead of just a stat")
		return damage

#=======================================================
#=======AILMENTS================================
enum Ailment {
	NONE = 0,
	POISONED = 1 << 0,
	BURNING = 1 << 1,
	# while stunned you have a delay in input for like a 3 sec
	# and maybe screen is a bit hazy
	STUNNED = 1 << 2
}

var current_ailment: int = Ailment.NONE

func has_ailment(ailment: Ailment) -> bool:
	return current_ailment & ailment


func add_ailment(ailment: Ailment) -> void:
	current_ailment |= ailment
	ailment_inflicted.emit(ailment)


func remove_ailment(ailment: Ailment) -> void:
	current_ailment &= ~ailment
	ailment_cured.emit(ailment)
var _active_buffs: Dictionary[String, Buff] = {}
#=======AILMENTS================================

#========BUFFS==================================
func update_buffs(delta: float) -> void:
	if !_active_buffs.size():
		return
	for buff_id: String in _active_buffs.keys().duplicate():
		_active_buffs[buff_id].update(self, delta)


func add_buff(buff: Buff) -> void:
	var buff_dup: Buff = buff.duplicate()
	buff_dup.apply(self)
	_active_buffs[buff.id] = buff_dup
	buff_dup.expired.connect(_on_buff_expired)
	buff_added.emit(buff_dup)



func _on_buff_expired(buff: Buff) -> void:
	remove_buff(buff)


func remove_buff(buff: Buff) -> void:
	_active_buffs.erase(buff.id)
	buff.remove(self)
	buff.expired.disconnect(_on_buff_expired)
	buff_removed.emit(buff)
#========BUFFS==================================

func init() -> void:
	pass
