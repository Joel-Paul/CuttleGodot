@tool
class_name Card
extends Node2D

enum RANK {JOKER, ACE, TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT, NINE, TEN, JACK, QUEEN, KING}
enum SUIT {CLUBS, DIAMONDS, HEARTS, SPADES}

signal flipped(card: Card)


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

@export var show_back: bool = false:
	set(val):
		show_back = val
		_set_texture()

@onready var anim_player: AnimationPlayer = %AnimationPlayer
var card_sprite: Sprite2D = Sprite2D.new()


func _ready() -> void:
	add_child(card_sprite)
	_set_texture()


func _set_texture() -> void:
	card_sprite.set_texture(_get_texture())
	card_sprite.scale = Vector2.ONE * card_texture.scale


func _get_texture() -> Texture2D:
	if show_back:
		return card_texture.back
	if rank == RANK.JOKER:
		return card_texture.joker
	# Subtract 1 to exclude RANK.JOKER
	return card_texture.get_all()[(RANK.size() - 1) * suit + rank - 1]


func get_size() -> Vector2:
	return card_texture.get_size()


func play_flip_card() -> void:
	var animation: StringName = "flip_up" if show_back else "flip_down"
	anim_player.play(animation)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"flip_up", "flip_down":
			flipped.emit(self)
