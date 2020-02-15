extends MultiMeshInstance

var road_segments = [] setget set_road_segments, get_road_segments

func _ready():
	pass # Replace with function body.

func add_straight(p1, p2):
	road_segments.push_back(PoolVector3Array([p1, p2]))
	
func add_curve(p1, p2, p3):
	road_segments.push_back(PoolVector3Array([p1, p2, p3]))

func set_road_segments(value):
	var tmp_array = []
	for seg in value:
		var arr = PoolVector3Array()
		for i in range(0, seg.size(), 3):
			arr.push_back(Vector3(seg[i], seg[i+1], seg[i+2]))
		tmp_array.push_back(arr)
	road_segments = tmp_array
	print(road_segments)

func get_road_segments():
	return road_segments

func get_closest_point(pt: Vector3) -> Vector3 :
	# default to point that should be too far away
	var closest = Vector3(999999, 999999, 999999)
	if road_segments.size() > 0:
		var minDist = 9999999
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
