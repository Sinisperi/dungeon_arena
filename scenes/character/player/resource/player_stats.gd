class_name PlayerStats extends CharacterStats

@export_group("Attributes")
@export var vitality: Stat
@export var endurance: Stat
@export var skill: Stat


func init() -> void:
	super.init()
	vitality.max_value_changed.connect(_on_vitality_changed)
	endurance.max_value_changed.connect(_on_endurance_changed)
	skill.max_value_changed.connect(_on_skill_changed)


func _on_vitality_changed(new_value: float) -> void:
	pass


func _on_endurance_changed(new_value: float) -> void:
	pass


func _on_skill_changed(new_value: float) -> void:
	pass
