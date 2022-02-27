extends Control

var _err = null

func _ready():
	self._err = $hbox/vbox/buttons/btn_move.connect("pressed", self, "_player_move_pawn")
	self._err = $hbox/vbox/buttons/btn_cancel.connect("pressed", self, "_ui_cancel")

func _player_move_pawn():
	Input.action_press("player_move_pawn")

func _ui_cancel():
	Input.action_press("ui_cancel")

func update_buttons(var pawn, var go_back):
	if !pawn:
		self._reset_buttons()
	else:
		$hbox/vbox/lbl_name.text = pawn.pawn_name
		$hbox/vbox/buttons/btn_move.disabled = !pawn.can_move
		$hbox/vbox/buttons/btn_attack.disabled = !pawn.can_attack
		$hbox/vbox/buttons/btn_cancel.disabled = !go_back

func _reset_buttons():
	for b in $hbox/vbox/buttons.get_children():
		b.disabled = true
	$hbox/vbox/lbl_name.text = "TACTICS MENU"
