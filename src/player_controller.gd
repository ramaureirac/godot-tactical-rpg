extends Spatial

var curr_pawn = null
var attackable_pawn = null

# wait
var wait_time = 0

# controller status
var is_joystick = false

var arena = null
var tactics_camera = null

# stage control
var stage = 0

var ui_control


func configure(var my_arena, var my_camera, var my_control):
	arena = my_arena
	tactics_camera = my_camera
	ui_control = my_control
	tactics_camera.target = get_children().front()

	ui_control.get_act("Move").connect("pressed", self, "player_wants_to_move")
	ui_control.get_act("Wait").connect("pressed", self, "player_wants_to_wait")
	ui_control.get_act("Cancel").connect("pressed", self, "player_wants_to_cancel")
	ui_control.get_act("Attack").connect("pressed", self, "player_wants_to_attack")


func get_mouse_over_object(var lmask):
	if ui_control.is_mouse_hover_button(): return
	var camera = get_viewport().get_camera()
	var origin = get_viewport().get_mouse_position() if !is_joystick else get_viewport().size/2
	var from = camera.project_ray_origin(origin)
	var to = from + camera.project_ray_normal(origin)*1000000
	return get_world().direct_space_state.intersect_ray(from, to, [], lmask).get("collider")


func can_act():
	for pawn in get_children(): 
		if pawn.can_act(): return true 
	return stage > 0


func reset():
	for pawn in get_children(): 
		pawn.reset()


# --- user action inputs --- #
func player_wants_to_move(): stage = 2
func player_wants_to_cancel(): stage = 1 if stage > 1 else 0
func player_wants_to_wait(): 
	curr_pawn.do_wait()
	stage = 0
func player_wants_to_attack(): stage = 5


# --- aux stage funcs --- #
func _aux_select_pawn():
	var pawn = get_mouse_over_object(2)
	var tile = get_mouse_over_object(1) if !pawn else pawn.get_tile()
	arena.mark_hover_tile(tile)
	return pawn if pawn else tile.get_object_above() if tile else null

func _aux_select_tile():
	var pawn = get_mouse_over_object(2)
	var tile = get_mouse_over_object(1) if !pawn else pawn.get_tile()
	arena.mark_hover_tile(tile)
	return tile


# --- stages ---- #
func select_pawn():
	arena.reset()
	if curr_pawn: curr_pawn.display_pawn_stats(false)
	curr_pawn = _aux_select_pawn()
	if !curr_pawn : return
	curr_pawn.display_pawn_stats(true)
	if Input.is_action_just_pressed("ui_accept") and curr_pawn.can_act() and curr_pawn in get_children():
		tactics_camera.target = curr_pawn
		stage = 1

func display_available_actions_for_pawn():
	curr_pawn.display_pawn_stats(true)
	arena.reset()
	arena.mark_hover_tile(curr_pawn.get_tile())

func display_available_movements():
	arena.reset()
	if !curr_pawn: return
	tactics_camera.target = curr_pawn
	arena.link_tiles(curr_pawn.get_tile(), curr_pawn.jump_height, get_children())
	arena.mark_reachable_tiles(curr_pawn.get_tile(), curr_pawn.move_radious)
	stage = 3

func display_attackable_targets():
	arena.reset()
	if !curr_pawn: return
	tactics_camera.target = curr_pawn
	arena.link_tiles(curr_pawn.get_tile(), curr_pawn.attack_radious)
	arena.mark_attackable_tiles(curr_pawn.get_tile(), curr_pawn.attack_radious)
	stage = 6

func select_new_location():
	var tile = get_mouse_over_object(1)
	arena.mark_hover_tile(tile) 
	if Input.is_action_just_pressed("ui_accept"):
		if tile and tile.reachable:
			curr_pawn.path_stack = arena.generate_path_stack(tile)
			tactics_camera.target = tile
			stage = 4

func select_pawn_to_attack():
	curr_pawn.display_pawn_stats(true)
	if attackable_pawn: attackable_pawn.display_pawn_stats(false)
	var tile = _aux_select_tile()
	attackable_pawn = tile.get_object_above() if tile else null
	if attackable_pawn: attackable_pawn.display_pawn_stats(true)
	if Input.is_action_just_pressed("ui_accept") and tile and tile.attackable:
		tactics_camera.target = attackable_pawn
		stage = 7

func move_pawn():
	curr_pawn.display_pawn_stats(false)
	if curr_pawn.path_stack.empty(): 
		stage = 0 if !curr_pawn.can_act() else 1

func attack_pawn(var delta):
	if !attackable_pawn: curr_pawn.can_attack = false
	else:
		if !curr_pawn.do_attack(attackable_pawn, delta): return
		attackable_pawn.display_pawn_stats(false)
		tactics_camera.target = curr_pawn
	attackable_pawn = null
	stage = 0 if !curr_pawn.can_act() else 1

# --- camera --- #
func move_camera():
	var h = -Input.get_action_strength("camera_left")+Input.get_action_strength("camera_right")
	var v = Input.get_action_strength("camera_forward")-Input.get_action_strength("camera_backwards")
	tactics_camera.move_camera(h, v, is_joystick)

func camera_rotation():
	if Input.is_action_just_pressed("camera_rotate_left"): tactics_camera.y_rot -= 90
	if Input.is_action_just_pressed("camera_rotate_right"): tactics_camera.y_rot += 90


func act(var delta):
	move_camera()
	camera_rotation()
	ui_control.set_visibility_of_actions_menu(stage in [1,2,3,5,6], curr_pawn)
	match stage:
		0: select_pawn()
		1: display_available_actions_for_pawn()
		2: display_available_movements()
		3: select_new_location()
		4: move_pawn()
		5: display_attackable_targets()
		6: select_pawn_to_attack()
		7: attack_pawn(delta)

func _process(var _delta):
	Input.set_mouse_mode(is_joystick)

func _input(var event):
	is_joystick = event is InputEventJoypadButton or event is InputEventJoypadMotion
	ui_control.is_joystick = is_joystick
