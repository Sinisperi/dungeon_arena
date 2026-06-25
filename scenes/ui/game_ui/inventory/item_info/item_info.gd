class_name ItemInfo extends PanelContainer
@export var item_icon: TextureRect
@export var item_name_label: Label
@export var item_description_label: Label


func display(item_data: ItemData) -> void:
	if item_data:
		item_icon.texture = item_data.texture
		item_name_label.text = item_data.item_name
		#item_description_label.text = item_data.description
