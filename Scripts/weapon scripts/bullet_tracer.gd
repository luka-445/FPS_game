extends MeshInstance3D


@onready var blood = $BloodSplatter
@onready var terrain = $TerrainSplatter


func _ready():
	var dup_mat = material_override.duplicate()
	material_override = dup_mat

func init(pos1, pos2):
	var draw_mesh = ImmediateMesh.new()
	mesh = draw_mesh
	draw_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material_override)
	draw_mesh.surface_add_vertex(pos1)
	draw_mesh.surface_add_vertex(pos2)
	draw_mesh.surface_end()

func triggerParticles(pos, gunPos, onEnemy):
	if onEnemy:
		blood.position = pos
		blood.look_at(gunPos)
		blood.emitting = true
	else: 
		terrain.position = pos
		terrain.look_at(gunPos)
		terrain.emitting = true
func _on_timer_timeout():
	queue_free()
