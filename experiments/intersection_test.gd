extends Node2D

var nodes = {}
var edges = []
var paths = []

var astar = AStar2D.new()
var start_point: Vector2
var end_point: Vector2

func _ready():
	for edge in make_test_data():
		var arr = PoolVector2Array()
		for i in range(0, edge.points.size(), 2):
			arr.push_back(Vector2(edge.points[i], edge.points[i+1]))
		edges.push_back({ "points": arr, "type": edge.type })
	#make_astar_from_edges()
	for i in edges.size():
		var edge = edges[i]
		add_node_edge(edge.points[0], i)
		add_node_edge(edge.points[edge.points.size() - 1], i)
	for ip in nodes.keys():
		var node = nodes[ip]
		make_intersection(ip, node)
		var polygon = Polygon2D.new()
		polygon.polygon = node.polygon
		polygon.color = Color.deeppink
		add_child(polygon)
		
#		print(ip, node.poes.size())
		var node_paths = []
		node_paths.resize(node.poes.size())
		# TODO figure out how to switch between left and right hand drive
		for i in node.poes.size():
			var node_path = []
			for j in floor(node.poes[i].size() / 2):
				for k in node.poes.size():
					if i != k:
						for m in range(ceil(node.poes[k].size() / 2) + 1, node.poes[k].size()):
#							print("node poes", node.poes[i][j], node.poes[k][m])
							var path_points = make_path(node.poes[i][j][0], node.poes[i][j][1], node.poes[k][m][0], node.poes[k][m][1])
							node_path.push_back(path_points)
							add_path(path_points)
							var line = Line2D.new()
							line.width = 2
							line.points = path_points
#							add_child(line)
			node_paths[i] = node_path
		node.paths = node_paths

	for i in edges.size():
		var edge = edges[i]
		var narr = [ nodes[edge.points[0]], nodes[edge.points[edge.points.size() - 1]] ]
		# many nodes are intersections of two segments or dead-ends
		var parr = [narr[0].polygon[0], narr[0].polygon[1], narr[1].polygon[0], narr[1].polygon[1]]
		for j in 2:
			if narr[j].polygon.size() > 2:
				#print(i, narr[j].sorted_segments, Array(narr[j].sorted_segments).find(i))
				var k = Array(narr[j].sorted_segments).find(i)
				var k1 = k - 1 if k > 0 else narr[j].sorted_segments.size() - 1
				parr[j * 2] = narr[j].polygon[k]
				parr[j * 2 + 1] = narr[j].polygon[k1]
#		print(i, parr)
		var sorted = sort_verticies_ccw(parr)
		var polygon = Polygon2D.new()
		polygon.polygon = [parr[sorted[0]], parr[sorted[1]], parr[sorted[2]], parr[sorted[3]]]
		polygon.color = Color.aliceblue
		add_child(polygon)
#		var line = Line2D.new()
#		line.points = [parr[sorted[0]], parr[sorted[1]], parr[sorted[2]], parr[sorted[3]]]
#		add_child(line)
		var pth0 = narr[0].poes[Array(narr[0].sorted_segments).find(i)]
		var pth1 = narr[1].poes[Array(narr[1].sorted_segments).find(i)]
#		print(pth0[0], pth1[2])
		# TODO add multi-lane logic
		var line = Line2D.new()
		line.width = 2
		line.points = [pth0[0][0], pth1[2][0]]
#		add_child(line)
		add_path([pth0[0][0], pth1[2][0]])
		line = Line2D.new()
		line.width = 2
		line.points = [pth0[2][0], pth1[0][0]]
#		add_child(line)
		add_path([pth0[2][0], pth1[0][0]])
		edge.paths = [[pth0[0][0], pth1[2][0]], [pth0[2][0], pth1[0][0]]]

	# dead-ends
	for ip in nodes.keys():
		var node = nodes[ip]
		if node.edges.size() == 1:
#			print(node.poes)
			var ci = floor(node.poes[0].size() / 2)
#			print(node.poes[0].size(), ci)
			var node_path = []
			for i in ci:
#				print(i, " ", ci, " ", ci - (i + 1), " ", ci + (i + 1))
#				print(node.poes[0][ci - (i + 1)], node.poes[0][ci + (i + 1)])
				var s = node.poes[0][ci - (i + 1)]
				var e = node.poes[0][ci + (i + 1)]
				var d = s[0].distance_to(e[0])
				var curve = Curve2D.new()
				curve.bake_interval = 1.0
				curve.add_point(s[0], Vector2.ZERO, (s[0] - s[1]).normalized() * d)
				curve.add_point(e[0], (e[0] - e[1]).normalized() * d)
				var line = Line2D.new()
				line.width = 2
				line.points = curve.get_baked_points()
