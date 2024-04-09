extends Area3D

signal placeTheBloodyTile
var bodies = []

func _on_tiles_testfor_col(face,cpos): # received signal
	bodies = [has_overlapping_bodies(),get_overlapping_bodies()] # if bodies are overlapping, and which
	print("is overlapping: ",bodies[0],"  overlapping with: ",bodies[1]) # print :>
	placeTheBloodyTile.emit(face,bodies[0],cpos)
	bodies = []
	pass # Replace with function body.
