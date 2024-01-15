@tool
class_name Hand
extends Node2D

const CURVE_POINTS = 20

@export_range(2, 20, 1, "suffix:cards") var hand_length: int = 8:
	set(val):
		hand_length = val
		queue_redraw()

@onready var _cards: Node2D = $Cards

#region Hand scaling
@export_group("Scaling", "scale")
@export_range(0, 50) var scale_spacing_x: float = 2.5:
	set(val):
		scale_spacing_x = val
		queue_redraw()
@export_range(0, 50) var scale_spacing_y: float = .5:
	set(val):
		scale_spacing_y = val
		queue_redraw()
@export_range(0, 90, 0.1, "radians_as_degrees") var scale_rotation: float = .25:
	set(val):
		scale_rotation = val
		queue_redraw()
#endregion

#region Hand curves
@export_group("Curves", "curve")
@export var curve_spacing_x: Curve = preload("res://src/resources/curves/hand_spacing_x.tres"):
	set(val):
		curve_spacing_x = val
		queue_redraw()
@export var curve_spacing_y: Curve = preload("res://src/resources/curves/hand_spacing_y.tres"):
	set(val):
		curve_spacing_y = val
		queue_redraw()
@export var curve_rotation: Curve = preload("res://src/resources/curves/hand_rotation.tres"):
	set(val):
		curve_rotation = val
		queue_redraw()
#endregion

#region Hand preview
@export_group("Preview", "preview")
@export var preview_show_cards: bool = true:
	set(val):
		preview_show_cards = val
		queue_redraw()
@export var preview_show_curve: bool = true:
	set(val):
		preview_show_curve = val
		queue_redraw()
@export var preview_card_texture: CardTexture = preload("res://src/resources/card_textures/pixel_white_red.tres"):
	set(val):
		preview_card_texture = val
		queue_redraw()
@export_range(0, 20, 1, "suffix:cards") var preview_num_cards: int = 8:
	set(val):
		preview_num_cards = val
		queue_redraw()
#endregion

func _draw() -> void:
	if Engine.is_editor_hint():
		_draw_preview_cards()
		_draw_preview_curve()


func _draw_preview_cards() -> void:
	if not preview_show_cards: return
	
	var offset: Vector2 = preview_card_texture.get_size() / -2.0  # make centre of card the origin
	for i in preview_num_cards:
		var trans: Transform2D = get_card_transform(i, preview_num_cards)
		draw_set_transform_matrix(trans)

		var rect: Rect2 = Rect2(offset, preview_card_texture.get_size())
		draw_texture_rect(preview_card_texture.back, rect, false)
	draw_set_transform(Vector2.ZERO)


func _draw_preview_curve() -> void:
	if not preview_show_curve: return
	
	var points: PackedVector2Array = PackedVector2Array()
	for i in CURVE_POINTS:
		var trans = get_card_transform(i, CURVE_POINTS)
		points.push_back(trans.get_origin())
	draw_polyline(points, Color.RED, 2)


func get_card_transform(index: int, length: int) -> Transform2D:
	# Normally, cards will distribute themselves evenly on a range
	# between 0 and 1, which is then fed into the Curve functions.
	# However, if there are say, 2 cards, then they will lie on 0 and 1.
	# This corresponds to the ends of the hand curve, causing a large gap between the cards.
	# To reduce the gap, we can pretend there are more cards in the
	# calculation, then add an offset to correctly centre the cards.
	var effective_length: float = maxf(length, hand_length) - 1
	var offset: float = maxf(0, hand_length - length) / effective_length / 2
	var norm_pos = index / effective_length + offset
	
	var x_pos: float = curve_spacing_x.sample(norm_pos) * scale_spacing_x * preview_card_texture.get_width()
	var y_pos: float = -curve_spacing_y.sample(norm_pos) * scale_spacing_y * preview_card_texture.get_height()
	var rot: float = curve_rotation.sample(norm_pos) * scale_rotation
	
	return Transform2D(rot, Vector2(x_pos, y_pos))


func update_hand() -> void:
	var cards = _cards.get_children()
	for i: int in cards.size():
		var trans = get_card_transform(i, cards.size())
		var card: Card = cards[i]
		rotate_card(card, trans.get_rotation())
		move_card(card, trans.get_origin())


func add_card(card: Card) -> void:
	_cards.add_child(card)
	update_hand()

## Tweens card to a rotaiton.
func rotate_card(card: Card, rot: float):
	card.rotation = rot


## Tweens card to a position.
func move_card(card: Card, pos: Vector2):
	card.position = pos
