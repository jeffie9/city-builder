extends Node

var paths: Array
var intersections: Dictionary

func update_paths(segments):
	# clear child paths
	var path_nodes = get_tree().get_nodes_in_group("Paths")
	for i in path_nodes:
		i.queue_free()

	paths = []
	intersections = {}
	# create path for each segment
	var curve = Curve3D.new()
	for seg in segments:
		if seg.size() == 3:
			var r1 = make_rectangle(seg[0], seg[1])
			var r2 = make_rectangle(seg[1], seg[2])
			curve.clear_points()
			curve.add_point(r1[0], Vector3.ZERO, r1[0].direction_to(r1[1]) * r1[0].distance_to(r1[1]) * 0.8)
			curve.add_point(r2[1], r2[1].direction_to(r2[0]) * r2[0].distance_to(r2[1]) * 0.8)
			curve.tessellate()
			paths.push_back(curve.get_baked_points())
			add_intersection(seg[0], paths.size() - 1)
			add_intersection(seg[2], paths.size() - 1)

			curve.clear_points()
			curve.add_point(r2[2], Vector3.ZERO, r2[2].direction_to(r2[3]) * r2[2].distance_to(r2[3]) * 0.8)
			curve.add_point(r1[3], r1[3].direction_to(r1[2]) * r1[2].distance_to(r1[3]) * 0.8)
			curve.tessellate()
			paths.push_back(curve.get_baked_points())
			add_intersection(seg[0], paths.size() - 1)
			add_intersection(seg[2], paths.size() - 1)

		elif seg.size() == 2:
			var rec = make_rectangle(seg[0], seg[1])
			paths.push_back(PoolVector3Array([rec[0], rec[1]]))
			add_intersection(seg[0], paths.size() - 1)
			add_intersection(seg[1], paths.size() - 1)
			paths.push_back(PoolVector3Array([rec[2], rec[3]]))
			add_intersection(seg[0], paths.size() - 1)
			add_intersection(seg[1], paths.size() - 1)

	display_paths()

func add_intersection(pt: Vector3, segment: int):
	if !intersections.has(pt):
		intersections[pt] = PoolIntArray()
	intersections[pt].push_back(segment)

func update_intersections():
	for i in intersections.keys():
		var iPaths = intersections[i]

func make_rectangle(p1, p2, width = 0.125):
	# perpendicular vector with y at midpoint and length
	var ppv = Vector3(p2.z - p1.z, max((p1.y + p2.y) / 2, 0.01), -(p2.x - p1.x)).normalized() * width
	return PoolVector3Array([p1 + ppv, p2 + ppv, p2 - ppv, p1 - ppv])

func display_paths():
	$path_outline.clear()
	for path in paths:
		$path_outline.begin(Mesh.PRIMITIVE_LINE_STRIP, null)
		for pt in path:
			$path_outline.add_vertex(pt)
		$path_outline.end()


#public static Mesh extrudeAlongPath(Vector3[] points, float width){
#    if (points.Length < 2)
#        return null;
#    Mesh m = new Mesh();
#    List<Vector3> verts = new List<Vector3>();
#    List<Vector3> norms = new List<Vector3>();
#
#    for (int i = 0; i < points.Length; i++) {
#        if(i != points.Length-1){
#            Vector3 perpendicularDirection = new Vector3(-( points[i+1].z-points[i].z ), points[i].y, points[i+1].x -points[i].x).normalized;
#            verts.Add (points[i]+perpendicularDirection*width);
#            norms.Add (Vector3.up);
#            verts.Add (points[i]+perpendicularDirection*-width);
#            norms.Add (Vector3.up);
#        }else{
#            Vector3 perpendicularDirection = new Vector3(-( points[i].z-points[i-1].z ), points[i].y, points[i].x -points[i-1].x).normalized;
#            verts.Add (points[i]+perpendicularDirection*-width);
#            norms.Add (Vector3.up);
#            verts.Add (points[i]+perpendicularDirection*width);
#            norms.Add (Vector3.up);
#        }
#    }
#    m.vertices = verts.ToArray ();
#    m.normals = norms.ToArray ();
#
#    List<int> tris = new List<int> ();
#    //Changed i+=3 to i++
#    for(int i = 0; i < m.vertices.Length-3; i++){
#        if(i%2 == 0){
#        tris.Add(i+2);
#        tris.Add(i+1);
#        tris.Add(i);
#        }else{
#            tris.Add(i);
#            tris.Add(i+1);
#            tris.Add(i+2);
#        }
#    }
#    m.triangles = tris.ToArray ();
#
#    m.name = "pathMesh";
#    m.RecalculateNormals ();
#    m.RecalculateBounds ();
#    m.Optimize ();
#    return m;
#}
