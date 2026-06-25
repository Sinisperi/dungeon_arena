extends Node

var dungeon = DungeonSignals.new()
var ui = UISignals.new()
var game = GameSignals.new()

signal crash_game
signal enemy_spawned
var enemies: int = 0


class DungeonSignals:
	signal seal_activated(index: int)
	signal navigation_bake_finished
	signal path_mark_placed(position_data: Dictionary, tex_id: int)
	signal boss_spawned
	signal boss_defeated


class UISignals:
	signal notification_pop_up_requested(title: String, body: String)


class GameSignals:
	signal dungeon_loaded(player_spawn_position)
	signal item_dropped(item_data: ItemData)
	signal item_picked_up(item_uuid: String)
	signal player_died(peer_id: int)
