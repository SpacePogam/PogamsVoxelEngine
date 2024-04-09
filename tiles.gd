extends GridMap

var tilePos
var tilePos2
var playerPos
var emptyTile
signal giveTilePos
signal testforCol

func _on_player_get_tile(tipPos):
	tilePos2 = local_to_map(to_local(tipPos))
	if get_cell_item(tilePos2) != INVALID_CELL_ITEM:
		emptyTile = false
	else:
		emptyTile = true
	giveTilePos.emit(tilePos2,emptyTile)
	pass # Replace with function body.

func _on_player_place_tile(pos,face): # on right click
	tilePos = Vector3(local_to_map(to_local(pos))) # set position to tile that is interacted with
	print("Before moving: ",$checkTile/colshape.position, "TilePos: ",tilePos)
	$checkTile/colshape.position = tilePos + face + Vector3(0.5,0.5,0.5)
	print("After moving: ",$checkTile/colshape.position)
	if not $checkTile/colshape.position == playerPos:
		testforCol.emit(face,$checkTile/colshape.position) # emit signal to check for external collision
	pass # Replace with function body.

func _on_player_break_tile(pos):
	tilePos = Vector3(local_to_map(to_local(pos)))
	set_cell_item(tilePos,-1,0)
	pass # Replace with function body.

func _on_check_tile_place_the_bloody_tile(face,coll,cpos):
	if not coll:
		set_cell_item(cpos-Vector3(0.5,0.5,0.5),2,0)
	pass # Replace with function body.


func _on_player_give_pos(signalPlayerPos):
	playerPos = Vector3(local_to_map(to_local(signalPlayerPos)))
	print(playerPos)
	pass # Replace with function body.
