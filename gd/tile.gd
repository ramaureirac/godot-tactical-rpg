extends StaticBody


var neighbors = []		# tile neighbors
var reachable = false	# can I reach and stand in here?
var path_gen = false		# the path generated is throught this tile
var taken = false		# there is something above this?
var root = null			# tile's parent
var weight = 0			# current distance from current tile

func _find_neighbors():
	if self.neighbors.empty():
		for r in $Ray/Neighbors.get_children():
			if r.is_colliding():
				self.neighbors.append(r.get_collider())

func _mark_tile():
	$Indicators/Reachable.visible = self.reachable and !self.path_gen
	$Indicators/PathGen.visible = self.reachable and self.path_gen

func _process(_delta):
	self._find_neighbors()
	self._mark_tile()
	self.taken = $Ray/Up.is_colliding()

func reset():
	self.reachable = false
	self.path_gen = false
	self.taken = false
	self.root = null
	self.weight = 0
