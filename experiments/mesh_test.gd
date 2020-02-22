extends Spatial

func _ready():
#	make_simple_triangle()
#	make_triangles_from_path()
	create_mesh()

func make_simple_triangle():
	var surfTool = SurfaceTool.new()

	surfTool.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	
	surfTool.add_color(Color(1, 0, 0, 1))
	surfTool.add_normal(Vector3(0, 1, 0))
	# first triangle is drawn counter-clockwise
	surfTool.add_vertex(Vector3(-10,3,-10))
	surfTool.add_vertex(Vector3(0,3,-10))
	surfTool.add_vertex(Vector3(-10,3,0))
	surfTool.add_vertex(Vector3(0,3,0))

	var meshInstance = MeshInstance.new()
	meshInstance.mesh = surfTool.commit()
	add_child(meshInstance)
	
func make_triangles_from_path():
	var p1 = Vector3(-10, 3, -10)
	var p2 = Vector3(-10, 3, 0)
	var p3 = Vector3(0, 3, 10)
	var r1 = make_rectangle(p1, p2)
	var r2 = make_rectangle(p2, p3)
	var curve = Curve3D.new()
	curve.clear_points()
	curve.add_point(r1[0], Vector3.ZERO, r1[0].direction_to(r1[1]) * r1[0].distance_to(r1[1]) * 0.8)
	curve.add_point(r2[1], r2[1].direction_to(r2[0]) * r2[0].distance_to(r2[1]) * 0.8)
	curve.tessellate()
	var c1 = curve.get_baked_points()
	curve.clear_points()
	curve.add_point(r2[2], Vector3.ZERO, r2[2].direction_to(r2[3]) * r2[2].distance_to(r2[3]) * 0.8)
	curve.add_point(r1[3], r1[3].direction_to(r1[2]) * r1[2].distance_to(r1[3]) * 0.8)
	curve.tessellate()
	var c2 = curve.get_baked_points()
	c2.invert()

	var surfTool = SurfaceTool.new()
	var material = SpatialMaterial.new()
	material.albedo_color = Color(1,0,0,1)
	surfTool.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	surfTool.set_material(material)
	surfTool.add_normal(Vector3(0, 1, 0))
#	surfTool.add_color(Color(1, 0, 0))
#	surfTool.add_uv(Vector2(0, 0))

	var smaller
	var bigger
	if c1.size() > c2.size():
		bigger = c1
		smaller = c2
	else:
		bigger = c2
		smaller= c1
	var vb
	var vs = smaller[0]
	for i in range(bigger.size() - 1):
		if i < smaller.size():
			vs = smaller[i]
		vb = bigger[i]
		surfTool.add_vertex(Vector3(vb.x, 0, vb.z))
		surfTool.add_vertex(Vector3(vs.x, 0, vs.z))
	#surfTool.add_vertex(Vector3(r2[2].x, 0, r2[2].z))
	var meshInstance = MeshInstance.new()
	meshInstance.mesh = surfTool.commit()
	add_child(meshInstance)
	
#func _process(delta):
#	var im = $ImmediateGeometry
#	im.clear()
#	im.begin(Mesh.PRIMITIVE_LINE_STRIP, null)
#	im.add_vertex(Vector3(0,3,-10))
#	im.add_vertex(Vector3(-10,3,-10))
#	im.add_vertex(Vector3(-10,3,0))
#	im.add_vertex(Vector3(0,3,-10))
#	im.add_vertex(Vector3(0,3,0))
#	im.add_vertex(Vector3(-10,3,0))
#	im.end()


func make_rectangle(p1, p2, width = 0.25):
	# perpendicular vector with y at midpoint and length
	var ppv = Vector3(p2.z - p1.z, max((p1.y + p2.y) / 2, 0.01), -(p2.x - p1.x)).normalized() * width
	return PoolVector3Array([p1 + ppv, p2 + ppv, p2 - ppv, p1 - ppv])

func create_array_mesh():
	var vertices = PoolVector3Array()
	var uvs = PoolVector2Array()
	var normals = PoolVector3Array()
	vertices.push_back(Vector3(-5, 1, -3))
	vertices.push_back(Vector3(-4, 1, -3))
	vertices.push_back(Vector3(-5, 1, 1))
	vertices.push_back(Vector3(-4, 1, 1))
	normals.push_back(Vector3.UP)
	uvs.push_back(Vector2.ZERO)
	var arrays = []
	arrays.resize(ArrayMesh.ARRAY_MAX)
	arrays[ArrayMesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_NORMAL] = normals
	# Create the Mesh.
	var arr_mesh = ArrayMesh.new()
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, arrays)
	ResourceSaver.save("res://quad.mesh", arr_mesh)

func create_mesh():
	var surfTool = SurfaceTool.new()
	var material = SpatialMaterial.new()
	material.albedo_color = Color(1,0,0,1)
	surfTool.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	surfTool.add_normal(Vector3.UP)
	surfTool.add_uv(Vector2.ZERO)
	surfTool.add_vertex(Vector3(-1, 1, -1))
	surfTool.add_vertex(Vector3(1, 1, -1))
	surfTool.add_vertex(Vector3(-1, 1, 1))
	surfTool.add_vertex(Vector3(1, 1, 1))
	var mesh = surfTool.commit()
	ResourceSaver.save("res://experiments/assets/quad_square.mesh", mesh)
