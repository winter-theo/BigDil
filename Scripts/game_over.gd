extends Control

var ButtonInput = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	if ButtonInput == 2 && Input.is_action_just_pressed("ui_left"):
		ButtonInput = 1
		$TextureRect/ColorRect/Label.add_theme_color_override("font_color", Color("88c070"))
		$TextureRect/ColorRect2/Label.add_theme_color_override("font_color", Color("e0f8d0"))
	if ButtonInput == 1 && Input.is_action_just_pressed("ui_right"):
		ButtonInput = 2
		$TextureRect/ColorRect/Label.add_theme_color_override("font_color", Color("e0f8d0"))
		$TextureRect/ColorRect2/Label.add_theme_color_override("font_color", Color("88c070"))
		
	if ButtonInput == 1 && Input.is_action_just_pressed("ui_accept"):
		global.unloading_scene = false
		global.loading_scene = true
		global.can_be_damaged = true
		global.scene_name = "overworld"
		global.life_bar = 6
		global.Inventory = []
		global.quantity = [0, 0]
		global.has_been_obtained = [false, false]
		global.LastPicked = true
		global.CurrentSlot = 0
		self.queue_free()
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_ready()
