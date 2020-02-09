extends MeshInstance

export(float) var terrain_width = 16
export(float) var terrain_depth = 16
export(float) var terrain_height = 1
export(float) var terrain_scale = 1

#Noise Generation
var terrain_noise = OpenSimplexNoise.new()

var terrain_heightmap = ImageTexture.new()
var terrain_texture = Texture.new()
var terrain_material = SpatialMaterial.new()
var terrain_mesh = Mesh.new()

var surfacetool = SurfaceTool.new()

func _ready():
	generate_heightmap()
	generate_mesh()

func generate_heightmap():
	#Setup the noise
	terrain_noise.seed = randi()
	terrain_noise.octaves = 4
	terrain_noise.period = 20.0
	terrain_noise.persistence = 0.8

	#Make the texture
	terrain_heightmap.create_from_image(terrain_noise.get_image(terrain_width+1, terrain_depth+1))
	terrain_texture = terrain_heightmap

func generate_mesh():
	#Set the material texture to the heightmap
	terrain_material.albedo_texture = terrain_texture

	# This is where the uv-mapping occurs, via the add_uv function
	for z in range(0,terrain_depth):
		surfacetool.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
		for x in range(0,terrain_width):

			surfacetool.add_uv(Vector2((terrain_width-x)/terrain_width,z/terrain_depth))
			surfacetool.add_vertex(Vector3((terrain_width-x)*terrain_scale, terrain_noise.get_noise_2d(x,z)*terrain_height*terrain_scale, z*terrain_scale))
			surfacetool.add_uv(Vector2((terrain_width-x)/terrain_width,(z+1)/terrain_depth))
			surfacetool.add_vertex(Vector3((terrain_width-x)*terrain_scale, terrain_noise.get_noise_2d(x,z+1)*terrain_height*terrain_scale, (z+1)*terrain_scale))

		surfacetool.generate_normals()
		surfacetool.index()

		surfacetool.commit(terrain_mesh)

	#Set the texture and mesh on the MeshInstance
	self.material_override = terrain_material
	self.set_mesh(terrain_mesh)
	self.set_surface_material(0, terrain_texture)
