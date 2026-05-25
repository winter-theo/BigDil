extends CharacterBody2D

@onready var movement_validation: RayCast2D = $RayCast2D
@onready var movement_tween: Node = $MovementTween
@export var grid_size: int = 16

var direction : Vector2 = Vector2.ZERO
var can_move : bool = true
var last_dir = ""
var flip = false
var in_range = false
var buffer = true

func _process(delta : float) -> void:
	if Input.is_action_pressed("ui_left"):
		direction.x = -1
		playAnim(direction)
		last_dir = "idle_side"
		flip = false
	elif Input.is_action_pressed("ui_right"):
		direction.x = 1
		playAnim(direction)
		last_dir = "idle_side"
		flip = true
	elif Input.is_action_pressed("ui_down"):
		direction.y = 1
		playAnim(direction)
		last_dir = "idle_down"
		flip = false
	elif Input.is_action_pressed("ui_up"):
		direction.y = -1
		playAnim(direction)
		last_dir = "idle_up"
		flip = false
	else:
		direction = Vector2.ZERO
		$AnimatedSprite2D.flip_h = flip
		$AnimatedSprite2D.play(last_dir)
		
func _physics_process(delta : float) -> void:
	if movement_validation.validate_movement(direction * grid_size) and can_move and direction != Vector2.ZERO:
		can_move = false
		movement_tween.run(self, global_position + direction * grid_size)
		movement_tween.tween.finished.connect(on_movement_tween_finished)
	if global.can_be_damaged == false:
		self.modulate.a = 0.5
	elif global.can_be_damaged == true:
		self.modulate.a = 1.0
	
	if in_range == true && global.TurnCounter % 2 != 0 && buffer == true:
		global.has_taken_damage = true
		global.can_be_damaged = true
		global.damageAmount = 1
		buffer = false
		global.is_frozen = true
		

func on_movement_tween_finished() -> void:
	can_move = true
	global.Billpos = self.position
	global.TurnCounter = global.TurnCounter + 1
	buffer = true
	
		
		
	
	## Animations
func playAnim(dir):
		if dir.x == 1:
			$AnimatedSprite2D.flip_h = true
			$AnimatedSprite2D.play("walk_side")
		if dir.x == -1:
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("walk_side")
		if dir.y == -1:
			$AnimatedSprite2D.play("walk_up")
		if dir.y == 1:
			$AnimatedSprite2D.play("walk_down")
		if dir.y == 0 && dir.x == 0:
			$AnimatedSprite2D.stop()
		
func player():
	pass
	







func _on_area_2d_body_entered(body):
	if body.has_method("enemy") && global.can_be_damaged == true:
		in_range = true


func _on_area_2d_body_exited(body):
		in_range = false
