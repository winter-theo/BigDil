extends Node2D

# Called when the node enters the scene tree for the first time.
func time_management():
	print(global.TurnCounter)
		
		
		# if Enemy has moved and ended turn = global.has_moved = false
func damageManager():
	#if Enemy dans range de joueur et can be danage = true, -1
	# faire l'inverse dans le script enemy
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if global.unloading_scene == true:
		self.queue_free() 
	time_management()
