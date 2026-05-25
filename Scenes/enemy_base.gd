class_name EnemyBase
extends CharacterBody2D

# ============================================================================
# EnemyBase
# ----------------------------------------------------------------------------
# Classe de base pour tous les ennemis du jeu. Chaque ennemi spécifique
# (cafard, rat, grenouille, etc.) hérite de cette classe et override
# take_turn() pour son comportement propre.
#
# Le TurnManager appelle take_turn() quand c'est au tour de l'ennemi de jouer.
# L'ennemi DOIT, en fin d'action, émettre le signal turn_finished
# (directement via end_turn() pour les actions instantanées, ou via le tween
# de mouvement pour les déplacements animés).
# ============================================================================

signal turn_finished

@export var max_hp: int = 1
@export var attack_damage: int = 1
@export var detection_range: int = 5   # en tiles, distance Manhattan
@export var tile_size: int = 16

# Convention d'animation : si l'ennemi a un AnimatedSprite2D, il doit posséder
# 3 animations nommées "walk_down", "walk_side", "walk_up" (avec loop). Le
# flip_h gère gauche/droite.
const ANIM_DOWN := "walk_down"
const ANIM_SIDE := "walk_side"
const ANIM_UP := "walk_up"

var hp: int
var is_dead: bool = false
var _damage_cooldown: bool = false
var _cached_player: Node = null

# Dernière direction de déplacement (utilisée pour orienter le sprite à
# l'arrêt). Par défaut, l'ennemi regarde vers le bas.
var _facing: Vector2 = Vector2.DOWN

@onready var movement_tween = $MovementTween
@onready var raycast = $RayCast2D
@onready var damage_sound = get_node_or_null("AudioStreamPlayer")
@onready var damage_label = get_node_or_null("Label")
@onready var damage_timer = get_node_or_null("Timer")
@onready var animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")


func _ready() -> void:
	hp = max_hp
	if damage_timer:
		damage_timer.timeout.connect(_on_damage_timer_timeout)
	if damage_label:
		damage_label.text = ""
	# Lance l'anim idle (face) par défaut.
	_play_facing_animation()


# Marqueur pour la compatibilité avec body.has_method("enemy") dans le code
# existant (bomb_placed.gd, player.gd legacy).
func enemy() -> void:
	pass


# ----------------------------------------------------------------------------
# Cycle de tour
# ----------------------------------------------------------------------------
# À override dans les sous-classes. Le comportement par défaut est de passer
# son tour.
func take_turn() -> void:
	end_turn()


func end_turn() -> void:
	turn_finished.emit()


# ----------------------------------------------------------------------------
# Mouvement à la grille
# ----------------------------------------------------------------------------
# Tente de bouger d'une tile dans la direction donnée. Retourne true si le
# mouvement est lancé (le tween appellera end_turn quand il finit), false si
# bloqué (l'appelant doit gérer la suite).
func attempt_move(direction: Vector2) -> bool:
	if direction == Vector2.ZERO:
		return false
	if not _can_move_to(direction):
		return false
	_set_facing(direction)
	movement_tween.run(self, global_position + direction * tile_size)
	movement_tween.tween.finished.connect(end_turn, CONNECT_ONE_SHOT)
	return true


func _can_move_to(direction: Vector2) -> bool:
	if raycast == null:
		return true
	return raycast.validate_movement(direction * tile_size)


# ----------------------------------------------------------------------------
# Animation directionnelle
# ----------------------------------------------------------------------------
# Met à jour _facing et joue l'animation correspondante.
func _set_facing(direction: Vector2) -> void:
	_facing = direction
	_play_facing_animation()


# Lance l'animation qui correspond à _facing. Le flip_h gère gauche/droite.
# Si l'ennemi n'a pas d'AnimatedSprite2D, ne fait rien (compat sprite statique).
func _play_facing_animation() -> void:
	if animated_sprite == null:
		return
	# NOTE : convention sprite source = regarde à droite. Donc flip_h=true pour la gauche.
	if _facing.x > 0:
		animated_sprite.flip_h = false
		_play_if_exists(ANIM_SIDE)
	elif _facing.x < 0:
		animated_sprite.flip_h = true
		_play_if_exists(ANIM_SIDE)
	elif _facing.y < 0:
		animated_sprite.flip_h = false
		_play_if_exists(ANIM_UP)
	else:
		animated_sprite.flip_h = false
		_play_if_exists(ANIM_DOWN)


