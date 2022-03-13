extends Spatial

const MAX_THINKING_TIME = 0.25

var curr_pawn = null
var t_camera = null
var arena = null
var pawns = []
var enemies = []
var ui = null

var stage_control = 0
var thinking_time = 0

func configure(var my_camera, var my_arena, var my_enemies, var my_ui):
	self.t_camera = my_camera
	self.arena = my_arena
	self.enemies = my_enemies
	self.pawns = self.get_children()
	self.ui = my_ui

func _act_select_a_pawn():
	self.arena.reset()
	for p in self.pawns:
		if p and p.can_act():
			self.curr_pawn = p
			self.stage_control = 1
	self.ui.display_pawn_stats(self.curr_pawn)
	self.curr_pawn.get_tile().reachable = true

func _aux_act_simulate_thinking(var delta):
	self.thinking_time += delta
	if self.thinking_time <= MAX_THINKING_TIME: return false
	self.thinking_time = 0
	return true

func _aux_act_mark_available_movements():
	var t = self.curr_pawn.get_tile()
	var d = self.curr_pawn.distance
	var h = self.curr_pawn.jump_height
	self.arena.mark_available_movements(t, d, h, self.pawns)

func _aux_act_get_nearest_tile_for_all_enemies():
	"""
	This will return an array of the nearest tile available
	for each enemy. 
	"""
	var tiles = []
	var p_t = self.curr_pawn.get_tile()
	var h = self.curr_pawn.jump_height
	for e in self.enemies:
		var e_t = e.get_tile()
		tiles.append(self.arena.find_nearest_tile_neighbor(p_t, e_t, h))
	return tiles

func _aux_act_get_nearest_tile_for_enemy():
	"""
	By using '_aux_act_get_nearest_tile_for_all_enemies' in order to get
	all posibly destinations, it will return the nearest tile of all tiles 
	reviced
	"""
	var tiles = self._aux_act_get_nearest_tile_for_all_enemies()
	var tile = tiles.front()
	for t in tiles: if t and t.weight < tile.weight: tile = t
	return tile

func _aux_act_get_nearest_reachable_tile(var tile):
	return self.arena.find_nearest_tile_reachable(tile)

func _act_evaluate_best_action(var _delta):
	#if !self._aux_act_simulate_thinking(delta): return
	if self.curr_pawn.can_move: self.stage_control = 2
	elif self.curr_pawn.can_attack: self.stage_control = 4

func _act_select_a_tile_to_move(var delta):
	# chase nearest enemy
	self._aux_act_mark_available_movements()
	if !self._aux_act_simulate_thinking(delta): return
	var t = self._aux_act_get_nearest_tile_for_enemy()
	t = self._aux_act_get_nearest_reachable_tile(t)
	self.curr_pawn.path_stack = self.arena.gen_path(t)
	self.t_camera.set_target(t)
	self.stage_control = 3

func _act_select_a_tile_to_attack(delta):
	var t = self.curr_pawn.get_tile()
	var r = self.curr_pawn.attack_radious
	self.arena.reset()
	var tiles = self.arena.mark_attackable_tiles(t, r, self.enemies + self.pawns)
	var best_p = null
	for tt in tiles:
		var p = tt.get_object_above()
		if p and p in self.enemies: best_p = p
	if !self._aux_act_simulate_thinking(delta): return
	self.curr_pawn.attack(best_p)
	self.curr_pawn.can_attack = false
	if self.curr_pawn.can_act(): self.stage_control = 1
	else: self.stage_control = 0

func _act_move_selected_pawn(var delta):
	if self.curr_pawn.move(delta):
		self.curr_pawn.can_move = false
		if self.curr_pawn.can_act(): self.stage_control = 1
		else: self.stage_control = 0

func act(var delta):
	match stage_control:
		0: self._act_select_a_pawn()
		1: self._act_evaluate_best_action(delta)
		2: self._act_select_a_tile_to_move(delta)
		3: self._act_move_selected_pawn(delta)
		4: self._act_select_a_tile_to_attack(delta)

