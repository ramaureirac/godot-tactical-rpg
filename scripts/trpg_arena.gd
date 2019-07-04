extends Spatial

# variables:
var camera = null
var tiles = []
var allies = []
var enemies = []
var turns_queue = []


# main functions:
func _process(_delta):
	self._process_camera()

func _physics_process(delta):
	self._process_tiles()
	self._process_pawns(delta)


#aux functions:
func _process_tiles():
	if tiles.empty():
		for tile in $TRPGTiles.get_children():
			tile.logic()
			self.tiles.append(tile)
		#print("Arena: ", self.tiles.size(), " tiles founded")
	else:
		for tile in self.tiles:
			tile.logic()

func _process_pawns(var delta):
	# init --
	if self.turns_queue.empty():
		if self.allies.empty():
			for ally in $TRPGAllies.get_children():
				ally.init(self)
				ally.logic()
				self.allies.push_back(ally)
				self.turns_queue.push_back(ally)
			#print("Area: ", self.allies.size(), " allies on the battlefield")
		if self.enemies.empty():
			for enemy in $TRPGEnemies.get_children():
				enemy.init(self)
				enemy.logic()
				self.enemies.push_back(enemy)
				self.turns_queue.push_back(enemy)
			#print("Area: ", self.enemies.size(), " enemies on the battlefield")
	# turn-based system --
	elif camera != null:
		for pawn in self.turns_queue:
			pawn.logic()
		var pawn = self.turns_queue.front()
		var tile = self.camera.logic(delta, pawn)
		if !pawn.act(delta, tile):
			self.turns_queue.push_back(self.turns_queue.pop_front())
			self._reset()

func _process_camera():
	if self.camera == null:
		self.camera = $TRPGCamera

func _reset():
	for tile in self.tiles:
		tile.reset()





