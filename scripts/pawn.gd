extends KinematicBody

const SPEED = 1400.0

# attributes
export var pawn_name = "Jhon Doe"
export var distance = 5
export var jump_height = 3
export var max_health = 150
export var attack_power = 40
export var attack_radious = 1

var can_move = true
var can_attack = true
var path_stack = []
var curr_health = self.max_health

func reset():
	self.can_move = true
	self.can_attack = true
	self.path_stack.clear()

func wait():
	self.can_move = false
	self.can_attack = false

func can_act():
	return self.can_move or self.can_attack

func move(delta):
	"""
	move this pawn acording to its 'path_stack'. it will return 'true' once
	the full path has been covered else it will return 'false'
	"""
	if self.path_stack.empty(): return false
	var t = path_stack.front()
	var d = (t.get_translation() - self.get_translation())
	var v = d.normalized()*SPEED*delta
	v = self.move_and_slide(v, Vector3.UP)
	if d.length() <= 0.4:
		self.set_translation(t.get_translation())
		self.path_stack.pop_front()
	return self.path_stack.empty()

func attack(var pawn):
	if !pawn or !pawn.get_tile().attackable: return
	pawn.queue_free()

func get_tile():
	return $RayCast.get_collider()


