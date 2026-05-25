extends Control


var state1 = load("res://Assets/UI/life_1.png")
var state2 = load("res://Assets/UI/life_2.png")
var state3 = load("res://Assets/UI/life_4.png")
var state4 = load("res://Assets/UI/life_3.png")
var state5 = load("res://Assets/UI/life_5.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	if global.life_bar >= 4:
		if global.life_bar == 6:
			$ColorRect/TextureRect3.set_texture(state1)
		if global.life_bar == 5:
			$ColorRect/TextureRect3.set_texture(state4)
		if global.life_bar == 4:
			$ColorRect/TextureRect3.set_texture(state5)
	if global.life_bar >= 2 && global.life_bar <= 4:
		$ColorRect/TextureRect3.set_texture(state5)
		if global.life_bar == 4:
			$ColorRect/TextureRect2.set_texture(state1)
		if global.life_bar == 3:
			$ColorRect/TextureRect2.set_texture(state4)
		if global.life_bar == 2:
			$ColorRect/TextureRect2.set_texture(state5)
	if global.life_bar >= 0 && global.life_bar <= 2:
		$ColorRect/TextureRect2.set_texture(state5)
		if global.life_bar == 1:
			$ColorRect/TextureRect.set_texture(state4)
	if global.life_bar <= 0:
		$ColorRect/TextureRect.set_texture(state5)
		global.loading_scene = true
		global.unloading_scene = true
		global.scene_name = "game_over"
			#Lancement game over



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_ready()
	if global.can_be_damaged == true && global.has_taken_damage == true:
		global.life_bar = global.life_bar - global.damageAmount
		$AudioStreamPlayer.playing = true
		global.can_be_damaged = false
		global.has_taken_damage = false
		$Timer.start()
	$Label.set_text(str(global.TurnCounter))

			
			



func _on_timer_timeout():
	global.can_be_damaged = true
