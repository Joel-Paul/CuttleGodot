@tool
class_name PlayArea
extends Node2D

const MAX_PREVIEW_CARDS = 52

@export_range(2, MAX_PREVIEW_CARDS, 1, "suffix:cards") var hand_length: int = 8:
	set(val):
		hand_length = val
		queue_redraw()
@export_range(0, 100, 0.01, "suffix:px") var play_area_margin: float = 0:
	set(val):
		play_area_margin = val
		queue_redraw()

#region Play Area scaling
@export_group("Scaling", "scale")
@export_range(0, 8) var scale_spacing_x: float = 2.5:
	set(val):
		scale_spacing_x = val
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
@export_range(0, MAX_PREVIEW_CARDS, 1, "suffix:cards") var preview_num_cards: int = 8:
	set(val):
		preview_num_cards = val
		queue_redraw()
#endregion

var _play_rect: Rect2
var _new_card: Card

var rotate_tween: Tween
var move_tween: Tween
var scale_tween: Tween


func _ready() -> void:
	_play_rect = create_play_rect()


func _draw() -> void:
	if Engine.is_editor_hint():
		_draw_preview_cards()
		_draw_preview_curve()
		_draw_play_area()


#region Editor Preview
func _draw_preview_cards() -> void:
	if not preview_show_cards: return
	
	for i in preview_num_cards:
		_draw_preview_card(i)
	
	draw_set_transform(Vector2.ZERO)


func _draw_preview_card(index: int) -> void:
	var offset: Vector2 = get_card_size() / -2.0  # make centre of card the origin
	
	var trans: Transform2D = get_card_transform(index, preview_num_cards)
	draw_set_transform_matrix(trans)
	
	var rect: Rect2 = Rect2(offset, get_card_size())
	draw_texture_rect(preview_card_texture.back, rect, false)


func _draw_preview_curve() -> void:
	if not preview_show_curve: return
	
	var points: PackedVector2Array = PackedVector2Array()
	for i in [0, preview_num_cards - 1]:
		var trans = get_card_transform(i, preview_num_cards)
		points.push_back(trans.get_origin())
	draw_polyline(points, Color.RED, 2)

func _draw_play_area() -> void:
	_play_rect = create_play_rect()
	draw_rect(_play_rect, Color.SKY_BLUE, false)
#endregion


func _reset_tweens() -> void:
	if rotate_tween: rotate_tween.kill()
	if move_tween: move_tween.kill()
	if scale_tween: scale_tween.kill()
	if %Cards.get_child_count() > 0:
		rotate_tween = create_tween().set_parallel()
		move_tween = create_tween().set_parallel()
		scale_tween = create_tween().set_parallel()


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
	
	var x_pos: float = (2 * norm_pos - 1) * scale_spacing_x * get_card_width()
	return Transform2D(0, Vector2(x_pos, 0))


func update_hand() -> void:
	_reset_tweens()
	var cards = %Cards.get_children()
	for i: int in cards.size():
		var trans = get_card_transform(i, cards.size())
		var card: Card = cards[i]
		card.z_index = i + 1
		if _new_card != null and _new_card == card:
			card.z_index *= 10
		rotate_card(card, trans.get_rotation(), 0.5)
		move_card(card, trans.get_origin(), 0.5)
		scale_card(card, trans.get_scale(), 0.5)
	_new_card = null


func order_cards() -> void:
	var cards = %Cards.get_children()
	cards.sort_custom(func(a: Card, b: Card): return a.value() < b.value())
	for i in cards.size():
		%Cards.move_child(cards[i], i)


func create_play_rect() -> Rect2:
	var offset = get_card_size() / 2 + Vector2.ONE * play_area_margin
	var pos_start = get_card_transform(0, hand_length).get_origin() - offset
	var pos_end = get_card_transform(hand_length - 1, hand_length).get_origin() + offset
	return Rect2(pos_start, pos_end - pos_start)


func inside_play_area(pos: Vector2) -> bool:
	return _play_rect.has_point(pos)


func add_card(card: Card, pos: Vector2) -> void:
	%Cards.add_child(card)
	card.global_position = pos
	_new_card = card
	order_cards()
	update_hand()


## Tweens card to a rotaiton.
func rotate_card(card: Card, rot: float, duration: float = 1) -> void:
	rotate_tween.tween_property(card, "rotation", rot, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)


## Tweens card to a position.
func move_card(card: Card, pos: Vector2, duration: float = 1) -> void:
	move_tween.tween_property(card, "position", pos, duration).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)


## Tweens card to a scale.
func scale_card(card: Card, scal: Vector2, duration: float = 1) -> void:
	scale_tween.tween_property(card, "scale", scal, duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)


func get_card_width() -> float:
	return preview_card_texture.get_width()


func get_card_height() -> float:
	return preview_card_texture.get_height()


func get_card_size() -> Vector2:
	return preview_card_texture.get_size()
