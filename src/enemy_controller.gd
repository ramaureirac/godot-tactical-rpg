extends Spatial

var stage = 0
var curr_pawn
var attackable_pawn

var tactics_camera = null
var arena = null
var targets = null


func can_act():
	for p in get_children():
		if p.can_act() : return true
	return stage > 0


func reset(): 
	for p in get_children(): p.reset()


func configure(var my_arena, var my_camera):
	tactics_camera = my_camera
	arena = my_arena
	curr_pawn = get_children().front()


func choose_pawn():
	arena.reset()
	for p in get_children():
		if p.can_act(): curr_pawn = p 
	stage = 1


func chase_nearest_enemy():
	arena.reset()
	arena.link_tiles(curr_pawn.get_tile(), curr_pawn.jump_height, get_children())
	arena.mark_reachable_tiles(curr_pawn.get_tile(), curr_pawn.move_radious)
	var to = arena.get_nearest_neighbor_to_pawn(curr_pawn, targets.get_children())
	curr_pawn.path_stack = arena.generate_path_stack(to)
	tactics_camera.target = to
	stage = 2


func move_pawn():
	if curr_pawn.path_stack.empty(): 
		stage = 3


func choose_pawn_to_attack():
	arena.reset()
	arena.link_tiles(curr_pawn.get_tile(), curr_pawn.attack_radious)
	arena.mark_attackable_tiles(curr_pawn.get_tile(), curr_pawn.attack_radious)
	attackable_pawn = arena.get_weakest_pawn_to_attack(targets.get_children())
	if attackable_pawn: 
		attackable_pawn.display_pawn_stats(true)
		tactics_camera.target = attackable_pawn
	stage = 4 


func attack_pawn(var delta):
	if !attackable_pawn: curr_pawn.can_attack = false
	else:
		if !curr_pawn.do_attack(attackable_pawn, delta): return
		attackable_pawn.display_pawn_stats(false)
		tactics_camera.target = curr_pawn
	attackable_pawn = null
	stage = 0


func act(var delta):
	targets = get_parent().get_node("Player")
	match stage:
		0: choose_pawn()
		1: chase_nearest_enemy()
		2: move_pawn()
		3: choose_pawn_to_attack()
		4: attack_pawn(delta)
