extends Node

var dungeon = DungeonSignals.new()
var ui = UISignals.new()

signal crash_game
signal enemy_spawned
var enemies: int = 0


class DungeonSignals:
	signal seal_activated(player_ref: Player)
	signal navigation_bake_finished


class UISignals:
	signal toast_popup_requested(message)
