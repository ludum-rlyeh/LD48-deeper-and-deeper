extends Node2D

var Ladder = preload("res://Scenes/InGame/Elements/Ladder.tscn")
var PlayerTscn = preload("res://Scenes/InGame/Characters/Character.tscn")

var player = null


# The arguments should be the inputs of a levels:
# - One objective
# - The starting position of the player
# - The inventory
# - The position of the "artefact"
func init_level(player_start_pos: Vector2, start_inventory, objectif_position: Vector2):
	self.player = init_player(player_start_pos, start_inventory)
	self.add_child(player)


func init_player(player_start_pos: Vector2, player_inventory):
	var player = PlayerTscn.instance()
	player.set_position(player_start_pos)
	player.set_inventory(player_inventory)
	return player


# Called automatically before childs.
func _ready():
	Events.connect("place_ladder_signal",self, "_on_place_ladder_signal")


func _on_place_ladder_signal():
	var ladder = Ladder.instance()
	ladder.position += $Character.position
	ladder.visible = false
	add_child(ladder)
	
	# wait adding child and next process
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	
	var overlapping = false
	for body in ladder.find_node("Area2D", false).get_overlapping_bodies():
		if body is StaticBody2D:
			overlapping = true
			break
	
	if overlapping:
		remove_child(ladder)
		Events.emit_signal("ladder_not_placed_signal") # not connected yet
	else:
		ladder.visible = true
		Events.emit_signal("ladder_placed_signal")
	
