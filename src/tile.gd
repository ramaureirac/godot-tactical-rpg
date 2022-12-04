extends StaticBody3D
class_name TacticTile

const Utils = preload("res://src/utils.gd")

# tile tint materials https://fffuel.co/cccolor/ 
var hover_mat = Utils.create_material("FFFFFF3F")

var reachable_mat = Utils.create_material("008fdbBF")
var hover_reachable_mat = Utils.create_material("0aa9ffBF")

var attackable_mat = Utils.create_material("d10000BF")
var hover_attackable_mat = Utils.create_material("ff4242BF")

# pathfinding attributes
var root
var distance

# tile state
var reachable = false
var attackable = false
var hover = false

# indicators & stuff
var tile_raycasting = load("res://assets/tscn/tile_raycasting.tscn")


func get_neighbors(height):
	return $RayCasting.get_all_neighbors(height)


func get_object_above():
	return $RayCasting.get_object_above()


func is_taken():
	return get_object_above() != null


func reset():
	root = null
	distance = 0
	reachable = false
	attackable = false


func configure_tile():
	hover = false
	add_child(tile_raycasting.instantiate())
	reset()


func _process(_delta):
	$Tile.visible = attackable or reachable or hover
	match hover:
		true:
			if reachable: $Tile.material_override = hover_reachable_mat
			elif attackable: $Tile.material_override = hover_attackable_mat
			else: $Tile.material_override = hover_mat
		false:
			if reachable: $Tile.material_override = reachable_mat
			elif attackable: $Tile.material_override = attackable_mat
