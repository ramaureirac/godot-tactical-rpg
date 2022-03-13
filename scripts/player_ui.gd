extends Control

var _err = null
var buttons = null

func _ready():
	self._err = $hbox/vbox/buttons/btn_move.connect("pressed", self, "_player_move_pawn")
	self._err = $hbox/vbox/buttons/btn_attack.connect("pressed", self, "_player_attack_pawn")
	#self._err = $hbox/vbox/buttons/btn_cancel.connect("pressed", self, "_ui_cancel")
	self._err = $hbox/vbox/buttons/btn_wait.connect("pressed", self, "_player_wait_pawn")
	self._err = $hbox/vbox/buttons/btn_cancel.connect("pressed", self, "_ui_cancel")

func _player_move_pawn():
	Input.action_press("player_move_pawn")

func _player_attack_pawn():
	Input.action_press("player_attack_pawn")

func _player_wait_pawn():
	Input.action_press("player_wait_pawn")

func _ui_cancel():
	Input.action_press("ui_cancel")

func display_pawn_stats(var pawn):
	if !pawn:
		$hbox/vbox_stats.visible = false
		return
	$hbox/vbox_stats.visible = true
	$hbox/vbox_stats/hbox/vbox/hbox_name/lbl_name_value.text = pawn.pawn_name
	$hbox/vbox_stats/hbox/vbox/hbox_health/lbl_curr_health_value.text = String(pawn.curr_health)
	$hbox/vbox_stats/hbox/vbox/hbox_health/lbl_max_health_value.text = String(pawn.max_health)
	$hbox/vbox_stats/hbox/vbox/hbox_attack/lbl_attack_value.text = String(pawn.attack_power)
	$hbox/vbox_stats/hbox/vbox/hbox_walk/lbl_walk_value.text = String(pawn.distance)
	$hbox/vbox_stats/hbox/vbox/hbox_attack_r/lbl_attack_r_value.text = String(pawn.attack_radious)

func update_buttons(var pawn, var stage):
	self.display_pawn_stats(pawn)
	if !pawn: 
		for b in $hbox/vbox/buttons.get_children():
			b.disabled = true
		return
	var can_go_back = stage > 0
	var lock_cmds = stage > 1
	$hbox/vbox/buttons/btn_move.disabled = !pawn.can_move or lock_cmds
	$hbox/vbox/buttons/btn_attack.disabled = !pawn.can_attack or lock_cmds
	$hbox/vbox/buttons/btn_wait.disabled = false or lock_cmds
	$hbox/vbox/buttons/btn_cancel.disabled = !can_go_back
