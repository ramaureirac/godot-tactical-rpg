const TILE_SRC = "res://src/tile.gd"

enum PAWN_CLASSES {Knight, Archer, Chemist, Cleric, Skeleton, SkeletonCPT, SkeletonMage}
enum PAWN_STRATEGIES {Tank, Flank, Support}
const KNIGHT_SPRITE = "res://assets/sprites/characters/chr_pawn_knight.png"
const ARCHER_SPRITE = "res://assets/sprites/characters/chr_pawn_archer.png"
const CHEMIST_SPRITE = "res://assets/sprites/characters/chr_pawn_chemist.png"
const CLERIC_SPRITE = "res://assets/sprites/characters/chr_pawn_mage.png"
const SKELETON_CPT_SPRITE = "res://assets/sprites/characters/chr_pawn_skeleton_cpt.png"
const SKELETON_SPRITE = "res://assets/sprites/characters/chr_pawn_skeleton.png"
const SKELETON_MAGE_SPRITE = "res://assets/sprites/characters/chr_pawn_skeleton_mage.png"


static func convert_tiles_into_static_bodies(var tiles_obj):

	"""
	Given a Spatial Node as parameter (tiles_obj), this function will iterate over each
	of its children converting them into a static body and attaching the tile.gd script.
	e.g. this function will transform the 'Tiles' into the following structure:
	
		> Tiles:                                > Tiles:
			> Tile1                                 > StaticBody (tile.gd):
			> Tile2                                     > Tile1
			...                                         > CollisionShape
			> TileN       -- TRANSFORM INTO ->      > StaticBody2 (tile.gd):
														> Tile2
														> CollisionShape
													...
													> StaticBodyN (tile.gd):
														> TileN
														> CollisionShape

	As you can see this is very usefull for configure walkeable tiles as fast as posible
	especially if the map used was exported from Blender using the Godot Extension
	"""

	for t in tiles_obj.get_children():
		t.create_trimesh_collision()
		var static_body = t.get_child(0)
		static_body.set_translation(t.get_translation())
		t.set_translation(Vector3.ZERO)
		t.set_name("Tile")
		t.remove_child(static_body)
		tiles_obj.remove_child(t)
		static_body.add_child(t)
		static_body.set_script(load(TILE_SRC))
		static_body.configure_tile()
		static_body.set_process(true)
		tiles_obj.add_child(static_body)


static func create_material(var color, var texture=null):
	var material = SpatialMaterial.new()
	material.flags_transparent = true
	material.albedo_color = Color(color)
	material.albedo_texture = texture
	return material


static func get_pawn_sprite(var pawn_class):
	match pawn_class:
		0: return load(KNIGHT_SPRITE)
		1: return load(ARCHER_SPRITE)
		2: return load(CHEMIST_SPRITE)
		3: return load(CLERIC_SPRITE)
		4: return load(SKELETON_SPRITE)
		5: return load(SKELETON_CPT_SPRITE)
		6: return load(SKELETON_MAGE_SPRITE)
    

static func get_pawn_move_radious(var pawn_class):
	match pawn_class:
		0: return 3
		1: return 5
		2: return 4
		3: return 4
		4: return 5
		5: return 3
		6: return 4


static func get_pawn_jump_height(var pawn_class):
	match pawn_class:
		0: return 0.5
		1: return 3
		2: return 1
		3: return 1
		4: return 3
		5: return 0.5
		6: return 1


static func get_pawn_attack_radious(var pawn_class):
	match pawn_class:
		0: return 1
		1: return 6
		2: return 3
		3: return 3
		4: return 6
		5: return 1
		6: return 3


static func get_pawn_attack_power(var pawn_class):
	match pawn_class:
		0: return 20
		1: return 10
		2: return 12
		3: return 12
		4: return 10
		5: return 20
		6: return 12


static func get_pawn_health(var pawn_class):
	match pawn_class:
		0: return 50
		1: return 35
		2: return 30
		3: return 25
		4: return 35
		5: return 50
		6: return 30


static func vector_remove_y(var vector):
	return vector*Vector3(1,0,1)


static func vector_distance_without_y(var b, var a):
	return vector_remove_y(b).distance_to(vector_remove_y(a))