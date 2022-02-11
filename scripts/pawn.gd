extends KinematicBody

const SPEED = 1200.0

var can_move = true
var can_attack = false
var path_stack = []

export var distance = 5

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

func get_tile():
	return $RayCast.get_collider()