func _play_if_exists(anim_name: String) -> void:
	if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation(anim_name):
		animated_sprite.play(anim_name)


# ----------------------------------------------------------------------------
# Localisation du joueur
# ----------------------------------------------------------------------------
func get_player() -> Node:
	if _cached_player == null or not is_instance_valid(_cached_player):
		_cached_player = _find_bill(get_tree().current_scene)
	return _cached_player


func _find_bill(node: Node) -> Node:
	if node == null:
		return null
	if node.name == "Bill":
		return node
	for child in node.get_children():
		var r = _find_bill(child)
		if r != null:
			return r
	return null


# Vecteur en tiles du cafard vers le joueur (ex: (-2, 1) = joueur 2 tiles à
# gauche et 1 tile en bas).
func player_vector() -> Vector2:
	var p = get_player()
	if p == null:
		return Vector2.ZERO
	return (p.global_position - global_position) / tile_size


func distance_to_player_tiles() -> int:
	var v = player_vector()
	return int(abs(v.x) + abs(v.y))


# 4-connecté : adjacent UNIQUEMENT en haut/bas/gauche/droite (pas diagonales).
func is_adjacent_to_player() -> bool:
	var v = player_vector()
	return (abs(v.x) + abs(v.y)) == 1


# ----------------------------------------------------------------------------
# Pathfinding greedy
# ----------------------------------------------------------------------------
# Avance d'1 tile vers le joueur, en privilégiant l'axe avec la plus grande
# différence. Si bloqué, tente l'axe perpendiculaire (contournement).
# Retourne true si un mouvement est lancé.
func smart_move_toward_player() -> bool:
	var v = player_vector()
	var primary: Vector2 = Vector2.ZERO
	var secondary: Vector2 = Vector2.ZERO

	if abs(v.x) >= abs(v.y):
		if v.x != 0:
			primary = Vector2(sign(v.x), 0)
		if v.y != 0:
			secondary = Vector2(0, sign(v.y))
	else:
		if v.y != 0:
			primary = Vector2(0, sign(v.y))
		if v.x != 0:
			secondary = Vector2(sign(v.x), 0)

	if primary != Vector2.ZERO and attempt_move(primary):
		return true
	if secondary != Vector2.ZERO and attempt_move(secondary):
		return true
	return false


# Errance aléatoire : tente une direction au hasard parmi les 4. Si toutes
# bloquées, retourne false.
func wander() -> bool:
	var dirs = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
	dirs.shuffle()
	for d in dirs:
		if attempt_move(d):
			return true
	return false


# ----------------------------------------------------------------------------
# Attaque du joueur
# ----------------------------------------------------------------------------
func attack_player() -> void:
	# Oriente l'ennemi vers le joueur pendant l'attaque (sans bouger).
	var v = player_vector()
	if v != Vector2.ZERO:
		if abs(v.x) >= abs(v.y):
			_set_facing(Vector2(sign(v.x), 0))
		else:
			_set_facing(Vector2(0, sign(v.y)))
	# On utilise le canal de dégâts existant (lu par life_bar.gd).
	if global.can_be_damaged:
		global.has_taken_damage = true
		global.damageAmount = attack_damage
	end_turn()


# ----------------------------------------------------------------------------
# Dégâts subis
# ----------------------------------------------------------------------------
func take_damage(amount: int) -> void:
	if is_dead or _damage_cooldown:
		return
	hp -= amount
	if damage_sound:
		damage_sound.play()
	if damage_label:
		damage_label.text = "-" + str(amount)
	_damage_cooldown = true
	if damage_timer:
		damage_timer.start()
	if hp <= 0:
		die()


func _on_damage_timer_timeout() -> void:
	_damage_cooldown = false
	if damage_label:
		damage_label.text = ""


func die() -> void:
	is_dead = true
	queue_free()
