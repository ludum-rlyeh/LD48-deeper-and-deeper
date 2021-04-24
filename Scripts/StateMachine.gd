extends Node

class_name StateMachine



var velocity = Vector2.ZERO
onready var player = get_parent()

var _state : Object

func _ready():
	_state = get_node("Normal")
	_enter_state([])

func change_to(new_state, args : Array):
	_state = get_node(new_state)
	_enter_state(args)
	
func _enter_state(args : Array):
	_state.fsm = self
	_state.enter(args)
	
func _process(delta):
	if _state.has_method("process"):
		_state.process(delta)
		
func _physics_process(delta):
	if _state.has_method("physics_process"):
		_state.physics_process(delta)

func _input(event):
	if _state.has_method("input"):
		_state.input(event)

func _unhandled_input(event):
	if _state.has_method("unhandled_input"):
		_state.unhandled_input(event)

func _unhandled_key_input(event):
	if _state.has_method("unhandled_key_input"):
		_state.unhandled_key_input(event)

func _notification(what):
	if _state && _state.has_method("notification"):
		_state.notification(what)
