extends Node

"""
Script for handling player actions, like select and move a pawn
camera movement and rotation, etc.
"""

var t_camera = null
var arena = null
var curr_pawn = null
var pawns = []

func configure(var my_camera, var my_arena):
	self.t_camera = my_camera
	self.arena = my_arena
	self.pawns = self.get_children()

func camera_rotation():
	if Input.is_action_just_pressed("cam_rotate_right"):
		self.t_camera.y_rot += 90
	if Input.is_action_just_pressed("cam_rotate_left"):
		self.t_camera.y_rot -= 90

func _select_pawn_for_movement():
	self.curr_pawn = self.t_camera.select_pawn()
	if !self.curr_pawn: return
	if !self.curr_pawn.can_act(): self.curr_pawn = null
	if !(self.curr_pawn in self.pawns): self.curr_pawn = null
	if self.curr_pawn != null and self.curr_pawn.can_act():
		var t = self.curr_pawn.get_tile()
		var d = self.curr_pawn.distance
		self.t_camera.set_target(t)
		self.arena.mark_available_movements(t, d, self.pawns)

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
			
