extends KinematicBody

# pathfinding variables:
var available_mvmts = []
var path = []
var curr_tile = null
var arena = null

# turn base variables:
var can_move = true

# pawn attributes variables:
export var ally = true
export var move_range = 3
export var jump_height = 1

# const
var MOVEMENT_SPEED = 800.0


# functions:
func init(var arena):
	self.arena = arena

func logic():
	self._update_curr_tile()
	if self._can_act():
		self._reset_acts()

func act(var delta, var tile):
	if self.ally:
		self._ally_act(tile)
	else:
		self._enemy_act()
	self.can_move = self._move(delta)
	return self._can_act()

# pawn acts
func _ally_act(var tile):
	self.available_mvmts = self._gen_available_mvmts()
	self.path = self._gen_path(tile)

func _enemy_act():
	#if self._ai_get_nearest_ally() != null:
	#	self.path = self._ai_gen_path_nearest_ally()
	#else:
	self.path = self._ai_gen_chase_path()


# aux functions:
func _update_curr_tile():
	self.curr_tile = $Ray/CurrTile.get_collider()

func _gen_available_mvmts():
	if self.available_mvmts.empty():
		if curr_tile != null:
			var curr_tile_piv = self.curr_tile
			var process_queue = []
			var av_mvmts = []
			curr_tile_piv.mv_available = true
			process_queue.push_back(curr_tile_piv)
			av_mvmts.append(curr_tile_piv)
			while !process_queue.empty():
				curr_tile_piv = process_queue.pop_front()
				# not to far
				if curr_tile_piv.distance < self.move_range:
					for neighbor in curr_tile_piv.neighbors:
						# not to high
						var height = abs(neighbor.get_translation().y - curr_tile_piv.get_translation().y)
						if  height <= self.jump_height:
							# not rooted yet
							if neighbor.root == null && neighbor != self.curr_tile:
								# tile available for pass over (used by team-mate)
								if neighbor.curr_pawn == null || neighbor.curr_pawn.ally == self.ally:
									neighbor.root = curr_tile_piv
									neighbor.distance = curr_tile_piv.distance + 1
									# tile available for standing on (empty tile)
									if neighbor.curr_pawn == null:
										neighbor.mv_available = true
										av_mvmts.append(neighbor)
									process_queue.push_back(neighbor)
			print("Pawn: they're ", av_mvmts.size(), " tiles availables for move")
			return av_mvmts
	return self.available_mvmts

func _gen_all_mvmts():
	if self.available_mvmts.empty():
		if curr_tile != null:
			var curr_tile_piv = self.curr_tile
			var process_queue = []
			var av_mvmts = []
			curr_tile_piv.mv_available = true
			process_queue.push_back(curr_tile_piv)
			av_mvmts.append(curr_tile_piv)
			while !process_queue.empty():
				curr_tile_piv = process_queue.pop_front()
				for neighbor in curr_tile_piv.neighbors:
					# not to high
					var height = abs(neighbor.get_translation().y - curr_tile_piv.get_translation().y)
					if  height <= self.jump_height:
						# not rooted yet
						if neighbor.root == null && neighbor != self.curr_tile:
							# tile available for pass over (used by team-mate)
							if neighbor.curr_pawn == null || neighbor.curr_pawn.ally == self.ally:
								neighbor.root = curr_tile_piv
								neighbor.distance = curr_tile_piv.distance + 1
								# tile available for standing on (empty tile)
								if neighbor.curr_pawn == null:
									# not to far
									if neighbor.distance <= self.move_range:
										neighbor.mv_available = true
										av_mvmts.append(neighbor)
								process_queue.push_back(neighbor)
			print("Pawn: they're ", av_mvmts.size(), " tiles availables for move")
			return av_mvmts
	return self.available_mvmts

func _gen_path(var dstny_tile, var ignore_mv_available = false):
	if !self.available_mvmts.empty() && self.path.empty():
		if dstny_tile != null && (dstny_tile.mv_available || ignore_mv_available):
			var mv_path = []
			while dstny_tile.root != null:
				mv_path.push_front(dstny_tile)
				dstny_tile = dstny_tile.root
			mv_path.push_front(dstny_tile)
			print("Pawn: generated path to ", mv_path.back().get_translation())
			return mv_path
	return self.path

