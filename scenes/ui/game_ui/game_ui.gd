class_name GameUI extends CanvasLayer

@export var hud: HUD
@export var inventory: Control
@export var pause_menu: Control

enum { NONE = 0, HUD = 1 << 0, INVENTORY = 1 << 1, PAUSE_MENU = 1 << 2, DEATH_SCREEN = 1 << 3 }

var current_ui_display: int = HUD


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Globals.game_ui = self
	inventory.open_requested.connect(_on_inventory_open_requested)
	inventory.close_requested.connect(_on_inventory_close_requested)


func _input(event: InputEvent) -> void:
	if event is InputEventKey && event.is_pressed():
		if event.keycode == KEY_TAB:
			toggle_ui_display(INVENTORY)
		elif event.keycode == KEY_ESCAPE:
			toggle_ui_display(PAUSE_MENU)


func _update() -> void:
	hud.visible = _is_current(HUD)
	inventory.visible = _is_current(INVENTORY)
	pause_menu.visible = _is_current(PAUSE_MENU)


func toggle_ui_display(ui_display: int) -> void:
	current_ui_display ^= ui_display
	_update()


func open_ui_display(ui_display: int) -> void:
	current_ui_display |= ui_display
	_update()


func close_ui_display(ui_display: int) -> void:
	current_ui_display &= ~ui_display
	_update()


func _is_current(ui_display: int) -> bool:
	return current_ui_display & ui_display


func _on_inventory_open_requested() -> void:
	open_ui_display(INVENTORY)


func _on_inventory_close_requested() -> void:
	close_ui_display(INVENTORY)
