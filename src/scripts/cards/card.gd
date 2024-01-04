@tool
extends Node2D
class_name Card

@export var card_texture: CardTexture = preload("res://src/resources/card_textures/default.tres"):
	set(val):
		card_texture = val
		set_texture()

@onready var card_sprite: Sprite2D = Sprite2D.new()

enum RANK {JOKER, ACE, ONE, TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT, NINE, TEN, JACK, QUEEN, KING}
enum SUIT {CLUBS, DIAMONDS, HEARTS, SPADES}

func _ready() -> void:
	add_child(card_sprite)
	set_texture()

func set_texture() -> void:
	card_sprite.set_texture(get_texture())
	card_sprite.scale = Vector2.ONE * card_texture.scale

func get_texture() -> Texture2D:
	return card_texture.blank

