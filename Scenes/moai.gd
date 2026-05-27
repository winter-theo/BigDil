extends EnemyBase

# ============================================================================
# Moai (BOSS)
# ----------------------------------------------------------------------------
# Statue antique géante (48×48, occupe 3×3 tiles). Boss du donjon.
#
# IA :
#   - Reste sur place (statue immobile)
#   - Si Bill est aligné en croix avec n'importe quelle partie du Moai
#     (3 colonnes × 3 rangées) et dans la portée :
#       Tour 1 : IDLE -> CHARGING (anim charge)
#       Tour 2 : CHARGING (anim charge)
#       Tour 3 : FIRING (anim laser, dégâts si Bill toujours sur la croix)
#       Tour 4 : IDLE (recommence)
#   - Si Bill est adjacent (collé) : attaque CAC sans charger (backup)
#
# Le joueur peut esquiver le laser en sortant de la croix pendant la phase de
# charge.
# ============================================================================

enum State { IDLE, CHARGING, FIRING }

# Durée de la phase de charge (en tours du boss).
const CHARGE_DURATION = 2

# Portée du laser en tiles.
const LASER_RANGE = 8

# Offset du centre visuel du Moai par rapport à sa position de référence
# (origine du noeud). Le sprite est offset de (8, -8), donc le centre visuel
# est ici. C'est par rapport à ce centre qu'on calcule la "croix" de tir.
const VISUAL_CENTER_OFFSET = Vector2(8, -8)

# Demi-largeur et demi-hauteur du Moai en tiles. 1 = couvre 3 tiles (-1, 0, +1).
const MOAI_HALF_WIDTH_TILES = 1
const MOAI_HALF_HEIGHT_TILES = 1

var state: State = State.IDLE
var charge_counter: int = 0


func _ready() -> void:
	max_hp = 5
	attack_damage = 1
	detection_range = LASER_RANGE
	super()
	_play("idle")


func take_turn() -> void:
	if is_dead:
		end_turn()
		return

	match state:
		State.IDLE:
			_handle_idle()
		State.CHARGING:
			_handle_charging()
		State.FIRING:
			_handle_firing()


func _handle_idle() -> void:
	if _player_on_cross() and _distance_from_visual_center() <= LASER_RANGE:
		state = State.CHARGING
		charge_counter = 0
		_play("charge")
		end_turn()
		return

	if is_adjacent_to_player():
		_play("idle")
		attack_player()
		return

	_play("idle")
	end_turn()


func _handle_charging() -> void:
	charge_counter += 1
	_play("charge")
	if charge_counter >= CHARGE_DURATION:
		state = State.FIRING
	end_turn()


func _handle_firing() -> void:
	_play("attack")
	if _player_on_cross() and _distance_from_visual_center() <= LASER_RANGE:
		if global.can_be_damaged:
			global.has_taken_damage = true
			global.damageAmount = attack_damage
	state = State.IDLE
	end_turn()


# ----------------------------------------------------------------------------
# Détection étendue : le Moai occupe 3x3 tiles, donc sa "croix" est élargie.
# ----------------------------------------------------------------------------

# Vecteur en tiles depuis le CENTRE VISUEL du Moai vers le joueur.
func _player_offset_tiles() -> Vector2:
	var p = get_player()
	if p == null:
		return Vector2.ZERO
	var moai_center = global_position + VISUAL_CENTER_OFFSET
	return (p.global_position - moai_center) / tile_size


# Distance Manhattan en tiles entre le centre visuel du Moai et le joueur.
# Utilisée pour la portée du laser.
func _distance_from_visual_center() -> int:
	var v = _player_offset_tiles()
	return int(abs(v.x) + abs(v.y))


# Bill est-il dans la croix élargie du Moai ?
# Vrai si Bill est dans une des 3 colonnes OU dans une des 3 rangées occupées
# par le Moai, et qu'il n'est PAS dans la zone du Moai elle-même.
func _player_on_cross() -> bool:
	var v = _player_offset_tiles()
	if v == Vector2.ZERO:
		return false

	var in_columns = abs(v.x) <= MOAI_HALF_WIDTH_TILES
	var in_rows = abs(v.y) <= MOAI_HALF_HEIGHT_TILES

	# Si Bill est physiquement dans la zone du Moai (ne devrait pas arriver
	# grâce à la hitbox), on ne déclenche pas le laser.
	if in_columns and in_rows:
		return false

	return in_columns or in_rows


# Helper pour jouer une animation si elle existe sur l'AnimatedSprite2D.
func _play(anim_name: String) -> void:
	if animated_sprite == null:
		return
	if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation(anim_name):
		if animated_sprite.animation != anim_name:
			animated_sprite.play(anim_name)
