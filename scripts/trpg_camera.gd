extends Spatial

# variables:
var pitch = -45.0
var yaw = -45.0

# const:
const ROTATION_SPEED = 6.0
const MOVEMENT_SPEED = 4.0


# functions:
func logic(var delta, var pawn):
	self._follow_pawn(delta, pawn)
	self._rotate_arround(delta)
	return self._get_selected_tile()


# aux functions:
func _follow_pawn(var delta, var pawn):
	var from = self.get_translation()
	var to = pawn.get_translation()
	if from != to:
		var move = from.linear_interpolate(to, delta * MOVEMENT_SPEED)
		self.set_translation(move)

func _rotate_arround(var delta):
	if Input.is_action_just_pressed("ui_left"):
		self.yaw -= 90.0
	if Input.is_action_just_pressed("ui_right"):
		self.yaw += 90.0
	if Input.is_action_just_pressed("ui_up"):
		self.pitch -= 15.0
	if Input.is_action_just_pressed("ui_down"):
		self.pitch += 15.0
	self.pitch = clamp(self.pitch, -60.0, -30.0)
	var from = self.get_rotation()
	var to = Vector3(deg2rad(self.pitch), deg2rad(self.yaw), 0.0)
	var euler = from.linear_interpolate(to, delta * ROTATION_SPEED)
	self.set_rotation(euler)

func _get_selected_tile():
	if Input.is_action_just_pressed("ui_accept"):
		var tap = get_viewport().get_mouse_position()
		var from = $Camera.project_ray_origin(tap)
		var to = from + $Camera.project_ray_normal(tap) * 10000
		var space_state = get_world().direct_space_state
		return space_state.intersect_ray(from, to, [], 1).get("collider")
	return null