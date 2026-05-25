extends Node

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if global.loading_scene == true:
		var scene_trs = load("res://Scenes/"+global.scene_name+".tscn")
		var scene = scene_trs.instantiate()
		add_child(scene)
		global.loading_scene = false
		
