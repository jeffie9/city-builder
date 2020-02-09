extends Node2D

var p1 = Vector2(200, 200)
var p2 = Vector2(250, 100)
var p3 = Vector2(350, 50)
var r1 = make_rectangle(p1, p2)
var r2 = make_rectangle(p2, p3)
var curve = Curve2D.new()

func _draw():
	# the simple line
	curve.clear_points()
	curve.add_point(p1)
	curve.add_point(p2)
	curve.add_point(p3)
	draw_polyline(curve.get_baked_points(), Color.red, 2.0)

	# the rectangles
	curve.clear_points()
	curve.add_point(r1[0])
	curve.add_point(r1[1])
	curve.add_point(r2[0])
	curve.add_point(r2[1])
	curve.add_point(r2[2])
	curve.add_point(r2[3])
	curve.add_point(r1[2])
	curve.add_point(r1[3])
	draw_polyline(curve.get_baked_points(), Color.white, 1.0)

	# curve with control points
	curve.clear_points()
	curve.add_point(r1[0], Vector2(0, 0), r1[0].direction_to(r1[1]) * r1[0].distance_to(r1[1]) * 0.8)
	curve.add_point(r2[1], r2[1].direction_to(r2[0]) * r2[0].distance_to(r2[1]) * 0.8)
	curve.add_point(r2[2], Vector2(0, 0), r2[2].direction_to(r2[3]) * r2[2].distance_to(r2[3]) * 0.8)
	curve.add_point(r1[3], r1[3].direction_to(r1[2]) * r1[2].distance_to(r1[3]) * 0.8)
	curve.add_point(r1[0])
	draw_polyline(curve.get_baked_points(), Color.blueviolet, 1.5)

	# finally deciphered control points by saving a Curve2D
	# PoolVector2Array([ 0.698339, 67.3897, 8.72923, -33.5203, 100.927, 157.738, -27.5844, 15.0143, 0, 0, 156.794, 100.125, 0, 0.34917, -31.4252, 17.4585, 169.015, 114.441, 11.1734, -28.9811, 0.349169, -0.34917, 120.48, 166.816, 0, 0, 0, 0, 100.927, 157.738 ])
#	curve.clear_points()
#	curve.add_point(Vector2(100.927, 157.738), Vector2(0.698339, 67.3897), Vector2(8.72923, -33.5203) )
#	curve.add_point(Vector2(156.794, 100.125), Vector2(-27.5844, 15.0143), Vector2(0, 0) )
#	curve.add_point(Vector2(169.015, 114.441), Vector2(0, 0.34917), Vector2(-31.4252, 17.4585) )
#	curve.add_point(Vector2(120.48, 166.816), Vector2(11.1734, -28.9811), Vector2(0.349169, -0.34917) )
#	curve.add_point(Vector2(100.927, 157.738), Vector2(0, 0), Vector2(0, 0) )
#	draw_polyline(curve.get_baked_points(), Color.chocolate, 1.0)

	# create a triangle strip (to the side)
	var xoffset = Vector2(200, 0)
	curve.clear_points()
	curve.add_point(r1[0] + xoffset, Vector2(0, 0), r1[0].direction_to(r1[1]) * r1[0].distance_to(r1[1]) * 0.8)
	curve.add_point(r2[1] + xoffset, r2[1].direction_to(r2[0]) * r2[0].distance_to(r2[1]) * 0.8)
	curve.tessellate()
	var c1 = curve.get_baked_points()
	curve.clear_points()
	curve.add_point(r2[2] + xoffset, Vector2(0, 0), r2[2].direction_to(r2[3]) * r2[2].distance_to(r2[3]) * 0.8)
	curve.add_point(r1[3] + xoffset, r1[3].direction_to(r1[2]) * r1[2].distance_to(r1[3]) * 0.8)
	curve.tessellate()
	var c2 = curve.get_baked_points()
	c2.invert()
	# array sizes could be different
	# sloppy - put all extra triangles at end
	var tris = PoolVector2Array()
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
		if i % 2 == 0:
			tris.append(vb)
		else:
			tris.append(vs)
		draw_line(vb, vs, Color.coral)

	# Initialize the ArrayMesh.
#	var arr_mesh = ArrayMesh.new()
#	var arrays = []
#	arrays.resize(ArrayMesh.ARRAY_MAX)
#	arrays[ArrayMesh.ARRAY_VERTEX] = tris
#	# Create the Mesh.
#	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, arrays)
#	var m = MeshInstance.new()
#	m.mesh = arr_mesh
#	draw_mesh(arr_mesh, ???)



func make_rectangle(v1, v2, width = 25):
	# perpendicular vector with width
	var ppv = Vector2(v2.y - v1.y, -(v2.x - v1.x)).normalized() * width
	return PoolVector2Array([v1 + ppv, v2 + ppv, v2 - ppv, v1 - ppv])
