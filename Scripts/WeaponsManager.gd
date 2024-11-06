extends Node3D

@export var ANIMATION_PLAYER : AnimationPlayer

var currentWeapon : Weapon

# array of weapons held by current player.
# array index 0 holds primary weapon.
# index 1 holds secondary weapon.
# index 2 holds melee weapon.
var weaponStack = []

# index of weapon in weaponStack.
var weaponIndicator : int = 0

var _nextWeapon : String

# Dictionary of all weapon resources.
var weaponDict = {}

# auxilary array used to build dictionary.
@export var weaponResourcesAux: Array[Weapon]

# holds starting weapons.
# this is in case more weapons are added later on.
# makes this system modular and expandable.
@export var startWeapons: Array[String]

func _ready():
	# Initilizes start of weapon state machine.
	InitWeapon()

func _input(event):
	# pull out primary weapon.
	if event.is_action_pressed("primaryWeapon"):
		exit(weaponStack[0])
	
	# pull out secondary weapon
	if event.is_action_pressed("secondaryWeapon"):
		exit(weaponStack[1])
	
	# pull out melee weapon
	if event.is_action_pressed("meleeWeapon"):
		exit(weaponStack[2])
	
func InitWeapon():
	
	# Create dictionary for reference to weapons.
	for weapon in weaponResourcesAux:
		weaponDict[weapon.weaponName] = weapon
	
	# Insert starting weapons into current weapon stack.
	for i in startWeapons:
		weaponStack.push_back(i)
	
	# set current weapon to frist weapon held by player in weapon stack and call enter.
	currentWeapon = weaponDict[weaponStack[0]]
	enter()


# call when entering into next weapon.
func enter():
	ANIMATION_PLAYER.queue(currentWeapon.animationPullout)

# Call exit before changing weapon.
func exit(nextWeapon):
	# if next is current than don't switch.
	if nextWeapon == currentWeapon.weaponName:
		return
	
	if ANIMATION_PLAYER.get_current_animation() != currentWeapon.animationPutaway:
		ANIMATION_PLAYER.play(currentWeapon.animationPutaway)
		_nextWeapon = nextWeapon

# Updates current weapon.
func ChangeWeapon(weaponName):
	# update current weapon to new weapon.
	currentWeapon = weaponDict[weaponName]
	# Reset next Weapon to empty string.
	_nextWeapon = ""
	# Enter new weapon.
	enter()

# sends signal when current animation is finished playing.
func _on_animation_player_animation_finished(anim_name):
	# when signal triggered, if anim_name == animationPutaway then change weapon.
	if anim_name == currentWeapon.animationPutaway:
		ChangeWeapon(_nextWeapon)
