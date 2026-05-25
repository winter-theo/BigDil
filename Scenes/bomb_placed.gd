extends StaticBody2D

var FirstRun = true
var InRange = false
var EnemyInRange = false
var Buffer = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	if FirstRun == true:
		self.position = global.Billpos
		self.position.x = self.position.x - 8
		Buffer = global.TurnCounter
		global.bomb2 = true
		FirstRun = false
	if global.TurnCounter == Buffer + 3:
		if InRange == true:
			global.has_taken_damage = true
			global.can_be_damaged = true
			global.damageAmount = 3
		if EnemyInRange == true:
			global.enemy_has_been_damaged = true
			global.enemy_can_be_damaged = true
			global.damageAmount = 3
			
		self.queue_free()

		
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if global.is_frozen == false:
		_ready()


func _on_area_2d_body_entered(body):
	if body.has_method("player"):
		InRange = true
	if body.has_method("enemy"):
		EnemyInRange = true


func _on_area_2d_body_exited(body):
	if body.has_method("player"):
		InRange = false
	if body.has_method("enemy"):
		EnemyInRange = false
