extends Spatial

"""
TODO
attack and health
"""

var players_turn = true
var player = null
var enemy = null
var arena = null

func _ready():
	self.arena = $Arena
	self.player = $Allies
	self.enemy = $Enemies
	self.player.configure($TCamera, $Arena, $PlayerUI)
	self.enemy.configure($TCamera, $Arena)

func _switch_turn():
	if self.players_turn:
		for a in self.player.pawns:
			if a.can_act(): 
				self.players_turn = true
				return
		self.players_turn = false
	else:
		for e in self.enemy.pawns:
			if e.can_act(): 
				self.players_turn = false
				return
		self._reset_turns()

func _reset_turns():
	self.players_turn = !self.players_turn
	for p in (self.player.pawns + self.enemy.pawns):
		p.can_move = true

func _move_pawn(var delta):
	var curr_pawn = self.player.curr_pawn
	if !self.players_turn:
		curr_pawn = self.enemy.curr_pawn
	if curr_pawn != null and curr_pawn.move(delta):
		curr_pawn.can_move = false
		self.player.curr_pawn = null
		self.enemy.curr_pawn = null
		self.arena.reset()

func _turn_handler(var delta):
	if self.players_turn: self.player.act(delta)
	else: self.enemy.set_destination(self.player.pawns)

func _process(var delta):
	self._turn_handler(delta)
	if !players_turn: self._move_pawn(delta)
	self.player.camera_rotation()
	self._switch_turn()
