extends Node2D

# ============================================================================
# TurnManager
# ----------------------------------------------------------------------------
# Orchestre le combat tour-par-tour de la scène.
#
# Cycle :
#   1. Tour joueur. global.is_player_turn = true.
#   2. Le joueur agit (mouvement/item/attaque) -> global.consume_turn()
#      -> signal turn_consumed -> on passe au tour ennemi.
#   3. Chaque ennemi joue son take_turn() en séquence, et émet turn_finished
#      quand son action est résolue. On enchaîne au suivant.
#   4. Tous les ennemis ont joué -> on repasse en tour joueur.
#
# Détection des ennemis : on scanne la scène à la recherche de tout node qui a
# une méthode take_turn() et un signal turn_finished (les EnemyBase).
# ============================================================================

enum State { PLAYER_TURN, ENEMY_TURN }

var state: State = State.PLAYER_TURN
var enemies: Array = []
var current_enemy_index: int = 0


func _ready() -> void:
	# Attendre une frame que tous les enfants soient prêts (sinon les Bill/ennemis
	# instanciés via PackedScene ne sont pas encore dans l'arbre).
	await get_tree().process_frame
	_refresh_enemies()
	global.is_player_turn = true
	if not global.turn_consumed.is_connected(_on_player_turn_consumed):
		global.turn_consumed.connect(_on_player_turn_consumed)


func _process(_delta: float) -> void:
	# Conservation du comportement legacy : si on change de scène, on se libère.
	if global.unloading_scene == true:
		queue_free()


# ----------------------------------------------------------------------------
# Détection des ennemis dans la scène
# ----------------------------------------------------------------------------
func _refresh_enemies() -> void:
	enemies.clear()
	_scan_for_enemies(self)


func _scan_for_enemies(node: Node) -> void:
	for child in node.get_children():
		# On reconnaît un ennemi à la présence de la méthode take_turn et du
		# signal turn_finished (notre interface EnemyBase).
		if child.has_method("take_turn") and child.has_signal("turn_finished"):
			enemies.append(child)
			if not child.turn_finished.is_connected(_on_enemy_turn_finished):
				child.turn_finished.connect(_on_enemy_turn_finished)
		_scan_for_enemies(child)


func _clean_dead_enemies() -> void:
	enemies = enemies.filter(func(e):
		return is_instance_valid(e) and not e.is_queued_for_deletion()
	)


# ----------------------------------------------------------------------------
# Cycle de tours
# ----------------------------------------------------------------------------
func _on_player_turn_consumed() -> void:
	# Le joueur vient de finir une action. Si on n'est pas censé être en tour
	# joueur, on ignore (sécurité).
	if state != State.PLAYER_TURN:
		return

	_clean_dead_enemies()

	if enemies.is_empty():
		# Pas d'ennemis dans la scène : le joueur peut continuer librement.
		global.is_player_turn = true
		return

	# Passe en tour ennemi.
	state = State.ENEMY_TURN
	global.is_player_turn = false
	current_enemy_index = 0
	_run_next_enemy()


func _run_next_enemy() -> void:
	# On saute tous les ennemis morts ou invalides.
	while current_enemy_index < enemies.size():
		var enemy = enemies[current_enemy_index]
		if is_instance_valid(enemy) and not enemy.is_queued_for_deletion():
			enemy.take_turn()
			return
		current_enemy_index += 1

	# Tous les ennemis ont joué : on repasse en tour joueur.
	state = State.PLAYER_TURN
	global.is_player_turn = true


func _on_enemy_turn_finished() -> void:
	# Un ennemi a fini son tour, on passe au suivant.
	current_enemy_index += 1
	_run_next_enemy()
