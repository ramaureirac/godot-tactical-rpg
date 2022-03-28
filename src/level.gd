extends Spatial

var t_from = null
var t_to = null
var curr_t = null


func _ready():
	$Player.configure($Arena, $TacticsCamera, $PlayerControllerUI)
	$Enemy.configure($Arena, $TacticsCamera)


func turn_handler(var delta):
	if $Player.can_act() : $Player.act(delta)
	elif $Enemy.can_act() : $Enemy.act(delta)
	else:
		$Player.reset()
		$Enemy.reset()


func _physics_process(var delta):
	turn_handler(delta)

