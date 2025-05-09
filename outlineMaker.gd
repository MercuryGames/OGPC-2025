extends MeshInstance3D 
var test = load("res://outlinetesting.tres")
var mesh_outline = mesh.create_outline(0.05)
var outlineMesh = MeshInstance3D.new()
func _ready():
	add_child(outlineMesh)
	outlineMesh.set_mesh(mesh_outline)
	outlineMesh.set_surface_override_material(0, test)
	outlineMesh.show()
	print("1001")

func hideme():
	outlineMesh.hide()
	get_active_material(0).no_depth_test = false
	get_active_material(0).render_priority = 0

func showme():
	outlineMesh.show()
	#get_active_material(0).no_depth_test = true
	get_active_material(0).render_priority = 1
