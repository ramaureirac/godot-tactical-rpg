extends Spatial

const SPEED = 8.0

var x_rot = -30.0
var y_rot = -45
var target = null

func _select(var lmask = 1):
	var o = get_viewport().get_mouse_position()
	var from = $Camera.project_ray_origin(o)
	var to = from + $Camera.project_ray_normal(o) * 1000000
	var s = get_world().direct_space_state
	return s.intersect_ray(from, to, [], lmask).get("collider")

func select_tile():
	return self._select(1)

func select_pawn():
	return self._select(2)

func set_target(var t):
	if t != null: self.target = t

func _move_to_target(var delta):
	if self.target == null: return
	var curr_t = self.get_translation()
	var dst_t = self.target.get_translation()
	var v = curr_t.linear_interpolate(dst_t, SPEED*delta)
	self.set_translation(v)

func _rotate(var delta):
	var curr_r = self.get_rotation()
	var x = deg2rad(self.x_rot)
	var y = deg2rad(self.y_rot)
	var dst_r = Vector3(x, y, 0.0)
	var e = curr_r.linear_interpolate(dst_r, SPEED*delta)
	self.set_rotation(e)

func _process(var delta):
	self._rotate(delta)
	self._move_to_target(delta)
