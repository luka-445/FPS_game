extends CharacterBody3D

var player = null
var stateMachine
const SPEED = 4.0
const ATTACK_RANGE = 1.4

@export var playerPath : NodePath

@onready var navAgent = $NavigationAgent3D
@onready var animationTree = $AnimationTree


func _ready():
	player = get_node(playerPath)
	stateMachine = animationTree.get("parameters/playback")
	
func _process(delta):
	velocity = Vector3.ZERO
	
	# navigation
	match stateMachine.get_current_node():
		"tier1_run":
			navAgent.set_target_position(player.global_transform.origin)
			var nextNavPoint = navAgent.get_next_path_position()
			velocity = (nextNavPoint - global_transform.origin).normalized() * SPEED
			look_at(Vector3(global_position.x + velocity.x, global_position.y,global_position.z + velocity.z), Vector3.UP)
		"tier1_attack":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	
	
	
	
	#conditions
	animationTree.set("parameters/conditions/attack", _targetInRange())
	animationTree.set("parameters/conditions/run",!_targetInRange())

	move_and_slide()

func _targetInRange():
	return global_position.distance_to(player.global_position) < ATTACK_RANGE

func _hitFinished():
	player.hit()
