@tool
extends MeshInstance3D

const Y_OFFSET = 0.01
const TILE_EXTENT = 0.5
const HEIGHT_EXTENT = 0.25

func _ready():
	if !mesh:
		mesh = ArrayMesh.new()
		
		var surface_array = []
		surface_array.resize(mesh.ARRAY_MAX)
		
		surface_array[Mesh.ARRAY_VERTEX] = PackedVector3Array([
				Vector3(-TILE_EXTENT, Y_OFFSET + HEIGHT_EXTENT, -TILE_EXTENT),
				Vector3(TILE_EXTENT, Y_OFFSET + HEIGHT_EXTENT, -TILE_EXTENT),
				Vector3(TILE_EXTENT, Y_OFFSET - HEIGHT_EXTENT, TILE_EXTENT),
				Vector3(-TILE_EXTENT, Y_OFFSET - HEIGHT_EXTENT, TILE_EXTENT),
			])
		
		surface_array[Mesh.ARRAY_INDEX] = PackedInt32Array([
				0, 1, 2,
				2, 3, 0,
			])
		
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
