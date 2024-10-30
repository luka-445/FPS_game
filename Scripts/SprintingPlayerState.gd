class_name SprintingPlayerState extends State

@export var ANIMATION : AnimationPlayer
@export var TOP_ANIMATION_SPEED : float = 1.6

func enter() -> void:
	ANIMATION.play("Sprinting", 0.5, 1.0)
	Global.player.speed = Global.player.SPEED_SPRINT

func update(delta) -> void:
	SetAnimationSpeed(Global.player.velocity.length())

func SetAnimationSpeed(spd):
	var alpha = remap(spd, 0.0, Global.player.SPEED_SPRINT, 0.0, 1.0)
	ANIMATION.speed_scale = lerp(0.0, TOP_ANIMATION_SPEED, alpha)

func _input(event) -> void:
	if event.is_action_released("sprint"):
		transition.emit("WalkingPlayerState")
