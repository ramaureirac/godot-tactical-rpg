extends KinematicBody

const Utils = preload("res://src/utils.gd")

const SPEED = 7
const ANIMATION_FRAMES = 1
const MIN_HEIGHT_TO_JUMP = 1
const GRAVITY_STRENGTH = 7
const MIN_TIME_FOR_ATTACK = 1

# class
export (Utils.PAWN_CLASSES) var pawn_class
export (Utils.PAWN_STRATEGIES) var pawn_strategy
export (String) var pawn_name = "Trooper"

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
export (int) var curr_frame = 0
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
	var camera_forward = -get_viewport().get_camera().global_transform.basis.z
	var dot = global_transform.basis.z.dot(camera_forward)
	$Character.flip_h = global_transform.basis.x.dot(camera_forward) > 0
	if dot < -0.306: $Character.frame = curr_frame
	elif dot > 0.306: $Character.frame = curr_frame + 1 * ANIMATION_FRAMES


func look_at_direction(var dir):
	var fixed_dir = dir*(Vector3(1,0,0) if abs(dir.x) > abs(dir.z) else Vector3(0,0,1))
	var angle = Vector3.FORWARD.signed_angle_to(fixed_dir.normalized(), Vector3.UP)+PI
	set_rotation(Vector3.UP*angle)


func follow_the_path(var delta):
	if !can_move : return
	if !move_direction : move_direction = path_stack.front()-global_transform.origin
	if move_direction.length() > 0.5:

		look_at_direction(move_direction)
		var velocity = move_direction.normalized()
		var curr_speed = SPEED

		# apply jump
		if move_direction.y > MIN_HEIGHT_TO_JUMP: 
			curr_speed = clamp(abs(move_direction.y)*2.3, 3, INF)
			is_jumping = true
		
		# fall or move to the edge before falling
		elif move_direction.y < -MIN_HEIGHT_TO_JUMP:
			if Utils.vector_distance_without_y(path_stack.front(), global_transform.origin) <= 0.2:
				gravity += Vector3.DOWN*delta*GRAVITY_STRENGTH
				velocity = (path_stack.front()-global_transform.origin).normalized()+gravity
			else:
				velocity = Utils.vector_remove_y(move_direction).normalized()
		
		var _v = move_and_slide(velocity*curr_speed, Vector3.UP)
		if global_transform.origin.distance_to(path_stack.front()) >= 0.2: return
	
	path_stack.pop_front()
	move_direction = null
	is_jumping = false
	gravity = Vector3.ZERO
	can_move = path_stack.size() > 0



func adjust_to_center():
	move_direction = get_tile().global_transform.origin-global_transform.origin
	var _v = move_and_slide(move_direction*SPEED*4, Vector3.UP)


func start_animator():
	if !move_direction : animator.travel("IDLE")
	elif is_jumping: animator.travel("JUMP")


func apply_movement(var delta):
	if !path_stack.empty(): follow_the_path(delta)
	else: adjust_to_center()


func do_wait():
	can_move = false
	can_attack = false


func do_attack(var a_pawn, var delta):
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
	$CharacterStats/Name/Viewport/Label.text = pawn_name+\
		", the "+String(Utils.PAWN_CLASSES.keys()[pawn_class])


func tint_when_not_able_to_act():
	$Character.modulate = Color(.7, .7, .7) if !can_act() else Color(1,1,1)


func display_pawn_stats(var v):
	$CharacterStats.visible = v


func _ready():
	_load_stats()
	_load_animator_sprite()
	display_pawn_stats(false)


func _process(var delta):
	rotate_pawn_sprite()
	apply_movement(delta)
	start_animator()
	tint_when_not_able_to_act()
	$CharacterStats/Health/Viewport/Label.text = String(curr_health)+"/"+String(max_health)
