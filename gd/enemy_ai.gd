extends Spatial

"""
Script for handling enemy AI actions.
TODO:

Make more personalities for AI. At the momente we have:
1. Tank: chase the nearest ally

some ideas:
1. Support: follow a enemy
2. Coward: escape from ally
3. Flank: try to flank the allies
"""

var curr_pawn = null
var t_camera = null
var arena = null
var pawns = []


func configure(var my_camera, var my_arena):
    self.t_camera = my_camera
    self.arena = my_arena
    self.pawns = self.get_children()

func set_destination(var allies):
    if self.curr_pawn: return
    self.curr_pawn = self.pawns.front()
    var t = self.curr_pawn.get_tile()
    var d = self.curr_pawn.distance
    self.arena.mark_available_movements(t, d)
    var nt = self._chase_nearest_ally(allies)
    self.curr_pawn.path_stack = self.arena.gen_path(nt)
    self.t_camera.set_target(nt)
    self.pawns.push_back(self.pawns.pop_front())
    return self.curr_pawn

func _chase_nearest_ally(var allies):
    var tiles = []
    var e_t = self.curr_pawn.get_tile()
    for a in allies:
        var a_t = a.get_tile()
        tiles.append(self.arena.find_nearest_tile_neighbor(e_t, a_t))
    var tile = tiles.front()
    for t in tiles:
        if t.weight < tile.weight:
            tile = t
    return self.arena.find_nearest_tile_reachable(tile)