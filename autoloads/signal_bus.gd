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
	signal notification_pop_up_requested(title: String, body: String)
