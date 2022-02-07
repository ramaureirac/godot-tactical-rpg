extends Spatial

func find_nearest_tile_reachable(var tile):
	while !tile.reachable:
		tile = tile.root
	return tile

func find_nearest_tile_neighbor(var from, var to):
	to.inv_weight = 0
	var pq = [to]
	var chk = []
	var tile = from
	while !pq.empty():
		var t = pq.pop_front()
		if t.root or t == from:
			if t.inv_weight < tile.inv_weight:
				tile = t
			elif t.inv_weight == tile.inv_weight and t.weight < tile.weight:
				tile = t
		else:
			for n in t.neighbors:
				if !(n in chk) and !(n in pq):
					n.inv_weight = t.inv_weight + 1
					pq.append(n)
		chk.append(t)
	return tile

func _gen_movement_tree(var tile):
	"""
	generate a movement tree linking each tile of the arena with his parent.
	this will set 'tile' as the head of the movement tree.
	"""
	var pq = [tile]
	while !pq.empty():
		var t = pq.pop_front()
		for n in t.neighbors:
			if n != tile:
				if n.root == null and !n.taken:
					n.root = t
					n.weight = t.weight + 1
					pq.push_back(n)

func mark_available_movements(var from, var d):
	"""
	mark which tiles are reachable according
	to 'd' parameter. First it link all possible destinations.
	"""
	if from == null: return
	self._gen_movement_tree(from)
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
