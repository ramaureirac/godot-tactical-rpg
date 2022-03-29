extends Control


var layout_xbox = load("res://assets/sprites/labels/controls-ui-xbox.png")
var layout_pc = load("res://assets/sprites/labels/controls-ui.png")
var is_joystick = false


func _process(var _delta):
	if is_joystick: $HBox/VBox/ControllerHints.texture = layout_xbox
	else: $HBox/VBox/ControllerHints.texture = layout_pc

func get_act(var action=null):
	if !action: return $HBox/Actions
	return $HBox/Actions.get_node(action)


func is_mouse_hover_button():
	if $HBox/Actions.visible:
		for action in $HBox/Actions.get_children():
			if action.get_global_rect().has_point(get_viewport().get_mouse_position()): 
				return true
	return false


func set_visibility_of_actions_menu(var v, var p):
	if !$HBox/Actions.visible: $HBox/Actions/Move.grab_focus()
	$HBox/Actions.visible = v
	if !p : return
	$HBox/Actions/Move.disabled = !p.can_move
	$HBox/Actions/Attack.disabled = !p.can_attack
