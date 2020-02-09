extends Spatial

var anchor_point : Vector3
var inter_point : Vector3
var m = SpatialMaterial.new()
# TODO better state definitions
var state = 0
var mode = 0   # 0 = straight, 1 = curve
var cursor_curve = Curve3D.new()
var half_road_width = 0.25

onready var roadMaterial = preload("res://assets/road_two_lane.material")
var road002 = preload("res://assets/road002.material")

func _ready():
	m.flags_unshaded = true
	m.flags_use_point_size = true
	m.albedo_color = Color(1.0, 1.0, 1.0, 1.0)

	var material = SpatialMaterial.new()
	material.albedo_color = Color(1,0,0,1)
	var surfTool = SurfaceTool.new()
	surfTool.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	#surfTool.add_color(Color(1, 0, 0, 1))
	surfTool.set_material(roadMaterial)
	surfTool.add_normal(Vector3.UP)
	surfTool.add_uv(Vector2.ZERO)
	# first triangle is drawn counter-clockwise
	surfTool.add_vertex(Vector3(-5,3,-3))
	surfTool.add_vertex(Vector3(-4,3,-3))
	surfTool.add_vertex(Vector3(-5,3,1))
	surfTool.add_vertex(Vector3(-4,3,1))
	var meshInstance = MeshInstance.new()
	meshInstance.mesh = surfTool.commit()
	add_child(meshInstance)



func _on_StaticBody_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseMotion:
		if state == 0:
			var im = get_node("cursor")
			im.set_material_override(m)
			im.clear()
			# draw a circle
			var numpoints = 64
			im.begin(Mesh.PRIMITIVE_LINE_LOOP, null)
			for i in numpoints:
				var phi = i * PI * 2.0 / numpoints
				im.add_vertex(click_position + Vector3(sin(phi), 0, cos(phi)) * 0.25)
			im.end()

	if mode == 0:
		straight_input_event(event, click_position)
	elif mode == 1:
		curve_input_event(event, click_position)


func straight_input_event(event, click_position):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		if state == 0:
			state = 1
			anchor_point = click_position

		elif state == 1:
			state = 0
			var im = get_node("cursor")
			im.clear()
#			var rec = make_rectangle(anchor_point, click_position)
#			print(rec)
#			var surfTool = SurfaceTool.new()
#			surfTool.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
#			surfTool.set_material(road002)
#			surfTool.add_normal(Vector3.UP)
#			surfTool.add_uv(Vector2.ZERO)
#			# this one needs clock-wise first triangle - maybe I create rec upside-down
#			surfTool.add_vertex(rec[0])
#			surfTool.add_vertex(rec[1])
#			surfTool.add_vertex(rec[3])
#			surfTool.add_vertex(rec[2])
#			var meshInstance = MeshInstance.new()
#			meshInstance.mesh = surfTool.commit()
#			add_child(meshInstance)
			var csg = make_csg_polygon_from_two_points(anchor_point, click_position)
			csg.material = roadMaterial
			add_child(csg)
			anchor_point = click_position


#			var length = anchor_point.distance_to(click_position)
#			var surfTool = SurfaceTool.new()
#			var material = SpatialMaterial.new()
#			material.albedo_color = Color(1,0,0,1)
#			surfTool.set_material(material)
#			surfTool.begin(Mesh.PRIMITIVE_TRIANGLES)
#			surfTool.add_normal(Vector3.UP)
#			surfTool.add_color(Color(1, 0, 0))
#			surfTool.add_uv(Vector2(0, 0))
#			surfTool.add_vertex(Vector3(-0.25, 0, -length))
#			surfTool.add_vertex(Vector3(0.25, 0, -length))
#			surfTool.add_vertex(Vector3(0.25, 0, 0))
#			surfTool.add_vertex(Vector3(-0.25, 0, -length))
#			surfTool.add_vertex(Vector3(0.25, 0, 0))
#			surfTool.add_vertex(Vector3(-0.25, 0, 0))
#			var meshInstance = MeshInstance.new()
#			meshInstance.mesh = surfTool.commit()
#			meshInstance.translation = anchor_point
#			var dir = anchor_point.direction_to(click_position).normalized()
#			meshInstance.rotation.y = -Vector2.UP.angle_to(Vector2(dir.x, dir.z))
#			add_child(meshInstance)

	if event is InputEventMouseMotion:
		if state == 1:
			var rec = make_rectangle(anchor_point, click_position)
			var im = get_node("cursor")
			im.clear()
			im.begin(Mesh.PRIMITIVE_LINE_LOOP, null)
			im.add_vertex(rec[0])
			im.add_vertex(rec[1])
			im.add_vertex(rec[2])
			im.add_vertex(rec[3])
			im.end()


func curve_input_event(event, click_position):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		if state == 0:
			state = 1
			anchor_point = click_position

		elif state == 1:
			state = 2
			inter_point = click_position

		elif state == 2:
			state = 0
			var im = get_node("cursor")
			im.clear()
			var csg = make_csg_polygon_from_points(anchor_point, inter_point, click_position)
			csg.material = roadMaterial
			add_child(csg)


	if event is InputEventMouseMotion:
		if state == 1:
			var rect = make_rectangle(anchor_point, click_position)
			var im = get_node("cursor")
			im.clear()
			im.begin(Mesh.PRIMITIVE_LINE_LOOP, null)
			for pt in rect:
				im.add_vertex(pt)
			im.end()
		elif state == 2:
			# could cache rectangle r1 and replace [1,2] with control points
			var r1 = make_rectangle(anchor_point, inter_point)
			var r2 = make_rectangle(inter_point, click_position)

			# debugging display
