extends Node2D

var LadderTscn = preload("res://Scenes/InGame/Elements/Ladder.tscn")
var PlayerTscn = preload("res://Scenes/InGame/Characters/Character.tscn")
var RopeTscn = preload("res://Scenes/InGame/Elements/Rope.tscn")
var InventoryTscn = preload("res://Scenes/InGame/HUD/Inventory.tscn")
var ObjectiveTscn = preload("res://Scenes/InGame/Elements/Objective.tscn")

var player = null
var inventory
var objective = null
var exit = null

var objective_reached = false

# The arguments should be the inputs of a levels:
# - One objective
# - The starting position of the player
# - The inventory
# - The position of the "artefact"
func init_level(player_start_pos: Vector2, 
				start_inventory, 
				objectif_position: Vector2, 
				end_position: Vector2):
	self.player = init_player(player_start_pos)

	self.inventory = init_inventory(start_inventory)
#	self.player.find_node("Camera2D", false).add_child(inventory)
	var hud_layer = CanvasLayer.new()
	hud_layer.add_child(inventory)
	hud_layer.layer = 1
	add_child(hud_layer)
	# Init the two objectives (the point to reach, and the exit)
	self.objective = self.init_objective(objectif_position, "objective_reached_signal")
	self.exit = self.init_objective(end_position, "exit_reached_signal")

func init_player(player_start_pos: Vector2):
	var player = PlayerTscn.instance()
	player.set_position(player_start_pos)
	self.add_child(player)
	return player


func init_inventory(start_inventory):
	var inventory = InventoryTscn.instance()
	inventory.set_inventory(start_inventory)
	return inventory


func init_objective(objectif_position: Vector2, objective_signal: String):
	var objective = ObjectiveTscn.instance()
	objective.set_signal_to_emit(objective_signal)
	objective.set_position(objectif_position)
	self.add_child(objective)
	return objective


# Called automatically before childs.
func _ready():
	# Emitted by player
	Events.connect("place_ladder_signal", self, "_on_place_ladder_signal")
	Events.connect("throw_rope_signal", self, "_on_throw_rope_signal")

	# Emitted by res://Scenes/InGame/Elements/Objective.tscn
	Events.connect("objective_reached_signal", self, "_on_player_reached_objective")
	Events.connect("exit_reached_signal", self, "_on_player_reached_exit")

func _on_place_ladder_signal():
	if _player_is_on_platform() and not _player_is_above("Boxes"):
		var ladder = LadderTscn.instance()
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
		var tp_position_offset = root.find_node("Offset").position
		rope.init(right, GlobalData.LENGTH_ROPE, tp_position_offset)
		rope.position = pos
		if not right:
			rope.scale.x = -1
		add_child(rope)
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


func _on_player_reached_objective():
	self.objective_reached = true
	self.objective.toggle()

func _on_player_reached_exit():
	if self.objective_reached:
		self.exit.toggle()
		print("GG !")
