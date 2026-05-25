extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body.has_method("player"):
		global.CurrentSlot = 0
		global.has_been_obtained[0] = true
		global.quantity[0] = global.quantity[0] + 1
		global.LastPicked = true
		self.queue_free()
		
		



func _on_body_exited(body):
	pass # Replace with function body.
