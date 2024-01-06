extends Node3D
class_name TacticsLevel

var t_from = null
var t_to = null
var curr_t = null
var player : TacticsPlayerController = null
var enemy : TacticsEnemyController
var arena : TacticsArena
var camera : TacticsCamera
var ui_control : TacticsPlayerControllerUI


func _ready():
	player = $Player
	enemy = $Enemy
	arena = $Arena
	camera = $TacticsCamera
	ui_control = $PlayerControllerUI
	player.configure(arena, camera, ui_control)
	enemy.configure(arena, camera, ui_control)


func turn_handler(delta):
	if player.can_act() : player.act(delta)
	elif enemy.can_act() : enemy.act(delta)
	else:
		player.reset()
		enemy.reset()


func _physics_process(delta):
	turn_handler(delta)

