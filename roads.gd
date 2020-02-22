extends MultiMeshInstance

var road_segments = [] setget set_road_segments, get_road_segments
var road_intersections: Dictionary setget , get_road_intersections

func add_straight(p1, p2):
	road_segments.push_back(PoolVector3Array([p1, p2]))
	
func add_curve(p1, p2, p3):
	road_segments.push_back(PoolVector3Array([p1, p2, p3]))

func set_road_segments(value):
	road_segments = []
	for seg in value:
		var arr = PoolVector3Array()
		for i in range(0, seg.size(), 3):
			arr.push_back(Vector3(seg[i], seg[i+1], seg[i+2]))
		if arr.size() == 3:
			add_curve(arr[0], arr[1], arr[2])
		elif arr.size() == 2:
			add_straight(arr[0], arr[1])

func get_road_segments():
	return road_segments

func get_road_intersections():
	return road_intersections

func calc_intersections():
	road_intersections = {}
	for i in road_segments.size() - 1:
		var seg = road_segments[i]
		add_intersection(seg[0], i)
		add_intersection(seg[seg.size() - 1], i)
	for pt in road_intersections.keys():
		var inter = road_intersections[pt]
		

func add_intersection(pt: Vector3, i: int):
	if !road_intersections.has(pt):
		road_intersections[pt] = { "segments" : PoolIntArray() }
	road_intersections[pt]["segments"].push_back(i)

func get_closest_point(pt: Vector3) -> Vector3 :
	# default to point that is too far away
	var closest = Vector3.INF
	if road_segments.size() > 0:
		var minDist = INF
		for seg in road_segments:
			for sp in seg:
				var d = pt.distance_to(sp)
				if d < minDist:
					minDist = d
					closest = sp
	return closest

func save():
	# convert to array of array of floats
	var segments = []
	for seg in road_segments:
		var tmp_array = []
		for pt in seg:
			tmp_array.push_back(pt.x)
			tmp_array.push_back(pt.y)
			tmp_array.push_back(pt.z)
		segments.push_back(tmp_array)
	var save_dict = {
		"path" : get_path(),
		"road_segments" : segments
	}
	return save_dict
