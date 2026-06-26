class_name Buff extends Resource

signal expired(buff: Buff)
@export var name: String
@export var icon: Texture2D
@export var duration: float
@export var is_permanent: bool = false
var id: String:
	get():
		return name.to_lower().replace(" ", "_")


func apply(_stats: CharacterStats) -> void:
	pass


func update(_stats: CharacterStats, delta: float) -> void:
	if !is_permanent:
		duration -= delta
		if duration <= 0:
			expired.emit(self)
			return


func remove(_stats: CharacterStats) -> void:
	pass
