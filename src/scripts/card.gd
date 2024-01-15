@tool
class_name Card
extends Node2D

enum RANK {JOKER, ACE, TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT, NINE, TEN, JACK, QUEEN, KING}
enum SUIT {CLUBS, DIAMONDS, HEARTS, SPADES}

@export var rank: RANK:
	set(val):
		rank = val
		_set_texture()

@export var suit: SUIT:
	set(val):
		suit = val
		_set_texture()

@export var card_texture: CardTexture = preload("res://src/resources/card_textures/pixel_white_red.tres"):
	set(val):
		card_texture = val
		_set_texture()

var card_sprite: Sprite2D = Sprite2D.new()

func _init(p_rank: RANK = RANK.JOKER, p_suit: SUIT = SUIT.CLUBS) -> void:
	if Engine.is_editor_hint():
		return
	rank = p_rank
	suit = p_suit

func _ready() -> void:
	add_child(card_sprite)
	_set_texture()


func _set_texture() -> void:
	card_sprite.set_texture(_get_texture())
	card_sprite.scale = Vector2.ONE * card_texture.scale


func _get_texture() -> Texture2D:
	if rank == RANK.JOKER:
		return card_texture.joker
	# Subtract 1 to exclude RANK.JOKER
	return card_texture.get_all()[(RANK.size() - 1) * suit + rank - 1]

func get_size() -> Vector2:
	return card_texture.get_size()
