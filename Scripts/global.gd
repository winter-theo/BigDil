extends Node

var bomb = load("res://Assets/UI/bomb.png")
var placeholder = load("res://Assets/UI/life_2.png")
var scene_name: String ="title_screen"

var loading_scene = true
var unloading_scene = false

var has_moved = false
var can_be_damaged = true
var has_taken_damage = false
var damageAmount = 0
var is_frozen = false

var TurnCounter = 0
var life_bar = 6

var Inventory = []
var has_been_obtained = [false, false]
var quantity = [0, 0]
var itemSprite = [bomb, placeholder]
var CurrentSlot = 0
var size = 0
var LastPicked = true

var Billpos = Vector2.ZERO

var enemy_has_been_damaged = false
var enemy_can_be_damaged = true
var has_attacked = false
var bomb2 = false
