extends Control

var HasPlayed = false


# Called when the node enters the scene tree for the first time.
func secondarysplash():
	$AnimationPlayer.play("title_screen_fade")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if HasPlayed == false:
		secondarysplash()
		HasPlayed = true


func _on_animation_player_animation_finished(title_screen_fade):
	global.scene_name = "main_menu"
	global.loading_scene = true
	self.queue_free()
