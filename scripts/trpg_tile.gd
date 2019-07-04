extends StaticBody

# pathfinding variables:
var root = null
var distance = 0
var neighbors = []

# state variables:
var mv_available = false
var curr_pawn = null


# functions:
func logic():
	if self.neighbors.empty():
		self._find_neighbors()
	self._update_indicator()
	self._update_curr_pawn()

func reset():
	self.root = null
	self.distance = 0
	self.mv_available = false
	self.curr_pawn = null


# aux functions
func _find_neighbors():
	self._find_neigbor($Ray/East)
	self._find_neigbor($Ray/North)
	self._find_neigbor($Ray/South)
	self._find_neigbor($Ray/West)

func _find_neigbor(var ray):
	if ray.is_colliding():
		self.neighbors.append(ray.get_collider())

func _update_indicator():
	$Indicator/MvAvailable.visible = self.mv_available

func _update_curr_pawn():
	self.curr_pawn = $Ray/Above.get_collider()
