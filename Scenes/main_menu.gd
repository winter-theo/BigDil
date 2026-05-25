extends Control

var ButtonInput = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	if ButtonInput == 2 && Input.is_action_just_pressed("ui_up"):
		ButtonInput = 1
		$TextureRect/ColorRect.set_color("808080")
		$TextureRect/ColorRect2.set_color("ffffff")
	if ButtonInput == 1 && Input.is_action_just_pressed("ui_down"):
		ButtonInput = 2
		$TextureRect/ColorRect.set_color("ffffff")
		$TextureRect/ColorRect2.set_color("808080")
		
	if ButtonInput == 1 && Input.is_action_just_pressed("ui_accept"):
		global.loading_scene = true
		global.scene_name = "overworld"
		self.queue_free()
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_ready()
