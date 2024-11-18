extends Node3D

var maxDistance : float
var _trailMeshHeight : float

@export var _trailMesh : MeshInstance3D
@export var _bulletLifeTime : float = 1
@export var _bulletSpeed : float = 50

func _ready():
	_trailMeshHeight = _trailMesh.mesh.height

	if maxDistance == 0:
		await get_tree().create_timer(_bulletLifeTime).timeout
		queue_free()
	

func _process(delta):
	_trailMeshHeight += Vector3.FORWARD * _bulletSpeed * delta
	
	if maxDistance > 0 and \
	global_position.distance_to(_trailMesh.global_position) >= \
	( maxDistance - (_trailMeshHeight * 2)):
		queue_free()
