class_name Level
extends Node3D

@onready var spawnsNode = $Map/Spawns
@onready var navRegionNode = $Map/NavigationRegion3D
@onready var player = $Map/NavigationRegion3D/player

# TIMERS
@onready var increaseTier1Max = $Timers/IncreaseTier1Max
@onready var increaseTier2Max = $Timers/IncreaseTier2Max
@onready var increaseTier3Max = $Timers/IncreaseTier3Max
@onready var surviveTimer = $Timers/SurviveTimer
var seconds : int = 0
var minutes : int = 0

@onready var label = $HUD/Label

const MAX_TIER1_COUNT = 50
const MAX_TIER2_COUNT = 10
const MAX_TIER3_COUNT = 3

var tier1Zombie = load("res://Scenes/enemies/tier1_zombie.tscn")
var tier2Zombie = load("res://Scenes/enemies/tier2_zombie.tscn")
var tier3Zombie = load("res://Scenes/enemies/tier3_zombie.tscn")
var zombieInstance

var canTier2Spawn : bool = true
var canTier3Spawn : bool = true
var currentMaxTier1ZombieCount : int = 10  #30
var currentMaxTier2ZombieCount : int = 0
var currentMaxTier3ZombieCount : int = 0
var currentTier1ZombieCount : int = 0
var currentTier2ZombieCount : int = 0
var currentTier3ZombieCount : int = 0

var gameOver : bool = false
var victory : bool = false

func _ready():
	get_tree().paused = false
	Global.currentLevel = self
	randomize()

func _process(_delta):
	if Global.debug.visible:
		Global.debug.AddProperty("Tier1Count", currentTier1ZombieCount, 2)
		Global.debug.AddProperty("Tier2Count", currentTier2ZombieCount, 3)
		Global.debug.AddProperty("Tier3Count", currentTier3ZombieCount, 4)
		Global.debug.AddProperty("Tier1MaxCount", currentMaxTier1ZombieCount, 5)
		Global.debug.AddProperty("Tier2MaxCount", currentMaxTier2ZombieCount, 6)
		Global.debug.AddProperty("Tier3MaxCount", currentMaxTier3ZombieCount, 7)
	
	if player.currentHealth <= 0 and gameOver == false:
		gameOver = true
		get_tree().change_scene_to_file("res://Scenes/UI/game_over.tscn")
	
	if minutes == 10 and victory == false:
		victory = true
		get_tree().change_scene_to_file("res://Scenes/UI/survived.tscn")


func _getRandomSpawn(parentNode):
	var randomID = randi() % parentNode.get_child_count()
	return parentNode.get_child(randomID)

func _getSpawnPoints():
	var spawnPointTier1 = _getRandomSpawn(spawnsNode).global_position
	var spawnPointTier2 = _getRandomSpawn(spawnsNode).global_position
	var spawnPointTier3 = _getRandomSpawn(spawnsNode).global_position
	
	# Make sure tier 1 enemies don't spawn inside of tier 2 or 3.
	while spawnPointTier1 == spawnPointTier2 or spawnPointTier1 == spawnPointTier3 or spawnPointTier2 == spawnPointTier3:
		# if tier2 inside of tier 1 change tier2 spawn.
		if spawnPointTier1 == spawnPointTier2:
			spawnPointTier2 = _getRandomSpawn(spawnsNode).global_position
		
		# if tier3 inside of tier1 change tier3 spawn
		if spawnPointTier1 == spawnPointTier3:
			spawnPointTier3 = _getRandomSpawn(spawnsNode).global_position
		
		# make sure tier 3 not inside tier 2.
		if spawnPointTier2 == spawnPointTier3:
			spawnPointTier3 = _getRandomSpawn(spawnsNode).global_position
	
	return [spawnPointTier1, spawnPointTier2, spawnPointTier3]
	
func _on_zombie_spawn_timer_timeout():
	spawnEnemies()

func spawnEnemies():
	var spawnPoints = _getSpawnPoints()
	_spawnTier1(spawnPoints[0]) 
	if canTier2Spawn == true:
		_spawnTier2(spawnPoints[1])
	
	if canTier3Spawn == true:
		_spawnTier3(spawnPoints[2])

func _spawnTier1(spawnPoint):
	# Spawn if current is less than max.
	if currentTier1ZombieCount < currentMaxTier1ZombieCount:
		zombieInstance = tier1Zombie.instantiate()
		zombieInstance.position = spawnPoint
		navRegionNode.add_child(zombieInstance)
		currentTier1ZombieCount += 1

func _spawnTier2(spawnPoint):
	# Spawn if current is less than max.
	if currentTier2ZombieCount < currentMaxTier2ZombieCount:
		zombieInstance = tier2Zombie.instantiate()
		zombieInstance.position = spawnPoint
		navRegionNode.add_child(zombieInstance)
		currentTier2ZombieCount += 1

func _spawnTier3(spawnPoint):
	# Spawn if current is less than max.
	if currentTier3ZombieCount < currentMaxTier3ZombieCount:
		zombieInstance = tier3Zombie.instantiate()
		zombieInstance.position = spawnPoint
		navRegionNode.add_child(zombieInstance)
		currentTier3ZombieCount += 1

func _on_survive_timer_timeout():
	seconds += 1
	if seconds == 60:
		seconds = 0
		minutes += 1
	label.set_text(str("Time survived ", minutes, " : ", str(seconds).pad_zeros(2)))


func _on_allow_tier_2_timer_timeout():
	canTier2Spawn = true
	currentMaxTier2ZombieCount = 5
	increaseTier2Max.start()


func _on_allow_tier_3_timer_timeout():
	canTier3Spawn = true
	currentMaxTier3ZombieCount = 1
	increaseTier3Max.start()


func _on_increase_tier_1_max_timeout():
	var newMax = currentMaxTier1ZombieCount * 1.2
	
	if newMax > MAX_TIER1_COUNT:
		newMax = MAX_TIER1_COUNT
		increaseTier1Max.stop()
	else:
		currentMaxTier1ZombieCount = newMax

func _on_increase_tier_2_max_timeout():
	var newMax = currentMaxTier2ZombieCount * 1.5
	
	if newMax > MAX_TIER2_COUNT:
		newMax = MAX_TIER2_COUNT
		increaseTier2Max.stop()
	else:
		currentMaxTier2ZombieCount = newMax


func _on_increase_tier_3_max_timeout():
	var newMax = currentMaxTier3ZombieCount + 1
	
	if newMax > MAX_TIER3_COUNT:
		newMax = MAX_TIER3_COUNT
		increaseTier3Max.stop()
	else:
		currentMaxTier3ZombieCount = newMax
