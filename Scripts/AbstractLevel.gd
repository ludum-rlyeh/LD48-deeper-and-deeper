extends Node2D

var Ladder = preload("res://Scenes/InGame/Elements/Ladder.tscn")
var PlayerTscn = preload("res://Scenes/InGame/Characters/Character.tscn")
var RopeTscn = preload("res://Scenes/InGame/Elements/Rope.tscn")

var InventoryTscn = preload("res://Scenes/InGame/HUD/Inventory.tscn")

var player = null
var inventory


# The arguments should be the inputs of a levels:
# - One objective
# - The starting position of the player
# - The inventory
# - The position of the "artefact"
func init_level(player_start_pos: Vector2, start_inventory, objectif_position: Vector2):
	self.player = init_player(player_start_pos)
	self.add_child(player)
	self.inventory = init_inventory(start_inventory)
	self.player.add_child(inventory)


func init_player(player_start_pos: Vector2):
	var player = PlayerTscn.instance()
	player.set_position(player_start_pos)
	return player

func init_inventory(start_inventory):
	var inventory = InventoryTscn.instance()
	inventory.set_inventory(start_inventory)
	return inventory

# Called automatically before childs.
func _ready():
	Events.connect("place_ladder_signal", self, "_on_place_ladder_signal")
	Events.connect("throw_rope_signal", self, "_on_throw_rope_signal")


func _on_place_ladder_signal():
	if _player_is_on_platform() and not _player_is_above("Boxes"):
		var ladder = Ladder.instance()
		ladder.position += player.position
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
	else:
		Events.emit_signal("ladder_not_placed_signal") # not connected yet


func _on_throw_rope_signal():
	var area = _player_is_on_rope_spot()
	if area != null:
		var root = area.get_root_scene()
		var pos = root.position
		var right = root.right
		Events.emit_signal("rope_thrown_signal")
		var rope = RopeTscn.instance()
		rope.init(right, 200)
		add_child(rope)

		rope.set_position(pos+Vector2(10 if right else -10, 0))
		rope.start_animation()

func _player_is_on_platform():
	return player.find_node("PlatformDetector", false).is_colliding() or \
		   player.find_node("PlatformDetectorCornerLeft", false).is_colliding()  or \
		   player.find_node("PlatformDetectorCornerRight", false).is_colliding()

func _player_is_above(group: String):
	return (player.find_node("PlatformDetector", false).is_colliding() and player.find_node("PlatformDetector", false).get_collider().is_in_group(group)) or \
		   (player.find_node("PlatformDetectorCornerLeft", false).is_colliding() and player.find_node("PlatformDetectorCornerLeft", false).get_collider().is_in_group(group)) or \
		   (player.find_node("PlatformDetectorCornerRight", false).is_colliding() and player.find_node("PlatformDetectorCornerRight", false).get_collider().is_in_group(group)) 

func _player_is_on_rope_spot():
	for area in player.find_node("GroundArea", false).get_overlapping_areas():
		if area.is_in_group("RopeSpots"):
			return area
	return null
