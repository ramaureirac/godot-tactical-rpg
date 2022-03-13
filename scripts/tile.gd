extends StaticBody

# path finding
var neighbors = []
var root = null	
var weight = 0
var inv_weight = INF

# indicators
var reachable = false		
var path_gen = false
var taken = false
var attackable = false

# REFACTOR + OPTIMIZE!!!! X2
# note: use above raycast in order to know if is taken!!!!!!!!!!!
func _find_neighbors():
	if $Neighbors and self.neighbors.size() == 0:
		for areas in $Neighbors.get_children():
			for a in areas.get_overlapping_bodies():
				var ay = a.get_translation().y
				var sy = self.get_translation().y
				if ay == sy:
					self.neighbors.append(a)
				elif ay > sy:
					var from = self.get_translation()-Vector3.UP*0.15
					var to = self.get_translation()+Vector3.UP*(ay-sy+2)
					var s = get_world().get_direct_space_state()
					if !s.intersect_ray(from, to, [], 1):
						self.neighbors.append(a)
				else:
					var from = a.get_translation()-Vector3.UP*0.15
					var to = a.get_translation()+Vector3.UP*(sy-ay+2)
					var s = get_world().get_direct_space_state()
					if !s.intersect_ray(from, to, [], 1):
						self.neighbors.append(a)

func _mark_tile():
	$Indicators/Reachable.visible = self.reachable and !self.path_gen
	$Indicators/PathGen.visible = self.reachable and self.path_gen
	$Indicators/Attackable.visible = self.attackable

func _process(_delta):
	self._find_neighbors()
	self._mark_tile()
	self.taken = $Ray/Up.is_colliding()

func get_object_above():
	return $Ray/Up.get_collider()

func reset():
	self.reachable = false
	self.path_gen = false
	self.taken = false
	self.attackable = false
	self.root = null
	self.weight = 0
	self.inv_weight = INF
