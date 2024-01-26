@tool
class_name Hand
extends Node2D

const MAX_PREVIEW_CARDS = 52

@export_range(2, MAX_PREVIEW_CARDS, 1, "suffix:cards") var hand_length: int = 8:
	set(val):
		hand_length = val
		queue_redraw()

@export_range(-1.5, 1.5) var focused_card_y: float = -0.5:
	set(val):
		focused_card_y = val
		focused_card_y_pos = val * get_card_height()
		queue_redraw()

#region Hand scaling
@export_group("Scaling", "scale")
@export_range(0, 8) var scale_spacing_x: float = 2.5:
	set(val):
		scale_spacing_x = val
		queue_redraw()
@export_range(0, 8) var scale_spacing_y: float = .5:
	set(val):
		scale_spacing_y = val
		queue_redraw()
@export_range(0, 90, 0.1, "radians_as_degrees") var scale_rotation: float = .25:
	set(val):
		scale_rotation = val
		queue_redraw()
@export_range(0, 10) var scale_focused_card_spacing: float = 0:
	set(val):
		scale_focused_card_spacing = val
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
@export var preview_show_focused_card_y: bool = true:
	set(val):
		preview_show_focused_card_y = val
		queue_redraw()
@export var preview_card_texture: CardTexture = preload("res://src/resources/card_textures/pixel_white_red.tres"):
	set(val):
		preview_card_texture = val
		queue_redraw()
@export_range(0, MAX_PREVIEW_CARDS, 1, "suffix:cards") var preview_num_cards: int = 8:
	set(val):
		preview_num_cards = val
		queue_redraw()
@export_range(-1, MAX_PREVIEW_CARDS - 1) var preview_focused_card_index: int = -1:
	set(val):
		preview_focused_card_index = val % preview_num_cards
		queue_redraw()
#endregion

const CURVE_POINTS = 20

@onready var _cards: Node2D = %Cards
var focused_card_index: int = -1
var focused_card_y_pos: float = focused_card_y * get_card_height()


func _draw() -> void:
	if Engine.is_editor_hint():
		_draw_preview_cards()
		_draw_preview_curve()
		_draw_preview_focused_card_y()


#region Editor Preview

func _draw_preview_cards() -> void:
	if not preview_show_cards: return
	focused_card_index = preview_focused_card_index
	
	for i in preview_num_cards:
		if i != focused_card_index:
			_draw_preview_card(i)
	
	if focused_card_index > -1:
		_draw_preview_card(focused_card_index)
	
	draw_set_transform(Vector2.ZERO)


func _draw_preview_card(index: int) -> void:
	var offset: Vector2 = get_card_size() / -2.0  # make centre of card the origin
	
	var trans: Transform2D = get_card_transform(index, preview_num_cards)
	draw_set_transform_matrix(trans)
	
	var rect: Rect2 = Rect2(offset, get_card_size())
	draw_texture_rect(preview_card_texture.back, rect, false)


func _draw_preview_curve() -> void:
	if not preview_show_curve: return
	focused_card_index = -1
	
	var points: PackedVector2Array = PackedVector2Array()
	for i in CURVE_POINTS:
		var trans = get_card_transform(i, CURVE_POINTS)
		points.push_back(trans.get_origin())
	draw_polyline(points, Color.RED, 2)


func _draw_preview_focused_card_y() -> void:
	if not preview_show_focused_card_y: return
	var x_pos = (scale_spacing_x + 0.5) * get_card_width()
	draw_line(Vector2(-x_pos, focused_card_y_pos), Vector2(x_pos, focused_card_y_pos), Color.BLUE, 2)

#endregion


func get_card_transform(index: int, length: int) -> Transform2D:
	# Normally, cards will distribute themselves evenly on a range
	# between 0 and 1, which is then fed into the Curve functions.
	# However, if there are say, 2 cards, then they will lie on 0 and 1.
	# This corresponds to the ends of the hand curve, causing a large gap between the cards.
	# To reduce the gap, we can pretend there are more cards in the
	# calculation, then add an offset to correctly centre the cards.
	var effective_length: float = maxf(length, hand_length) - 1
	var effective_offset: float = maxf(0, hand_length - length) / effective_length / 2
	var norm_pos = index / effective_length + effective_offset
	
	if focused_card_index == index:
		pass
	elif focused_card_index > -1:
		var focused_offset = scale_focused_card_spacing / (get_card_width() * (index - focused_card_index))
		norm_pos += focused_offset
	
	var x_pos: float = curve_spacing_x.sample(norm_pos) * scale_spacing_x * get_card_width()
	var y_pos: float = -curve_spacing_y.sample(norm_pos) * scale_spacing_y * get_card_height()
	var rot: float = curve_rotation.sample(norm_pos) * scale_rotation
	var scal = Vector2.ONE
	
	if focused_card_index == index:
		y_pos = focused_card_y_pos
		rot = 0
		scal *= 1.25
	
	return Transform2D(rot, scal, 0, Vector2(x_pos, y_pos))


func update_hand() -> void:
	var cards = _cards.get_children()
	for i: int in cards.size():
		var trans = get_card_transform(i, cards.size())
		var card: Card = cards[i]
		card.z_index = i + 1
		if i == focused_card_index:
			card.z_index *= 1
		rotate_card(card, trans.get_rotation())
		move_card(card, trans.get_origin())
		scale_card(card, trans.get_scale())


func add_card(card: Card, pos: Vector2) -> void:
	_cards.add_child(card)
	card.global_position = pos
	card.focus.connect(focus_card)
	card.unfocus.connect(unfocus_card)
	update_hand()


## Tweens card to a rotaiton.
func rotate_card(card: Card, rot: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(card, "rotation", rot, 0.1).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	#tween.set_parallel()


## Tweens card to a position.
func move_card(card: Card, pos: Vector2) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(card, "position", pos, 1).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)


## Tweens card to a scale.
func scale_card(card: Card, scal: Vector2) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(card, "scale", scal, 0.1).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)


func focus_card(card: Card) -> void:
	focused_card_index = _cards.get_children().find(card)
	update_hand()


func unfocus_card() -> void:
	focused_card_index = -1
	update_hand()


func get_card_width() -> float:
	return preview_card_texture.get_width()


func get_card_height() -> float:
	return preview_card_texture.get_height()


func get_card_size() -> Vector2:
	return preview_card_texture.get_size()
