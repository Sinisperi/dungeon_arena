class_name PlayerStats extends CharacterStats

@export var attributes: Attributes


func init(player_name: String) -> void:
	super.init(player_name)
	attributes.vitality.max_value_changed.connect(_on_vitality_changed)
	attributes.endurance.max_value_changed.connect(_on_endurance_changed)
	attributes.skill.max_value_changed.connect(_on_skill_changed)
	print("connecting ", player_name)


func _on_vitality_changed(new_value: float) -> void:
	pass


func _on_endurance_changed(new_value: float) -> void:
	pass


func _on_skill_changed(new_value: float) -> void:
	pass
