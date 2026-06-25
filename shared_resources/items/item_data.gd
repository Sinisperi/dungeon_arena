class_name ItemData extends Resource

enum Type { WEAPON, CONSUMABLE }
@export var type: Type = Type.WEAPON
@export var item_name: String = ""
@export var texture: AtlasTexture

var id: String:
	get():
		return item_name.to_lower().replace(" ", "_")
