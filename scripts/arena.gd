extends Spatial

func find_nearest_tile_reachable(var tile):
	"""
	if a tile is not reachable, this function will return the 
	the closest tile on its movement_tree
	"""
	while !tile.reachable:
		tile = tile.root
	return tile

func find_nearest_tile_neighbor(var from, var to, var h=3):
	"""
	giving a tile 'to' it will find the shortest path to one of its
	neighbors. This is usefull when pawns are following a target
	"""
	to.inv_weight = 0
	var pq = [to]
	var chk = []
	var tile = from
	while !pq.empty():
		var t = pq.pop_front()
		if (t.root or t == from) and !t.taken:
			if t.inv_weight < tile.inv_weight:
				tile = t
			elif t.inv_weight == tile.inv_weight and t.weight < tile.weight:
				tile = t
		else:
			for n in t.neighbors:
				var ny = n.get_translation().y
				var ty = t.get_translation().y
				if !(n in chk) and !(n in pq) and abs(ny-ty) <= h:
					n.inv_weight = t.inv_weight + 1
					pq.append(n)
		chk.append(t)
	return tile

func _gen_movement_tree(var tile, var height, var walkeable_obj):
	"""
	generate a movement tree linking each tile of the arena with his parent.
	this will set 'tile' as the head of the movement tree.
	the variable 'walkeable_obj' will contain game objects which a pawn can
	pass throught but can't stand on it, e.g: pawns of the same team
	"""
	var pq = [tile]
	while !pq.empty():
		var t = pq.pop_front()
		for n in t.neighbors:
			if n != tile:
				var obj = n.get_object_above()
				if n.root == null and (obj in walkeable_obj or !obj):
					var ny = n.get_translation().y
					var ty = t.get_translation().y
					if abs(ny-ty) < height:
						n.root = t
						n.weight = t.weight + 1
						pq.push_back(n)

func mark_available_movements(var from, var d, var h=3, var walkeable_obj=[]):
	"""
	mark which tiles are reachable according
	to 'd' parameter. First it link all possible destinations.
	"""
	if from == null: return
	self._gen_movement_tree(from, h, walkeable_obj)
	for t in $Tiles.get_children():
		if t == from or t.weight <= d and t.weight > 0 and !t.taken:
			t.reachable = true

func gen_path(var tile):
	"""
	generate path to 'tile'
	"""
	var path = []
	while tile != null:
		path.push_front(tile)
		tile.path_gen = true
		tile = tile.root
	return path

func reset():
	for t in $Tiles.get_children():
		t.reset()
