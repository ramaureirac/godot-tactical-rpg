extends KinematicBody

const MOVE_SPEED = 16
const ROT_SPEED = 10

var x_rot = -30
var y_rot = -45
var target = null


func move_camera(var h, var v, var joystick):
	if !joystick and h == 0 and v == 0 or target: return
	var angle = (atan2(-h, v))+$Pivot.get_rotation().y
	var dir = Vector3.FORWARD.rotated(Vector3.UP, angle)
	var vel = dir*MOVE_SPEED
	if joystick: vel = vel*sqrt(h*h+v*v)
	vel = move_and_slide(vel, Vector3.UP)


func rotate_camera(var delta):
	var curr_r = $Pivot.get_rotation()
	var x = deg2rad(x_rot)
	var y = deg2rad(y_rot)
	var dst_r = Vector3(x, y, 0)
	$Pivot.set_rotation(curr_r.linear_interpolate(dst_r, ROT_SPEED*delta))


func follow():
	if !target: return
	var from = global_transform.origin
	var to = target.global_transform.origin
	var vel = (to-from)*MOVE_SPEED/4
	vel = move_and_slide(vel, Vector3.UP)
	if from.distance_to(to) <= 0.25: target = null


func _process(var delta):
	rotate_camera(delta)
	follow()
