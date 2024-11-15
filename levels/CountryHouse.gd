extends Node3D

@onready var hit = $UI/hit
@onready var spawnsNode = $Map/Spawns
@onready var navRegionNode = $Map/NavigationRegion3D

var tier1Zombie = load("res://Scenes/tier1_zombie.tscn")
var tier2Zombie = load("res://Scenes/enemies/tier2_zombie.tscn")
var zombieInstance
	
var maxTier1ZombieCount : int = 10
var maxTier2ZombieCount : int = 5
var maxTier3ZombieCount : int = 1
var currentTier1ZombieCount : int = 0
var currentTier2ZombieCount : int = 0
var currentxTier3ZombieCount : int = 0

func _ready():
	Global.currentLevel = self
	randomize()
	EventBus.playerHit.connect(onPlayer_playerHit)

func onPlayer_playerHit():
	hit.visible = true
	await get_tree().create_timer(0.1).timeout
	hit.visible = false

func _getRandomSpawn(parentNode):
	var randomID = randi() % parentNode.get_child_count()
	return parentNode.get_child(randomID)

func _getSpawnPoints():
	var spawnPointTier1 = _getRandomSpawn(spawnsNode).global_position
	var spawnPointTier2 = _getRandomSpawn(spawnsNode).global_position
	
	while spawnPointTier1 == spawnPointTier2:
		spawnPointTier2 = _getRandomSpawn(spawnsNode).global_position
	
	return [spawnPointTier1, spawnPointTier2]
	
func _on_zombie_spawn_timer_timeout():
	spawnEnemies()

func spawnEnemies():
	var spawnPoints = _getSpawnPoints()
	_spawnTier1(spawnPoints[0])
	_spawnTier2(spawnPoints[1])

func _spawnTier1(spawnPoint):
	zombieInstance = tier1Zombie.instantiate()
	zombieInstance.position = spawnPoint
	navRegionNode.add_child(zombieInstance)
	currentTier1ZombieCount += 1

func _spawnTier2(spawnPoint):
	zombieInstance = tier2Zombie.instantiate()
	zombieInstance.position = spawnPoint
	navRegionNode.add_child(zombieInstance)
	currentTier2ZombieCount += 1
