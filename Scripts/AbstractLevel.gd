extends Node2D

var InventoryTscn = preload("res://Scenes/InGame/HUD/Inventory.tscn")

var LadderTscn = preload("res://Scenes/InGame/Elements/Ladder.tscn")
var RopeTscn = preload("res://Scenes/InGame/Elements/Rope.tscn")

export (Dictionary) var start_inventory = {
	GlobalData.OBJECT_TYPE.ROPE: 0,
	GlobalData.OBJECT_TYPE.LADDER: 0
}

export (Vector2) var limits_right_corner = Vector2(1024, 600)

export (GlobalData.TREASURE_TYPE) var end_treasure = GlobalData.TREASURE_TYPE.SLIP

var objective_reached = false

onready var player = $Elements/Character

# Called when the node enters the scene tree for the first time.
# Called automatically before childs.
func _ready():
	# Emitted by player
	Events.connect("place_ladder_signal", self, "_on_place_ladder_signal")
	Events.connect("throw_rope_signal", self, "_on_throw_rope_signal")
	
	# Emitted by res://Scenes/InGame/Elements/Objective.tscn
	Events.connect("objective_reached_signal", self, "_on_objective_reached_signal")
	# Emitted by res://Scenes/InGame/Elements/Entry.tscn
	Events.connect("exit_reached_signal", self, "_on_exit_reached_signal")
	
	# Init camera linked to the player
	var camera = player.find_node("Camera2D")
	camera.limit_right = limits_right_corner.x
	camera.limit_bottom = limits_right_corner.y
	
	# Init inventory
	var inventory = InventoryTscn.instance()
	inventory.set_inventory(start_inventory)
	var hud_layer = CanvasLayer.new()
	hud_layer.add_child(inventory)
	hud_layer.layer = 1
	add_child(hud_layer)
	

func _on_objective_reached_signal():
	if not objective_reached:
		objective_reached = true
		$Elements/Entry.toggle()

func _on_exit_reached_signal():
	if objective_reached:
		Events.emit_signal("victory_signal", end_treasure)

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
		Events.emit_signal("rope_thrown_signal", area)
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
