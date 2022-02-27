extends Node

"""
Script for handling player actions, like select and move a pawn
camera movement and rotation, etc.
"""

var t_camera = null
var arena = null
var curr_pawn = null
var pawns = []
var player_ui = null

var state_control = 0

func configure(var my_camera, var my_arena, var my_ui):
	self.t_camera = my_camera
	self.arena = my_arena
	self.player_ui = my_ui
	self.pawns = self.get_children()

func camera_rotation():
	if Input.is_action_just_pressed("cam_rotate_right"):
		self.t_camera.y_rot += 90
	if Input.is_action_just_pressed("cam_rotate_left"):
		self.t_camera.y_rot -= 90

"""
func _select_pawn_for_movement():
	self.curr_pawn = self.t_camera.select_pawn()
	if !self.curr_pawn: return
	if !self.curr_pawn.can_act(): self.curr_pawn = null
	if !(self.curr_pawn in self.pawns): self.curr_pawn = null
	if self.curr_pawn != null and self.curr_pawn.can_act():
		var t = self.curr_pawn.get_tile()
		var d = self.curr_pawn.distance
		var h = self.curr_pawn.jump_height
		self.t_camera.set_target(t)
		self.arena.mark_available_movements(t, d, h, self.pawns)

func _select_tile_for_movement():
	var t = self.t_camera.select_tile()
	if t == null: return
	if t.reachable:
		self.t_camera.set_target(t)
		self.curr_pawn.path_stack = self.arena.gen_path(t)

func ally_move_pawn():
	if Input.is_action_just_pressed("ui_accept"):
		if self.curr_pawn == null:
			self._select_pawn_for_movement()
		elif self.curr_pawn.path_stack.empty():
			self._select_tile_for_movement()
		return self.curr_pawn
"""

func _aux_select_a_pawn():
	var p = self.t_camera.select_pawn()
	if p and p in self.pawns and p.can_act():
		self.t_camera.set_target(p.get_tile())
		self.curr_pawn = p
		self.state_control = 1

func _act_select_a_pawn():
	self.arena.reset()
	self.curr_pawn = null
	self.player_ui.update_buttons(self.curr_pawn, false)
	if Input.is_action_just_released("ui_accept"):
		self._aux_select_a_pawn()

func _act_select_an_cmd_for_pawn():
	self.arena.reset()
	self.curr_pawn.get_tile().reachable = true
	self.player_ui.update_buttons(self.curr_pawn, true)
	if Input.is_action_just_pressed("ui_cancel"):
		self.state_control = 0
	elif Input.is_action_just_pressed("player_move_pawn"):
		var t = self.curr_pawn.get_tile()
		var d = self.curr_pawn.distance
		var h = self.curr_pawn.jump_height
		self.arena.mark_available_movements(t, d, h, self.pawns)
		self.state_control = 2
	elif Input.is_action_just_released("ui_accept"):
		self._aux_select_a_pawn()

func _act_select_a_tile_to_move():
	self.player_ui.update_buttons(self.curr_pawn, true)
	if Input.is_action_just_pressed("ui_cancel"):
		self.state_control = 1
	elif Input.is_action_just_pressed("ui_accept"):
		var t = self.t_camera.select_tile()
		if t and t.reachable:
			self.t_camera.set_target(t)
			self.curr_pawn.path_stack = self.arena.gen_path(t)
			self.state_control = 3

func _act_move_selected_pawn(var delta):
	self.player_ui.update_buttons(null, false)
	if self.curr_pawn.move(delta):
		self.curr_pawn.can_move = false
		self.curr_pawn = null
		self.state_control = 0
		self.arena.reset()

func act(var delta):
	match self.state_control:
		0: self._act_select_a_pawn()
		1: self._act_select_an_cmd_for_pawn()
		2: self._act_select_a_tile_to_move()
		3: self._act_move_selected_pawn(delta)