func _move(var delta):
	if !self.available_mvmts.empty() && !self.path.empty():
		var from = self.get_translation()
		var to = self.path.front().get_translation()
		var dir = to - from
		var vel = dir.normalized() * delta * MOVEMENT_SPEED
		vel = self.move_and_slide(vel, Vector3.UP)
		if dir.length() < 0.3:
			self.set_translation(to)
			self.path.pop_front()
			if self.path.empty():
				self.available_mvmts.clear()
				return false
			else:
				print("Pawn: moving to ", self.path.front().get_translation())
	return true

func _can_act():
	return self.can_move

func _reset_acts():
	self.can_move = true


# AI functions:
func _ai_gen_path_nearest_ally():
	self.available_mvmts = self._gen_available_mvmts()
	return self._ai_get_path_nearest_ally()

func _ai_gen_chase_path():
	self.available_mvmts = self._gen_all_mvmts()
	return self._ai_get_chase_path()

func _ai_get_nearest_ally(var use_height = true):
	var nearest_allies = []
	if use_height:
		var allies = self.arena.allies
		for ally in allies:
			var height = abs(ally.get_translation().y - self.get_translation().y)
			if  height <= self.jump_height:
				nearest_allies.append(ally)
		if nearest_allies.empty():
			return null
	else:
		nearest_allies = self.arena.allies
	var nearest_ally = nearest_allies.front()
	for ally in nearest_allies:
		var from = self.get_translation()
		var distance = from.distance_to(ally.get_translation())
		var nearest_distance = from.distance_to(nearest_ally.get_translation())
		if distance < nearest_distance:
			nearest_ally = ally
	return nearest_ally

func _ai_get_nearest_tile(var pawn):
	if pawn != null:
		var nearest_tile = self.available_mvmts.front()
		for tile in self.available_mvmts:
			var from = tile.get_translation()
			var nearest_distance = nearest_tile.get_translation().distance_to(pawn.get_translation())
			var distance = from.distance_to(pawn.get_translation())
			if distance < nearest_distance:
				nearest_tile = tile
		return nearest_tile
	return null

func _ai_get_path_nearest_ally():
	if self.path.empty() && !self.available_mvmts.empty():
		var ally = self._ai_get_nearest_ally()
		var tile = self._ai_get_nearest_tile(ally)
		if tile == null:
			return self._gen_path(self.curr_tile)
		return self._gen_path(tile)
	return self.path

func _ai_get_nearest_neighbor(var tile):
	var neighbors = []
	for neighbor in tile.neighbors:
		if neighbor.curr_pawn == null:
			var height = abs(neighbor.get_translation().y - tile.get_translation().y)
			if height <= self.jump_height:
				neighbors.append(neighbor)
	if !neighbors.empty():
		var nearest = neighbors.front()
		for neighbor in neighbors:
			var nearest_distance =  self.get_translation().distance_to(nearest.get_translation())
			var distance = self.get_translation().distance_to(neighbor.get_translation())
			if distance < nearest_distance:
				nearest = neighbor
		return nearest
	return tile.neighbors.front()

func _ai_get_chase_path():
	if !self.available_mvmts.empty() && self.path.empty():
		var ally = self._ai_get_nearest_ally(false)
		var tile = self._ai_get_nearest_neighbor(ally.curr_tile)
		var mv_path = self._gen_path(tile, true)
		for ally in self.arena.allies:
			tile = self._ai_get_nearest_neighbor(ally.curr_tile)
			var tmp_path = self._gen_path(tile)
			if tmp_path.size() > 1 && tmp_path.size() < mv_path.size():
				mv_path = tmp_path
		while (mv_path.size() > self.move_range + 1):
			mv_path.pop_back()
		while mv_path.back().curr_pawn != null && mv_path.size() > 1:
			mv_path.pop_back()
		return mv_path
	return self.path