extends EnemyBase

# ============================================================================
# Rat
# ----------------------------------------------------------------------------
# Plus tanky que le cafard : 3 PV au lieu de 1. Inflige 1 dégât en CAC.
# Comportement identique au cafard : avance vers Bill, attaque quand adjacent.
# ============================================================================


func _ready() -> void:
	max_hp = 3
	attack_damage = 1
	detection_range = 5
	super()


func take_turn() -> void:
	if is_dead:
		end_turn()
		return

	# 1. Si adjacent à Bill : attaque CAC.
	if is_adjacent_to_player():
		attack_player()
		return

	# 2. Si dans la zone de détection : avance vers Bill (avec contournement).
	if distance_to_player_tiles() <= detection_range:
		if smart_move_toward_player():
			return  # le tween émettra turn_finished à la fin

	# 3. Hors de portée OU bloqué : errance aléatoire.
	if wander():
		return

	# 4. Tout bloqué : passe son tour.
	end_turn()
