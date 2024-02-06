@tool
class_name Deck
extends Node2D


@export var card_texture: CardTexture = preload("res://src/resources/card_textures/pixel_white_red.tres"):
	set(val):
		card_texture = val
		queue_redraw()

@export_range(0, 50, 1, "suffix:px") var empty_deck_corner_radius: int = 5:
	set(val):
		empty_deck_corner_radius = val
		queue_redraw()

@export var stack_vector: Vector2 = Vector2.ONE * -0.1:
	set(val):
		stack_vector = val
		queue_redraw()

#region Deck preview
@export_group("Preview", "preview")
@export_range(0, 60, 1, "suffix:cards") var preview_deck_size: int = 52:
	set(val):
		preview_deck_size = val
		queue_redraw()
#endregion

var card_scene: PackedScene = preload("res://src/scenes/card.tscn")
var _cards: Array[Card]


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	reset_deck()


func _draw() -> void:
	_draw_empty()
	_draw_stack()


func _draw_empty() -> void:
	var style_box = StyleBoxFlat.new()
	style_box.set_corner_radius_all(empty_deck_corner_radius)
	style_box.set_anti_aliased(false)
	var offset: Vector2 = card_texture.get_size() / -2.0  # make centre of card the origin
	var rect: Rect2 = Rect2(offset, card_texture.get_size())
	draw_style_box(style_box, rect)


func _draw_stack() -> void:
	var stack_size = preview_deck_size
	if not Engine.is_editor_hint():
		stack_size = _cards.size()
	
	var offset: Vector2 = card_texture.get_size() / -2.0  # make centre of card the origin
	for i in stack_size:
		var rect: Rect2 = Rect2(offset + stack_vector * i, card_texture.get_size())
		draw_texture_rect(card_texture.back, rect, false)


func reset_deck() -> void:
	_cards.clear()
	var _exclude = [Card.SUIT.CLUBS, Card.SUIT.DIAMONDS, Card.SUIT.HEARTS, Card.SUIT.CLUBS]
	for suit: Card.SUIT in Card.SUIT.values():
		if suit in _exclude: continue
		for rank: Card.RANK in Card.RANK.values():
			if rank == Card.RANK.JOKER:
				continue
			_cards.push_back(add_card(rank, suit))
	shuffle()


func shuffle() -> void:
	_cards.shuffle()


func draw_card() -> Card:
	var card: Card = _cards.pop_back()
	add_child(card)
	card.position = stack_vector * _cards.size()
	queue_redraw()
	card.play_flip_card()
	return card


func is_empty() -> bool:
	return _cards.is_empty()


func add_card(rank: Card.RANK, suit: Card.SUIT) -> Card:
	var card: Card = card_scene.instantiate()
	card.card_texture = card_texture
	card.rank = rank
	card.suit = suit
	card.show_back = true
	return card
