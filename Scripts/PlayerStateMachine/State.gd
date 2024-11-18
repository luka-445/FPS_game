class_name State

extends Node

# This is a Generic State script that will be used as a super class.
# Individual states will inherit this script and create their own unique values
# and function based on need.

# Create Signal to communicate between state script and states.
signal transition(newStateName: StringName)

# enter and exit functions control when new state is either entered or current state is exited.
func enter() -> void:
	pass

func exit() -> void:
	pass

# Process function for every frame (equivalent to _process)
func update(_delta: float) -> void:
	pass

# equivalent to _physics_process function.
func physics_update(_delta: float) -> void:
	pass