#				add_child(line)
				node_path.push_back(curve.get_baked_points())
				add_path(curve.get_baked_points())
			node.paths = [node_path]

	make_astar_from_paths()
	for path in paths:
#		print(path)
		var line = Line2D.new()
		line.width = 2
		line.points = path
		add_child(line)

	var curve = Curve2D.new()
#	curve.bake_interval = 1.0
	for p in paths[0]:
		curve.add_point(p)
	$Path2D.curve = curve

func _process(delta):
	$Path2D/PathFollow2D.offset += delta * 50

func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		start_point = event.position
		update()
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT and event.pressed:
		end_point = event.position
		find_path()
		update()

func _draw():
	if start_point != null:
		draw_circle(start_point, 10, Color.green)
	if end_point != null:
		draw_circle(end_point, 10, Color.red)

func add_node_edge(node: Vector2, edge: int):
	var node_edges
	if nodes.has(node):
		node_edges = nodes[node].edges
	else:
		nodes[node] = {}
		node_edges = PoolIntArray()
	node_edges.push_back(edge)
	nodes[node].edges = node_edges

# side effect: assigns data to node
func make_intersection(ip, node):
	if node.edges.size() <= 0:
		return

	if node.edges.size() == 1:
		var op = edges[node.edges[0]].points[0] if edges[node.edges[0]].points[0] != ip else edges[node.edges[0]].points[edges[node.edges[0]].points.size() - 1]
		var rec = make_rectangle(ip, op, 25.0)
		node.polygon = PoolVector2Array([rec[0], rec[3]])
		rec = make_rectangle(ip, op, 12.5)
		node.poes = [[PoolVector2Array([rec[0], rec[1]]), PoolVector2Array([ip, op]), PoolVector2Array([rec[3], rec[2]])]]
		node.sorted_segments = PoolIntArray([node.edges[0]])
		return

	# make first segment the base
	var base_normal = ((edges[node.edges[0]].points[0] if edges[node.edges[0]].points[0] != ip else edges[node.edges[0]].points[edges[node.edges[0]].points.size() - 1]) - ip).normalized()
	var segments_by_angle = {}
	for i in range(1, node.edges.size()):
		var op = edges[node.edges[i]].points[0] if edges[node.edges[i]].points[0] != ip else edges[node.edges[i]].points[edges[node.edges[0]].points.size() - 1]
		var ang = base_normal.angle_to((op - ip).normalized())
		if ang < 0:
			ang += 2 * PI
		segments_by_angle[ang] = node.edges[i]
	var sorted_keys = segments_by_angle.keys()
	sorted_keys.sort()
	var sorted_segments = PoolIntArray()
	sorted_segments.push_back(node.edges[0])
	for key in sorted_keys:
		sorted_segments.push_back(segments_by_angle[key])

	var intersection_polygon_points = PoolVector2Array()
	for i in sorted_segments.size():
		var seg1 = edges[sorted_segments[i]].points
		var seg2 = edges[sorted_segments[(i + 1) % sorted_segments.size()]].points
		var op = seg1[0] if seg1[1] == ip else seg1[1]
		var r1 = make_rectangle(ip, op)
		op = seg2[0] if seg2[1] == ip else seg2[1]
		var r2 = make_rectangle(ip, op)
		var inter = Geometry.line_intersects_line_2d(r1[2], r1[3] - r1[2], r2[1], r2[0] - r2[1])
		intersection_polygon_points.push_back(inter)

	var node_poes = []
	for i in sorted_segments.size():
		var seg1 = edges[sorted_segments[i]].points
		var seg2 = edges[sorted_segments[(i + 1) % sorted_segments.size()]].points
		var op = seg1[0] if seg1[1] == ip else seg1[1]
		# path point of entry through intersection
		var path_poe = []
		var i1 = i - 1 if i > 0 else sorted_segments.size() - 1
		# TODO handle wider road types and sidewalk paths
		# in paths
		var rec = make_rectangle(ip, op, 12.5)
		var inter = Geometry.line_intersects_line_2d(rec[1], rec[0] - rec[1],
				intersection_polygon_points[i1], intersection_polygon_points[i] - intersection_polygon_points[i1])
		path_poe.push_back(PoolVector2Array([inter, rec[1]]))
		# centerline
		inter = Geometry.line_intersects_line_2d(op, ip - op,
				intersection_polygon_points[i1], intersection_polygon_points[i] - intersection_polygon_points[i1])
		path_poe.push_back(PoolVector2Array([inter, op]))
		# out paths
		inter = Geometry.line_intersects_line_2d(rec[2], rec[3] - rec[2],
				intersection_polygon_points[i1], intersection_polygon_points[i] - intersection_polygon_points[i1])
		path_poe.push_back(PoolVector2Array([inter, rec[2]]))
		node_poes.push_back(path_poe)

	node.polygon = intersection_polygon_points
	node.sorted_segments = sorted_segments
	node.poes = node_poes

