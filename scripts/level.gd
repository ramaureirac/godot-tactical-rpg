extends Spatial

"""
TODO
attack and health
"""

var players_turn = true
var player = null
var enemy = null
var arena = null

func _configure():
	self.arena = $Arena
	self.player = $Allies
	self.enemy = $Enemies
	self.player.configure($TCamera, $Arena, $Enemies.get_children(), $PlayerUI)
	self.enemy.configure($TCamera, $Arena, $Allies.get_children(), $PlayerUI)

func _switch_turns():
	if self.players_turn:
		for a in self.player.pawns: if a.can_act(): return
	else:
		for e in self.enemy.pawns: if e.can_act(): return
	self._reset_turns()

func _reset_turns():
	self.players_turn = !self.players_turn
	for p in (self.player.pawns + self.enemy.pawns): p.reset()

func _turn_handler(var delta):
	if self.player.pawns.empty() or self.enemy.pawns.empty(): return
	if self.players_turn: self.player.act(delta)
	else: self.enemy.act(delta)

func _process(var delta):
	self._configure()
	self._turn_handler(delta)
	self._switch_turns()
