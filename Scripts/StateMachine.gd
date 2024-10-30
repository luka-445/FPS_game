class_name StateMachine

extends Node

@export var CURRENT_STATE : State 
var states: Dictionary = {}

func _ready():
	# Get states on game start and insert into states dictionary.
	for child in get_children():
		if child is State:
			states[child.name] = child
			# Connects signal from states script to the on_child_transition function
			child.transition.connect(on_child_transition)
		else: 
			push_warning("Incompatible child node not of type: State")
	
	CURRENT_STATE.enter()

func _process(delta):
	# update process calculations for set current state.
	CURRENT_STATE.update(delta)
	# Add Current state to debug panel for testing.
	Global.debug.AddProperty("Current State", CURRENT_STATE.name, 1)

func _physics_process(delta):
	# update physics calculation for the set current state.
	CURRENT_STATE.physics_update(delta)

# Function controls logic that updates State.
func on_child_transition(newStateName: StringName) -> void:
	var newState = states.get(newStateName)
	if newState != null:
		if newState != CURRENT_STATE:
			CURRENT_STATE.exit()
			newState.enter()
			CURRENT_STATE = newState
	else: 
		push_warning("Null State")