func sort_verticies_ccw(verts, ip = null):
	if ip == null:
		# take the average of the verticies
		ip = Vector2(0, 0)
		for v in verts:
			ip += v
		ip /= verts.size()

	var segments_by_angle = {}
	for i in verts.size():
		var ang = ip.angle_to((verts[i] - ip).normalized())
		if ang < 0:
			ang += 2 * PI
		segments_by_angle[ang] = i
	var sorted_keys = segments_by_angle.keys()
	sorted_keys.sort()
	var sorted_verticies = PoolIntArray()
	for key in sorted_keys:
		sorted_verticies.push_back(segments_by_angle[key])
	return sorted_verticies

# adds path to the end of an existing path else starts a new path
func add_path(path):
	# no attempt at optimization yet
	var pn = path[path.size() - 1]
	for p in paths:
#		if path[0] == p[0] or pn == p[0] or path[0] == p[p.size() - 1] or pn == p[p.size() - 1]:
#			print("found some equality")
		if path[0] == p[0]:
#			print("path[0] to head")
			for i in range(1, path.size()):
				p.push_front(path[i])
			return
		elif pn == p[0]:
#			print("path[n] to head")
			for i in range(path.size() - 1, -1, -1):
				p.push_front(path[i])
			return
		elif path[0] == p[p.size() - 1]:
#			print("path[0] to tail")
			for i in range(1, path.size()):
				p.push_back(path[i])
			return
		elif pn == p[p.size() - 1]:
#			print("path[n] to tail")
			for i in range(path.size() - 1, -1, -1):
				p.push_back(path[i])
			return
	# not found, add new path
	paths.push_back(Array(path))

func make_astar_from_edges():
	var point_array = []
	for edge in edges:
		var p0_index = point_array.find(edge.points[0])
		if p0_index == -1:
			p0_index = point_array.size()
			point_array.append(edge.points[0])
			astar.add_point(p0_index, edge.points[0])
		var p1_index = point_array.find(edge.points[edge.points.size() - 1])
		if p1_index == -1:
			p1_index = point_array.size()
			point_array.append(edge.points[edge.points.size() - 1])
			astar.add_point(p1_index, edge.points[edge.points.size() - 1])
		astar.connect_points(p0_index, p1_index)

func make_astar_from_paths():
	var point_array = []
	for path in paths:
		for i in path.size() - 1:
			var p0_index = point_array.find(path[i])
			if p0_index == -1:
				p0_index = point_array.size()
				point_array.append(path[i])
				astar.add_point(p0_index, path[i])
			var p1_index = point_array.find(path[i + 1])
			if p1_index == -1:
				p1_index = point_array.size()
				point_array.append(path[i + 1])
				astar.add_point(p1_index, path[i + 1])
			astar.connect_points(p0_index, p1_index)

func make_intersection_1(intersection_point, segments) -> Dictionary :
	# make first segment the base
	var base_normal = ((segments[0][0] if segments[0][1] == intersection_point else segments[0][1]) - intersection_point).normalized()
	var segments_by_angle = {}
	for i in range(1, segments.size()):
		var op = segments[i][0] if segments[i][1] == intersection_point else segments[i][1]
		var ang = base_normal.angle_to((op - intersection_point).normalized())
		if ang < 0:
			ang += 2 * PI
		segments_by_angle[ang] = i
	var sorted_keys = segments_by_angle.keys()
	sorted_keys.sort()
	var sorted_segments = PoolIntArray()
	sorted_segments.push_back(0)
	for key in sorted_keys:
		sorted_segments.push_back(segments_by_angle[key])
	sorted_segments.push_back(0)

	var intersection_polygon_points = PoolVector2Array()
	for i in sorted_segments.size() - 1:
		var seg1 = segments[sorted_segments[i]]
		var seg2 = segments[sorted_segments[i + 1]]
		var op = seg1[0] if seg1[1] == intersection_point else seg1[1]
		var r1 = make_rectangle(intersection_point, op)
		op = seg2[0] if seg2[1] == intersection_point else seg2[1]
		var r2 = make_rectangle(intersection_point, op)
		var inter = Geometry.line_intersects_line_2d(r1[2], r1[3] - r1[2], r2[1], r2[0] - r2[1])
		intersection_polygon_points.push_back(inter)
	sorted_segments.remove(sorted_segments.size() - 1)
	return {
		"polygon": intersection_polygon_points,
		"sorted_segments": sorted_segments
		}

