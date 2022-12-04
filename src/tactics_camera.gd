extends CharacterBody3D
class_name TacticsCamera

const MOVE_SPEED = 16
const ROT_SPEED = 10

var x_rot = -30
var y_rot = -45
var target = null


func move_camera(h, v, joystick):
	if !joystick and h == 0 and v == 0 or target: return
	var angle = (atan2(-h, v))+$Pivot.get_rotation().y
	var dir = Vector3.FORWARD.rotated(Vector3.UP, angle)
	var vel = dir*MOVE_SPEED
	if joystick: vel = vel*sqrt(h*h+v*v)
	set_velocity(vel)
	set_up_direction(Vector3.UP)
	move_and_slide()
	vel = velocity


func rotate_camera(delta):
	var curr_r = $Pivot.get_rotation()
	var x = deg_to_rad(x_rot)
	var y = deg_to_rad(y_rot)
	var dst_r = Vector3(x, y, 0)
	$Pivot.set_rotation(curr_r.lerp(dst_r, ROT_SPEED*delta))


func follow():
	if !target: return
	var from = global_transform.origin
	var to = target.global_transform.origin
	var vel = (to-from)*MOVE_SPEED/4
	set_velocity(vel)
	set_up_direction(Vector3.UP)
	move_and_slide()
	vel = velocity
	if from.distance_to(to) <= 0.25: target = null


func _process(delta):
	rotate_camera(delta)
	follow()
