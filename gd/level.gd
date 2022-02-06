extends Spatial

"""
TODO
change find nearest ally logic. Evaluate each path weight instead
change for in enemy turn, use a queue instead!!
configure jump and vertical tiles like buildings, bridges, etc.
posiblity to pass over tiles that are taken by your same team
attack and health
"""

var curr_pawn = null
var ally_turn = true
var allies = []
var enemies = []

func _ready():
	self.allies = $Allies.get_children()
	self.enemies = $Enemies.get_children()

func _find_nearest(var e, var arr):
	if e == null or arr.empty(): return null
	var na = arr.front()
	var na_d = (na.get_translation() - e.get_translation()).length()
	for a in arr:
		var new_na_d = (a.get_translation() - e.get_translation()).length()
		if new_na_d < na_d:
			na = a
			na_d = new_na_d
	return na

func _find_nearest_tile_to_pawn(var e, var allies_arr):
	var na = self._find_nearest(e, allies_arr)
	var tile = e.get_tile()
	var tile_w = INF
	for t in na.get_tile().neighbors:
		if t == e.get_tile() or (t.root != null and t.weight < tile_w):
			tile = t
			tile_w = t.weight
	while !tile.reachable:
		tile = tile.root
	return tile

func _check_switch_turn():
	"""
	at the end of the function '_process' this will check if
	there are some available movements before force the end
	of the turn
	"""
	if self.ally_turn:
		for a in self.allies:
			if a.can_act(): 
				self.ally_turn = true
				return
		self.ally_turn = false
	else:
		for e in self.enemies:
			if e.can_act(): 
				self.ally_turn = false
				return
		self._reset_turns()

func _reset_turns():
	self.ally_turn = true
	for p in (self.allies + self.enemies):
		p.can_move = true

func _ally_choose_destination():
	if Input.is_action_just_pressed("ui_accept"):
		# from
		if self.curr_pawn == null:
			self.curr_pawn = $TCamera.select_pawn()
			if !self.curr_pawn.can_act(): self.curr_pawn = null
			if !(self.curr_pawn in self.allies): self.curr_pawn = null
			if self.curr_pawn != null and self.curr_pawn.can_act():
				var t = self.curr_pawn.get_tile()
				var d = self.curr_pawn.distance
				$TCamera.set_target(t)
				$Arena.mark_available_movements(t, d)
		# to
		elif self.curr_pawn != null and self.curr_pawn.path_stack.empty():
			var t = $TCamera.select_tile()
			if t == null: return
			if t.reachable:
				$TCamera.set_target(t)
				self.curr_pawn.path_stack = $Arena.gen_path(t)

func _enemy_choose_destination():
	## change for a queue
	if self.curr_pawn != null: return
	for e in self.enemies:
		if e.can_act():
			var t = e.get_tile()
			var d = e.distance
			$TCamera.set_target(t)
			$Arena.mark_available_movements(t, d)
			var nt = self._find_nearest_tile_to_pawn(e, self.allies)
			$TCamera.set_target(nt)
			e.path_stack = $Arena.gen_path(nt)
			self.curr_pawn = e
			return

func _move_pawn(var delta):
	if self.curr_pawn != null and self.curr_pawn.move(delta):
		self.curr_pawn.can_move = false
		self.curr_pawn = null
		$Arena.reset()

func _camera_rotation():
	if Input.is_action_just_pressed("cam_rotate_right"):
		$TCamera.y_rot += 90
	if Input.is_action_just_pressed("cam_rotate_left"):
		$TCamera.y_rot -= 90

func _turn_handler():
	if self.ally_turn:
		self._ally_choose_destination()
	else:
		self._enemy_choose_destination()
	self._check_switch_turn()

func _process(var delta):
	self._turn_handler()
	self._move_pawn(delta)
	self._camera_rotation()