func make_path(s0, s1, e0, e1):
	var dir = rad2deg(abs((s0 - s1).angle_to(e0 - e1)))
	if dir > 1 and dir < 179:
		var inter = Geometry.line_intersects_line_2d(s1, s0 - s1, e1, e0 - e1)
		var curve = Curve2D.new()
		curve.bake_interval = 1.0
		curve.add_point(s0, Vector2.ZERO, inter - s0)
		curve.add_point(e0, Vector2.ZERO, inter - e0)
		return curve.get_baked_points()
	else:
		return PoolVector2Array([s0, e0])

func find_path():
	if start_point != null and end_point != null:
		var start_id = astar.get_closest_point(start_point)
		var end_id = astar.get_closest_point(end_point)
		print(start_id, end_id)
#		var line = Line2D.new()
#		line.width = 2
#		line.points = astar.get_point_path(start_id, end_id)
#		add_child(line)
	
		var curve = Curve2D.new()
		curve.bake_interval = 1.0
		for p in astar.get_point_path(start_id, end_id):
			curve.add_point(p)
		$Path2D.curve = curve

func find_closest_edge(point: Vector2):
	var min_dist = INF
	var min_index = -1
	for i in edges.size():
		var edge = edges[i]
		var cp = Geometry.get_closest_point_to_segment_2d(point, edge.points[0], edge.points[1])
		var dist = point.distance_squared_to(cp)
		if dist < min_dist:
			min_dist = dist
			min_index = i
	return min_index


func make_rectangle(p1, p2, width = 25):
	var ppv = Vector2(p2.y - p1.y, -(p2.x - p1.x)).normalized() * width
	return PoolVector2Array([p1 + ppv, p2 + ppv, p2 - ppv, p1 - ppv])

func first_way():
	var road_segments = []
	var intersection_point = Vector2(400, 300)
	var pt = Vector2(intersection_point.x - 200, intersection_point.y - 100)
	road_segments.push_back(PoolVector2Array([pt, intersection_point]))
	pt = Vector2(intersection_point.x + 100, intersection_point.y - 200)
	road_segments.push_back(PoolVector2Array([pt, intersection_point]))
	pt = Vector2(intersection_point.x + 200, intersection_point.y + 100)
	road_segments.push_back(PoolVector2Array([pt, intersection_point]))
	pt = Vector2(intersection_point.x - 100, intersection_point.y + 200)
	road_segments.push_back(PoolVector2Array([pt, intersection_point]))

	var normals = PoolVector2Array()

	for seg in road_segments:
		var rec = make_rectangle(seg[0], seg[1])
		var poly = Polygon2D.new()
		poly.polygon = rec
		poly.color = Color.white
		add_child(poly)
		var line = Line2D.new()
		line.points = PoolVector2Array([seg[0], seg[1]])
		line.width = 2
		add_child(line)
#		line = Line2D.new()
#		line.points = rec
#		line.width = 1
#		add_child(line)

		# only works because intersection_point added second
		normals.push_back((seg[0] - seg[1]).normalized())


	
	# orient the intersection (usually not in any order)
	# caution: assumes 4-way intersection
	var orientation = PoolIntArray()
	var max_angle = 0
	var max_angle_index = NAN
	for i in range(1, normals.size()):
		var ang = abs(normals[0].angle_to(normals[i]))
		if ang > max_angle:
			max_angle = ang
			max_angle_index = i
	var pos_angle_index = NAN
	var neg_angle_index = NAN
	for i in range(1, normals.size()):
		if i != max_angle_index:
			var ang = normals[0].angle_to(normals[i])
			if ang > 0:
				pos_angle_index = i
			else:
				neg_angle_index = i
	orientation.push_back(0)
	orientation.push_back(pos_angle_index)
	orientation.push_back(max_angle_index)
	orientation.push_back(neg_angle_index)
	orientation.push_back(0)

	# find the four corners
	var intersection_polygon_points = PoolVector2Array()
	for i in range(0, 4):
		var seg1 = road_segments[orientation[i]]
		var seg2 = road_segments[orientation[i+1]]
		var op = seg1[0] if seg1[1] == intersection_point else seg1[1]
		var r1 = make_rectangle(intersection_point, op)
		op = seg2[0] if seg2[1] == intersection_point else seg2[1]
		var r2 = make_rectangle(intersection_point, op)
		var inter = Geometry.line_intersects_line_2d(r1[2], r1[3] - r1[2], r2[1], r2[0] - r2[1])
		intersection_polygon_points.push_back(inter)
		
	var intersection_polygon = Polygon2D.new()
	intersection_polygon.polygon = intersection_polygon_points
	intersection_polygon.color = Color.deeppink
	add_child(intersection_polygon)

