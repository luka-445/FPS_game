class_name SceneTransitionController 
extends Control


@export var background : ColorRect
@export var animationPlayer : AnimationPlayer

func _unhandled_input(event):
	if event.is_pressed():
		Global.gameController.changeGuiScene("res://Scenes/UI/start_menu.tscn")
func transition(animation : String, seconds : float) -> void:
	animationPlayer.play(animation, -1.0, 1 / seconds)
