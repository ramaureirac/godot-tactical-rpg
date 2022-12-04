extends CharacterBody3D
class_name TacticsPawn 

const Utils = preload("res://src/utils.gd")

const SPEED = 7
const ANIMATION_FRAMES = 1
const MIN_HEIGHT_TO_JUMP = 1
const GRAVITY_STRENGTH = 7
const MIN_TIME_FOR_ATTACK = 1

# class
@export var pawn_class : Utils.PAWN_CLASSES
@export var pawn_strategy : Utils.PAWN_STRATEGIES
@export var pawn_name : String = "Trooper"

# pawn available actions
var can_move = true
var can_attack = true

# stats
var move_radious 
var jump_height
var attack_radious
var attack_power
var max_health = 100
var curr_health = 100

# animation
var curr_frame : int = 0
var animator = null

# pathfinding
var path_stack = []
var move_direction = null
var is_jumping = false
var gravity = Vector3.ZERO
var wait_delay = 0


func get_tile():
	return $Tile.get_collider()


func rotate_pawn_sprite():
	var camera_forward = -get_viewport().get_camera_3d().global_transform.basis.z
	var dot = global_transform.basis.z.dot(camera_forward)
	$Character.flip_h = global_transform.basis.x.dot(camera_forward) > 0
	if dot < -0.306: $Character.frame = curr_frame
	elif dot > 0.306: $Character.frame = curr_frame + 1 * ANIMATION_FRAMES


func look_at_direction(dir):
	var fixed_dir = dir*(Vector3(1,0,0) if abs(dir.x) > abs(dir.z) else Vector3(0,0,1))
	var angle = Vector3.FORWARD.signed_angle_to(fixed_dir.normalized(), Vector3.UP)+PI
	set_rotation(Vector3.UP*angle)


func follow_the_path(delta):
	if !can_move : return
	if move_direction == null : move_direction = path_stack.front()-global_transform.origin
	if move_direction.length() > 0.5:

		look_at_direction(move_direction)
		var p_velocity = move_direction.normalized()
		var curr_speed = SPEED

		# apply jump
		if move_direction.y > MIN_HEIGHT_TO_JUMP: 
			curr_speed = clamp(abs(move_direction.y)*2.3, 3, INF)
			is_jumping = true

		# fall or move to the edge before falling
		elif move_direction.y < -MIN_HEIGHT_TO_JUMP:
			if Utils.vector_distance_without_y(path_stack.front(), global_transform.origin) <= 0.2:
				gravity += Vector3.DOWN*delta*GRAVITY_STRENGTH
				p_velocity = (path_stack.front()-global_transform.origin).normalized()+gravity
			else:
				p_velocity = Utils.vector_remove_y(move_direction).normalized()

		set_velocity(p_velocity*curr_speed)
		set_up_direction(Vector3.UP)
		move_and_slide()
		var _v = p_velocity
		if global_transform.origin.distance_to(path_stack.front()) >= 0.2: return

	path_stack.pop_front()
	move_direction = null
	is_jumping = false
	gravity = Vector3.ZERO
	can_move = path_stack.size() > 0



func adjust_to_center():
	move_direction = get_tile().global_transform.origin-global_transform.origin
	set_velocity(move_direction*SPEED*4)
	set_up_direction(Vector3.UP)
	move_and_slide()
	var _v = velocity


func start_animator():
	if move_direction == null : animator.travel("IDLE")
	elif is_jumping: animator.travel("JUMP")


func apply_movement(delta):
	if !path_stack.is_empty(): follow_the_path(delta)
	else: adjust_to_center()


func do_wait():
	can_move = false
	can_attack = false


func do_attack(a_pawn, delta):
	look_at_direction(a_pawn.global_transform.origin-global_transform.origin)
	if can_attack and wait_delay > MIN_TIME_FOR_ATTACK / 4.0: 
		a_pawn.curr_health = clamp(a_pawn.curr_health-attack_power, 0, INF)
		can_attack = false
	if wait_delay < MIN_TIME_FOR_ATTACK:
		wait_delay += delta
		return false
	wait_delay = 0
	return true


func reset():
	can_move = true
	can_attack = true	


func can_act():
	return (can_move or can_attack) and curr_health > 0


func _load_stats():
	move_radious = Utils.get_pawn_move_radious(pawn_class)
	jump_height = Utils.get_pawn_jump_height(pawn_class)
	attack_radious = Utils.get_pawn_attack_radious(pawn_class)
	attack_power = Utils.get_pawn_attack_power(pawn_class)
	max_health = Utils.get_pawn_health(pawn_class)
	curr_health = max_health


func _load_animator_sprite():
	animator = $Character/AnimationTree.get("parameters/playback")
	animator.start("IDLE")
	$Character/AnimationTree.active = true
	$Character.texture = Utils.get_pawn_sprite(pawn_class)
	$CharacterStats/NameLabel.text = pawn_name+", the "+String(Utils.PAWN_CLASSES.keys()[pawn_class])


func tint_when_not_able_to_act():
	$Character.modulate = Color(.7, .7, .7) if !can_act() else Color(1,1,1)


func display_pawn_stats(v):
	$CharacterStats.visible = v


func _ready():
	_load_stats()
	_load_animator_sprite()
	display_pawn_stats(false)


func _process(delta):
	rotate_pawn_sprite()
	apply_movement(delta)
	start_animator()
	tint_when_not_able_to_act()
	$CharacterStats/HealthLabel.text = str(curr_health)+"/"+str(max_health)
	