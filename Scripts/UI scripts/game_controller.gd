class_name GameController 
extends Node

@onready var transitionController = $GUI/TransitionController
#@onready var animationPlayer = $GUI/TransitionController/AnimationPlayer

@export var world3D : Node3D
@export var world2D : Node2D
@export var gui : Control

var current3DScene
var current2DScene
var currentGuiScene

func _ready() -> void:
	Global.gameController = self
	currentGuiScene = load("res://Scenes/UI/start_menu.tscn")

func _unhandled_input(event) -> void:
	if event.is_pressed():
		Global.gameController.changeGuiScene("res://Scenes/UI/options_menu.tscn")

# modular function to control user interface.
func changeGuiScene(new_scene : String, delete : bool = true, keepRunning : bool = false,
	transition : bool = true, 
	transitionIn : String = "fade_in", 
	transitionOut : String = "fade_out", 
	seconds : float = 1.0
) -> void:
	if  transition:
		transitionController.transition(transitionOut, seconds)
		await transitionController.animationPlayer.animation_finished
	
	if currentGuiScene != null:
		if delete:
			currentGuiScene.queue_free()
		elif keepRunning:
			currentGuiScene.visible = false
		else:
			gui.remove_child(currentGuiScene)
	
	var new = load(new_scene).instantiate()
	gui.add_child(new)
	currentGuiScene = new
	transitionController.transition(transitionIn, seconds)

func change3DScene(new_scene : String, delete : bool = true, keepRunning : bool = false) -> void:
	if current3DScene != null:
		if delete:
			current3DScene.queue_free()
		elif keepRunning:
			current3DScene.visible = false
		else:
			world3D.remove_child(current3DScene)
	
	var new = load(new_scene).instantiate()
	world3D.add_child(new)
	current3DScene = new

func change2DScene(new_scene : String, delete : bool = true, keepRunning : bool = false) -> void:
	if current2DScene != null:
		if delete:
			current2DScene.queue_free()
		elif keepRunning:
			current2DScene.visible = false
		else:
			world2D.remove_child(current2DScene)
	
	var new = load(new_scene).instantiate()
	world2D.add_child(new)
	current2DScene = new
