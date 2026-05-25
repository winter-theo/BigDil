extends Control

# 0 = BOMBS 1 = SCREW
var ActiveSlot = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if global.has_been_obtained[global.CurrentSlot] == true && global.LastPicked == true:
		$TextureRect2.set_texture(global.itemSprite[global.CurrentSlot])
		$TextureRect2/Label.set_text("x"+str(global.quantity[global.CurrentSlot]))
		
	if global.quantity[global.CurrentSlot] == 0 && global.has_been_obtained[global.CurrentSlot] == true:
		global.has_been_obtained[global.CurrentSlot] = false
		for i in 2:
			if i >= global.quantity.size():
				break
			if global.quantity[i] > 0:
				if i == global.CurrentSlot:
					i = i + 1
				global.CurrentSlot = i 
				$TextureRect2.set_texture(global.itemSprite[global.CurrentSlot])
				$TextureRect2/Label.set_text("x"+str(global.quantity[global.CurrentSlot]))
				break
			
			
					
				
			

		
	global.LastPicked = false
	

		
	
		
	
		
	if Input.is_action_just_pressed("select"):
		var FirstCheck = true
		for i in 2:
			if i + 1 >= global.quantity.size():
				break
			if global.quantity[i] > 0:
				if i == global.CurrentSlot:
					i = i + 1
				global.CurrentSlot = i 
				$TextureRect2.set_texture(global.itemSprite[global.CurrentSlot])
				$TextureRect2/Label.set_text("x"+str(global.quantity[global.CurrentSlot]))
				break
			
		
		
	if global.CurrentSlot == 0 && global.quantity[0] >= 1 && Input.is_action_pressed("ui_cancel"):
		global.loading_scene = true
		global.scene_name = "bomb_placed"
		global.quantity[0] -= 1
		$TextureRect2/Label.set_text("x"+str(global.quantity[0]))
		global.TurnCounter = global.TurnCounter + 1
				
		
		
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_ready()
