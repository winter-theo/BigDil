extends CharacterBody2D

var HP = 3
var in_range = false
var enemy_can_be_damaged = true
var enemy_has_been_damaged = false
var detected = false
var Buffer = true

# Called when the node enters the scene tree for the first time.
func _ready():
	if enemy_can_be_damaged == true && enemy_has_been_damaged == true:
		HP = HP - global.damageAmount
		$AudioStreamPlayer.playing = true
		enemy_can_be_damaged = false
		enemy_has_been_damaged = false
		$Label.set_text("-3")
		$Timer.start()
		if HP <= 0:
			self.queue_free()
			
	if in_range == true && Input.is_action_just_pressed("ui_accept") && global.TurnCounter % 2 == 0 && Buffer == true:
		enemy_can_be_damaged = true
		enemy_has_been_damaged = true
		global.damageAmount = 1
		Buffer = false
	if global.is_frozen == true:
		Buffer = true
			

func enemy():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_ready()


func _on_timer_timeout():
	global.enemy_can_be_damaged = true


func _on_area_2d_body_entered(body):
	if body.has_method("player"):
		enemy_can_be_damaged = true
		in_range = true

	
		


func _on_area_2d_body_exited(body):
	if body.has_method("player"):
		enemy_can_be_damaged = false

