extends Node

# --- Signaux ---
# Émis chaque fois qu'une action consomme un tour (mouvement, attaque, item).
# Le TurnManager s'y abonne pour déclencher les tours ennemis.
signal turn_consumed

# --- Ressources préchargées ---
var bomb = load("res://Assets/UI/bomb.png")
var placeholder = load("res://Assets/UI/life_2.png")

# --- Gestion de scènes (legacy) ---
var scene_name: String = "title_screen"
var loading_scene = true
var unloading_scene = false

# --- État joueur ---
var has_moved = false
var can_be_damaged = true
var has_taken_damage = false
var damageAmount = 0
var is_frozen = false

# --- Tour-par-tour ---
# Quand false, le joueur ne peut pas agir (c'est le tour des ennemis).
var is_player_turn: bool = true
var TurnCounter = 0

# --- Vie & inventaire ---
var life_bar = 6

var Inventory = []
var has_been_obtained = [false, false]
var quantity = [0, 0]
var itemSprite = [bomb, placeholder]
var CurrentSlot = 0
var size = 0
var LastPicked = true

# --- Position de Bill (utilisée par bomb_placed) ---
var Billpos = Vector2.ZERO

# --- État ennemi (legacy, conservé pour compat) ---
var enemy_has_been_damaged = false
var enemy_can_be_damaged = true
var has_attacked = false
var bomb2 = false


# Consomme un tour pour le joueur : incrémente le compteur et notifie le
# TurnManager. À appeler à chaque action joueur (mouvement, item, attaque).
func consume_turn() -> void:
	TurnCounter += 1
	turn_consumed.emit()
