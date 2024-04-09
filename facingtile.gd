extends GridMap

var selected: Vector3

func _on_tiles_give_tile_pos(tilePos,emptyTile):
	clear()
	if not emptyTile:
		set_cell_item(tilePos,0,0)
	pass
