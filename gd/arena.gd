extends Spatial

func _gen_movement_tree(var tile):
	"""
	generate a movement tree linking each tile of the arena with his parent.
	this will set 'tile' as the head of the movement tree.
	"""
	var pq = [tile]
	while !pq.empty():
		var t = pq.pop_front()
		for n in t.neighbors:
			if n.root == null and n != tile and !n.taken:
				n.root = t
				n.weight = t.weight + 1
				pq.push_back(n)

func mark_available_movements(var from, var d=10):
	"""
	mark which tiles are reachable acording
	to 'd' parameter. First it link all possible destinations.
	"""
	if from == null: return
	self._gen_movement_tree(from)
	for t in $Tiles.get_children():
		if t == from or t.weight <= d and t.weight > 0:
			t.reachable = true

func gen_path(var t):
	"""
	generate path to 't' only if 't' was tagged as reachable
	by the 'mark_available_movements' method.
	"""
	var path = []
	while t != null and t.reachable:
		path.push_front(t)
		t.path_gen = true
		t = t.root
	return path

func reset():
	for t in $Tiles.get_children():
		t.reset()