func second_way():
	var intersection_point = Vector2(400, 300)
	var road_segments = []
	var pt = Vector2(intersection_point.x - 200, intersection_point.y - 100)
	road_segments.push_back(PoolVector2Array([pt, intersection_point]))
	pt = Vector2(intersection_point.x + 100, intersection_point.y - 200)
	road_segments.push_back(PoolVector2Array([pt, intersection_point]))
	pt = Vector2(intersection_point.x + 200, intersection_point.y + 100)
	road_segments.push_back(PoolVector2Array([pt, intersection_point]))
	pt = Vector2(intersection_point.x - 100, intersection_point.y + 200)
	road_segments.push_back(PoolVector2Array([pt, intersection_point]))
	print(road_segments)
	
	var intersection = make_intersection_1(intersection_point, road_segments)
	var intersection_polygon_points = intersection["polygon"]
	var sorted_segments = intersection["sorted_segments"]
	print(intersection_polygon_points)
	var intersection_polygon = Polygon2D.new()
	intersection_polygon.polygon = intersection_polygon_points
	intersection_polygon.color = Color.deeppink
	add_child(intersection_polygon)
	var path_poe = []

	for i in road_segments.size():
		var seg = road_segments[sorted_segments[i]]
		var op = seg[0] if seg[1] == intersection_point else seg[1]
		var rec = make_rectangle(intersection_point, op)

		var i1 = i - 1 if i > 0 else road_segments.size() - 1
		# clip the intersection polygon
		rec[0] = intersection_polygon_points[i1]
		rec[3] = intersection_polygon_points[i]
		
		var poly = Polygon2D.new()
		poly.polygon = rec
		poly.color = Color.white
		add_child(poly)
		var inter = Geometry.line_intersects_line_2d(
				intersection_point, op - intersection_point,
				intersection_polygon_points[i1], intersection_polygon_points[i] - intersection_polygon_points[i1])
		var line = Line2D.new()
		line.points = PoolVector2Array([inter, op])
		line.width = 2
		add_child(line)
		
		# path point of entry through intersection
		rec = make_rectangle(intersection_point, op, 12.5)
		inter = Geometry.line_intersects_line_2d(rec[1], rec[0] - rec[1],
				intersection_polygon_points[i1], intersection_polygon_points[i] - intersection_polygon_points[i1])
		path_poe.push_back(PoolVector2Array([inter, rec[1]]))
		inter = Geometry.line_intersects_line_2d(rec[2], rec[3] - rec[2],
				intersection_polygon_points[i1], intersection_polygon_points[i] - intersection_polygon_points[i1])
		path_poe.push_back(PoolVector2Array([inter, rec[2]]))
	
	var curve = Curve2D.new()
	curve.bake_interval = 1.0
	for i in path_poe.size():
		# careful: this works because only two-lane roads
		var start_pts = path_poe[i]
		var start = (i + 1) % 2
		for j in range(start, path_poe.size(), 2):
			var end_pts = path_poe[j]
			var dir = rad2deg(abs((start_pts[0] - start_pts[1]).angle_to(end_pts[0] - end_pts[1])))
			var line = Line2D.new()
			line.width = 2
			if dir > 1 and dir < 179:
				curve.clear_points()
				var inter = Geometry.line_intersects_line_2d(start_pts[1], start_pts[0] - start_pts[1], end_pts[1], end_pts[0] - end_pts[1])
				curve.add_point(start_pts[0], Vector2.ZERO, inter - start_pts[0])
				curve.add_point(end_pts[0], Vector2.ZERO, inter - end_pts[0])
				line.points = curve.get_baked_points()
			else:
				line.points = PoolVector2Array([start_pts[0], end_pts[0]])

			add_child(line)


func make_test_data() -> Array :
	return [
		{ "type": 0, "points": [200,200,400,300] },
		{ "type": 0, "points": [500,100,400,300] },
		{ "type": 0, "points": [600,400,400,300] },
		{ "type": 0, "points": [300,500,400,300] },
		{ "type": 0, "points": [450,425,300,500] },
	]
