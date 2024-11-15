extends CharacterBody3D

var player = null
var stateMachine
const SPEED = 4.0
const ATTACK_RANGE = 1.4
const DAMAGE : float = 10.0
var health : int = 5
var playDeathAnimation : bool = false
@export var playerPath := "/root/CountryHouse/Map/NavigationRegion3D/player"
@onready var worldCollider = $CollisionShape3D
@onready var navAgent = $NavigationAgent3D
@onready var animationTree = $AnimationTree


func _ready():
	player = get_node(playerPath)
	stateMachine = animationTree.get("parameters/playback")
	
func _process(delta):
	velocity = Vector3.ZERO
	
	# navigation
	match stateMachine.get_current_node():
		"tier2_run":
			navAgent.set_target_position(player.global_transform.origin)
			var nextNavPoint = navAgent.get_next_path_position()
			velocity = (nextNavPoint - global_transform.origin).normalized() * SPEED
			rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10)
			look_at(Vector3(global_position.x + velocity.x, global_position.y, global_position.z + velocity.z),
			 Vector3.UP)
		"tier2_attack":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	#conditions
	animationTree.set("parameters/conditions/attack", _targetInRange())
	animationTree.set("parameters/conditions/run",!_targetInRange())

	move_and_slide()

func _targetInRange():
	return global_position.distance_to(player.global_position) < ATTACK_RANGE

func _hitFinished():
	if global_position.distance_to(player.global_position) < ATTACK_RANGE:
		var dir = global_position.direction_to(player.global_position)
		player.hit(dir)


func _on_area_3d_body_part_hit(damage):
	health -= damage
	if health <= 0:
		worldCollider.disabled = true
		animationTree.set("parameters/conditions/die", true)
		await get_tree().create_timer(5.0).timeout
		queue_free()
		Global.currentLevel.currentTier2ZombieCount -= 1