#			var im = get_node("debug_cursor")
#			im.clear()
#			im.begin(Mesh.PRIMITIVE_LINE_LOOP, null)
#			for pt in r1:
#				im.add_vertex(pt)
#			im.end()
#			im.begin(Mesh.PRIMITIVE_LINE_LOOP, null)
#			for pt in r2:
#				im.add_vertex(pt)
#			im.end()
#			im.begin(Mesh.PRIMITIVE_POINTS, null)
#			im.add_vertex(anchor_point)
#			im.add_vertex(inter_point)
#			im.add_vertex(click_position)
#			im.end()
			# end debugging

			# seem to get sharper corners with a composite curve
			var im = get_node("cursor")
			im.clear()
			cursor_curve.clear_points()
			cursor_curve.add_point(r1[0], Vector3.ZERO, r1[0].direction_to(r1[1]) * r1[0].distance_to(r1[1]))
			cursor_curve.add_point(r2[1], r2[1].direction_to(r2[0]) * r2[0].distance_to(r2[1]))
			im.begin(Mesh.PRIMITIVE_LINE_STRIP, null)
			for pt in cursor_curve.get_baked_points():
				im.add_vertex(pt)
			im.add_vertex(r2[1])
			im.end()
			cursor_curve.clear_points()
			cursor_curve.add_point(r2[2], Vector3.ZERO, r2[2].direction_to(r2[3]) * r2[2].distance_to(r2[3]))
			cursor_curve.add_point(r1[3], r1[3].direction_to(r1[2]) * r1[2].distance_to(r1[3]))
			im.begin(Mesh.PRIMITIVE_LINE_STRIP, null)
			for pt in cursor_curve.get_baked_points():
				im.add_vertex(pt)
			im.add_vertex(r1[0])  # this one doesn't display ):
			im.end()

func make_rectangle(p1, p2, width = 0.25):
	# perpendicular vector with y at midpoint and length
	var ppv = Vector3(p2.z - p1.z, max((p1.y + p2.y) / 2, 0.01), -(p2.x - p1.x)).normalized() * width
	return PoolVector3Array([p1 + ppv, p2 + ppv, p2 - ppv, p1 - ppv])

func make_mesh_from_points(p1, p2, p3):
	var r1 = make_rectangle(p1, p2)
	var r2 = make_rectangle(p2, p3)
	cursor_curve.clear_points()
	cursor_curve.add_point(r1[0], Vector3.ZERO, r1[0].direction_to(r1[1]) * r1[0].distance_to(r1[1]) * 0.8)
	cursor_curve.add_point(r2[1], r2[1].direction_to(r2[0]) * r2[0].distance_to(r2[1]) * 0.8)
	cursor_curve.tessellate()
	var c1 = cursor_curve.get_baked_points()
	cursor_curve.clear_points()
	cursor_curve.add_point(r2[2], Vector3.ZERO, r2[2].direction_to(r2[3]) * r2[2].distance_to(r2[3]) * 0.8)
	cursor_curve.add_point(r1[3], r1[3].direction_to(r1[2]) * r1[2].distance_to(r1[3]) * 0.8)
	cursor_curve.tessellate()
	var c2 = cursor_curve.get_baked_points()
	c2.invert()
	# array sizes could be different
	# sloppy - put all extra triangles at end
	var surfTool = SurfaceTool.new()
	var material = SpatialMaterial.new()
	material.albedo_color = Color(1,0,0,1)
	surfTool.set_material(material)
	surfTool.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	surfTool.add_normal(Vector3.UP)
	surfTool.add_color(Color(1, 0, 0))
	surfTool.add_uv(Vector2(0, 0))
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

func make_csg_polygon_from_points(p1, p2, p3):
	var curve = Curve3D.new()
	curve.add_point(p1, Vector3.ZERO, p1.direction_to(p2) * p1.distance_to(p2) * 0.8)
	curve.add_point(p3, p3.direction_to(p2) * p3.distance_to(p2) * 0.8)
	return make_csg_polygon_from_curve(curve)

func make_csg_polygon_from_two_points(p1, p2):
	var curve = Curve3D.new()
	curve.add_point(p1)
	curve.add_point(p2)
	return make_csg_polygon_from_curve(curve)

func make_csg_polygon_from_curve(curve):
	curve.tessellate()
	var points = curve.get_baked_points()
#	var im = $debug_cursor
#	im.clear()
#	im.begin(Mesh.PRIMITIVE_LINE_STRIP, null)
#	for pt in points:
#		im.add_vertex(pt)
#	im.end()
	
	var track_half_width = 0.25
	var path = Path.new()
	path.curve = curve
	add_child(path)
	var csg = CSGPolygon.new()
	csg.mode = CSGPolygon.MODE_PATH
	csg.path_rotation = CSGPolygon.PATH_ROTATION_PATH_FOLLOW
	csg.path_node = path.get_path()
	csg.invert_faces = true
	var poly = csg.polygon
	poly.set(0, Vector2(-track_half_width, 0.0))
	poly.set(1, Vector2(-track_half_width, -0.1))
	poly.set(2, Vector2( track_half_width, -0.1))
	poly.set(3, Vector2( track_half_width, 0.0))
	csg.polygon = poly
	return csg
