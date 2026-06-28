class_name PlayerStats extends CharacterStats

@export var attributes: Attributes


func init() -> void:
	super.init()
	attributes.vitality.max_value_changed.connect(_on_vitality_changed)
	attributes.endurance.max_value_changed.connect(_on_endurance_changed)
	attributes.skill.max_value_changed.connect(_on_skill_changed)


func _on_vitality_changed(new_value: float) -> void:
	pass


func _on_endurance_changed(new_value: float) -> void:
	pass


func _on_skill_changed(new_value: float) -> void:
	pass
