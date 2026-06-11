class_name ShrineOfTime extends Area3D

var time_essence_held: int = 500

# it will be on the wall of the central room

# Like Chinese incense clocks with strings that get burned to alarm
# So basically you can refill the clock, but if one out of 3 things is burned, difficulty rises and even if you
# refill it is not going to restore that thing
# maybe you cannot refill past that thing anymore so the max time gets shorter every time it burns that thing
# when all the things are burned, difficulty is at max

# have 4 pillars that will light up when you activate the seal
# when 4 pillars are lit, you go to the center to perform a ritual and summon the final boss or get teleported to the boss arena
# ritual will take time so you have to somehow defend

var essence_value: float = 0.6
var since_last_update: float = essence_value


func interact(player_ref: Player) -> void:
	time_essence_held += player_ref.stats.time_essence
	player_ref.change_time_essence_by(-player_ref.stats.time_essence)
	player_ref.stats.time_essence = 0


func _process(delta: float) -> void:
	if since_last_update <= 0.0:
		since_last_update = essence_value
		time_essence_held -= 1
		print(" essence left ", time_essence_held, " time left ")

	since_last_update -= delta
	if time_essence_held == 0.0:
		print("HAHAHA YOU LOOSE YOU FUCKERS")
