extends EnemyBase

# ============================================================================
# Cafard
# ----------------------------------------------------------------------------
# Le plus simple des ennemis. 1 PV, 1 dégât, avance vers Bill chaque tour.
# Hors de portée -> errance aléatoire.
# ============================================================================


func _ready() -> void:
	max_hp = 1
	attack_damage = 1
	detection_range = 5
	super()  # appelle EnemyBase._ready() (initialise hp, signaux, etc.)


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
