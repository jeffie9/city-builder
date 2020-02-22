extends Spatial

onready var m = SpatialMaterial.new()
onready var roadMaterial = preload("res://assets/road_two_lane.material")

func _ready():
	m.flags_unshaded = true
	m.flags_use_point_size = true
	m.albedo_color = Color(1.0, 0.0, 0.0, 1.0)
	m.params_line_width = 5.0
	var p1 = Vector3(-10, 0, -5)
	var p2 = Vector3(-10, 0, 0)
	var p3 = Vector3(10, 0, 5)
	var curve = Curve3D.new()
	curve.add_point(p1, Vector3.ZERO, p1.direction_to(p2) * p1.distance_to(p2) * 0.8)
	curve.add_point(p3, p3.direction_to(p2) * p3.distance_to(p2) * 0.8)
	curve.tessellate()
	var points = curve.get_baked_points()
#	var im = $ImmediateGeometry
#	im.set_material_override(m)
#	im.clear()
#	im.begin(Mesh.PRIMITIVE_LINE_STRIP, null)
#	for pt in points:
#		im.add_vertex(pt)
#	im.end()
	
	var track_half_width = 2.0
	var path = Path.new()
	path.curve = curve
	add_child(path)
	print("path", path.get_path())
	var csg = CSGPolygon.new()
	csg.mode = CSGPolygon.MODE_PATH
	csg.path_rotation = CSGPolygon.PATH_ROTATION_PATH_FOLLOW
	csg.path_node = path.get_path()
	var poly = csg.polygon
	poly.set(0, Vector2(-track_half_width, 0.0))
	poly.set(1, Vector2(-track_half_width, -0.1))
	poly.set(2, Vector2( track_half_width, -0.1))
	poly.set(3, Vector2( track_half_width, 0.0))
	csg.polygon = poly
	csg.material = roadMaterial
	add_child(csg)

#func _process(delta):
#	var p1 = Vector3(-5, 0, -10)
#	var p2 = Vector3(-5, 0, 0)
#	var p3 = Vector3(5, 0, 10)
#	var curve = Curve3D.new()
#	curve.add_point(p1, Vector3.ZERO, p1.direction_to(p2) * p1.distance_to(p2) * 0.8)
#	curve.add_point(p3, p3.direction_to(p2) * p3.distance_to(p2) * 0.8)
#	curve.tessellate()
#	var points = curve.get_baked_points()
#	var im = $ImmediateGeometry
#	im.set_material_override(m)
#	im.clear()
#	im.begin(Mesh.PRIMITIVE_LINE_STRIP, null)
#	for pt in points:
#		im.add_vertex(pt)
#	im.end()


#func _process(delta):
#	var im = $ImmediateGeometry
#	#im.set_material_override(m)
#	im.clear()
#	im.begin(Mesh.PRIMITIVE_LINE_STRIP, null)
#	im.add_vertex(Vector3(0,3,-10))
#	im.add_vertex(Vector3(-10,3,-10))
#	im.add_vertex(Vector3(-10,3,0))
#	im.add_vertex(Vector3(0,3,-10))
#	im.add_vertex(Vector3(0,3,0))
#	im.add_vertex(Vector3(-10,3,0))
#	im.end()

#func _process(_delta):
#	var im = $ImmediateGeometry
#
#	# Clean up before drawing.
#	im.clear()
#
#	# Begin draw.
#	im.begin(Mesh.PRIMITIVE_TRIANGLES)
#
#	# Prepare attributes for add_vertex.
#	im.set_normal(Vector3(0, 0, 1))
#	im.set_uv(Vector2(0, 0))
#	# Call last for each vertex, adds the above attributes.
#	im.add_vertex(Vector3(-1, -1, 0))
#
#	im.set_normal(Vector3(0, 0, 1))
#	im.set_uv(Vector2(0, 1))
#	im.add_vertex(Vector3(-1, 1, 0))
#
#	im.set_normal(Vector3(0, 0, 1))
#	im.set_uv(Vector2(1, 1))
#	im.add_vertex(Vector3(1, 1, 0))
#
#	# End drawing.
#	im.end()
