extends Node

const ITEMS_PATH = "res://shared_resources/items/"

var _items: Dictionary[String, ItemData] = {}

func _ready() -> void:
	_load_items(ITEMS_PATH)

func _load_items(path: String) -> void:
	var dir: DirAccess = DirAccess.open(path)

	if !dir:
		push_error("Failed to load items from directory: " + path)
		return
	
	dir.list_dir_begin()
	var file_name: String = dir.get_next()


	while file_name != "":
		var full_path: String = path.path_join(file_name)
		if dir.current_is_dir():
			_load_items(full_path + "/")
		else:
			if file_name.ends_with(".tres") || file_name.ends_with(".remap"):
				_load_item(full_path)
		file_name = dir.get_next()
	dir.list_dir_end()

func _load_item(file_path: String) -> void:
	file_path = file_path.trim_suffix(".remap")
	var item: ItemData = load(file_path)
	_items[item.id] = item


func get_item(id: String) -> ItemData:
	if _items.has(id):
		return _items[id].duplicate()
	push_error("ITEM_DB: Was not able to find ", id, " in loaded items")
	return null
