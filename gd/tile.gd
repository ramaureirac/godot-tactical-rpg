extends StaticBody

var neighbors = []			
var reachable = false		
var path_gen = false
var taken = false
var root = null	
var weight = 0
var inv_weight = INF

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
	self.inv_weight = INF
