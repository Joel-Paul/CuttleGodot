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

var cards: Array[Card]

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_reset_deck()

func _draw() -> void:
	_draw_empty()
	_draw_stack()

func _reset_deck() -> void:
	cards.clear()
	for suit: Card.SUIT in Card.SUIT.values():
		for rank: Card.RANK in Card.RANK.values():
			var card: Card = Card.new(rank, suit)
			card.card_texture = card_texture
			cards.push_back(card)

func _draw_empty() -> void:
	var style_box = StyleBoxFlat.new()
	style_box.set_corner_radius_all(empty_deck_corner_radius)
	style_box.set_anti_aliased(false)
	var offset: Vector2 = card_texture.get_size() / -2.0  # make centre of card the origin
	var rect: Rect2 = Rect2(offset, card_texture.get_size())
	draw_style_box(style_box, rect)

func _draw_stack() -> void:
	var stack_size = preview_deck_size
	if not Engine.is_editor_hint() and not cards.is_empty():
		stack_size = cards.size()
	
	var offset: Vector2 = card_texture.get_size() / -2.0  # make centre of card the origin
	for i in stack_size:
		var rect: Rect2 = Rect2(offset + stack_vector * i, card_texture.get_size())
		draw_texture_rect(card_texture.back, rect, false)
