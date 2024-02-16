extends Node3D
class_name TacticsArena

@export var pksc_tile: PackedScene
@export var pksc_slope: PackedScene

@export var items_using_tiles: Array[int]
@export var items_using_slopes: Array[int]

const Utils = preload("res://src/utils.gd")


func link_tiles(root, height, allies_arr=null):
	var pq = [root]
	while !pq.is_empty():
		var curr_tile : TacticTile = pq.pop_front()
		for neighbor in curr_tile.get_neighbors(height):
			if !neighbor.root and neighbor != root:
				if !(neighbor.is_taken() and allies_arr and !neighbor.get_object_above() in allies_arr):
					neighbor.root = curr_tile
					neighbor.distance = curr_tile.distance+1
					pq.push_back(neighbor)


func mark_hover_tile(tile : TacticTile):
	for t in $Tiles.get_children(): t.hover = false
	if tile: tile.hover = true


func mark_reachable_tiles(root : TacticTile, distance):
	for t in $Tiles.get_children():
		t.reachable = t.distance > 0 and t.distance <= distance and !t.is_taken() or t == root


func mark_attackable_tiles(root : TacticTile, distance):
	for t in $Tiles.get_children():
		t.attackable = t.distance > 0 and t.distance <= distance or t == root


func generate_path_stack(to):
	var path_stack = []
	while to:
		#to.hover = true
		path_stack.push_front(to.global_transform.origin)
		to = to.root
	return path_stack


func reset():
	for t in $Tiles.get_children(): t.reset()


func _ready():
	for c in $GridMap.get_used_cells():
		var item = $GridMap.get_cell_item(c)
		
		var mesh
		if item in items_using_tiles:
			mesh = pksc_tile.instantiate()
		elif item in items_using_slopes:
			mesh = pksc_slope.instantiate()
			mesh.set_basis($GridMap.get_cell_item_basis(c))
		
		if mesh:
			$Tiles.add_child(mesh)
			mesh.set_position($GridMap.map_to_local(c))
	
	$Tiles.visible = true
	Utils.convert_tiles_into_static_bodies($Tiles)


func get_nearest_neighbor_to_pawn(pawn, pawn_arr):
	var nearest_t = null
	for p in pawn_arr:
		if p.curr_health <= 0: continue
		for n in p.get_tile().get_neighbors(pawn.jump_height):
			if (!nearest_t or n.distance < nearest_t.distance) and n.distance > 0 and !n.is_taken():
				nearest_t = n
	while nearest_t and !nearest_t.reachable: nearest_t = nearest_t.root
	return nearest_t if nearest_t else pawn.get_tile()


func get_weakest_pawn_to_attack(pawn_arr):
	var weakest = null
	for p in pawn_arr:
		if (!weakest or p.curr_health < weakest.curr_health) and p.curr_health > 0 and p.get_tile().attackable:
			weakest = p
	return weakest
