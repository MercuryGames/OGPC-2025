extends MeshInstance3D

@onready var player = get_tree().get_root().get_node("/root/TestRoom/Player")

var rando = RandomNumberGenerator.new()

var noise = NoiseTexture2D.new()

var time = 0
var heightMap = []
var gridsize = [150, 150]
@export var trilength : float

func _ready() -> void:
	noise = FastNoiseLite.new()
	noise.noise_type = 3
	heightMap.resize(gridsize[0])
	for i in heightMap.size():
		heightMap[i] = []
		heightMap[i].resize(gridsize[1])
	for i in heightMap.size():
		for j in heightMap[i].size():
			heightMap[i][j] = [noise.get_noise_2d(i, j), 0]

func _process(delta: float) -> void:
	position = player.position + Vector3(-(trilength*gridsize[0])/2, -15, -(trilength*gridsize[0])/2)
	position.y = 0#-10
	time += 1#0.3
	var material = self.get_active_material(0)
	material.set_shader_parameter("time", time)
	var meshData = []
	meshData.resize(ArrayMesh.ARRAY_MAX)
	meshData[ArrayMesh.ARRAY_VERTEX] = PackedVector3Array()
	meshData[ArrayMesh.ARRAY_TEX_UV] = PackedVector2Array()
	for i in heightMap.size():
		for j in heightMap[i].size():
			var k = i*trilength
			var f = j*trilength
			var cpos = get_global_position()+Vector3(k, heightMap[i][j][0], f)
			#print("cpos",cpos)
			#get position of the player's pointer
			var tpos = player.get_global_position()
			#print("tpos",tpos)
			#find the differance
			var posDiff = tpos - cpos
			var o = (abs(posDiff[0])+abs(posDiff[1])+abs(posDiff[2]))/9
			heightMap[i][j][0]= (noise.get_noise_3d(i+(position.x/trilength), time, j+(position.z/trilength))*5)
			#var l = 0.1*(1-abs(heightMap[i][j][0]))+0.001#( 0.1 + (noise.get_noise_3d(i, time, j)/100))*(1-abs(heightMap[i][j][0]))+0.001
			#if heightMap[i][j][0] > 1:
			#	heightMap[i][j][1] = 1
			#elif heightMap[i][j][0] < -1:
			#	heightMap[i][j][1] = 0
			#if heightMap[i][j][1] == 1:
			#	heightMap[i][j][0] -= l
			#else:
			#	heightMap[i][j][0] += l
			#heightMap[i][j] = noise.get_noise_3d(i/trilength/2, time, j/trilength/2)
	
	for i in heightMap.size()-1:
		for j in heightMap[i].size()-1:
			var k = i*trilength
			var f = j*trilength
			meshData[ArrayMesh.ARRAY_VERTEX].append(Vector3(k, heightMap[i][j][0], f))
			meshData[ArrayMesh.ARRAY_TEX_UV].append(Vector2(1, 1))
			meshData[ArrayMesh.ARRAY_VERTEX].append(Vector3(k + trilength, heightMap[i + 1][j][0], f))
			meshData[ArrayMesh.ARRAY_TEX_UV].append(Vector2(0, 1))
			meshData[ArrayMesh.ARRAY_VERTEX].append(Vector3(k, heightMap[i][j + 1][0], f + trilength))
			meshData[ArrayMesh.ARRAY_TEX_UV].append(Vector2(1, 0))
			meshData[ArrayMesh.ARRAY_VERTEX].append(Vector3(k + trilength , heightMap[i + 1][j][0], f))
			meshData[ArrayMesh.ARRAY_TEX_UV].append(Vector2(0, 1))
			meshData[ArrayMesh.ARRAY_VERTEX].append(Vector3(k + trilength, heightMap[i + 1][j + 1][0], f + trilength))
			meshData[ArrayMesh.ARRAY_TEX_UV].append(Vector2(0, 0))
			meshData[ArrayMesh.ARRAY_VERTEX].append(Vector3(k, heightMap[i][j + 1][0], f + trilength))
			meshData[ArrayMesh.ARRAY_TEX_UV].append(Vector2(1, 0))
	
	
	
	mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, meshData)
