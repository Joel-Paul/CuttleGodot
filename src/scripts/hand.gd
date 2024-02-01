@tool
class_name Hand
extends Node2D


signal released(card: Card)

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

var focused_card_index: int = -1
var focused_card_y_pos: float = focused_card_y * get_card_height()
var dragging_card: Card

var rotate_tween: Tween
var move_tween: Tween
var scale_tween: Tween


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and dragging_card != null:
		dragging_card.global_position += event.relative


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
	for i in hand_length * 2:
		var trans = get_card_transform(i, hand_length * 2)
		points.push_back(trans.get_origin())
	draw_polyline(points, Color.RED, 2)


func _draw_preview_focused_card_y() -> void:
	if not preview_show_focused_card_y: return
	var x_pos = (scale_spacing_x + 0.5) * get_card_width()
	draw_line(Vector2(-x_pos, focused_card_y_pos), Vector2(x_pos, focused_card_y_pos), Color.BLUE, 2)
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
	_reset_tweens()
	var cards = %Cards.get_children()
	for i: int in cards.size():
		var trans = get_card_transform(i, cards.size())
		var card: Card = cards[i]
		card.z_index = i + 1
		if focused_card_index == i:
			rotate_card(card, trans.get_rotation(), 0.1)
			move_card(card, trans.get_origin(), 0.1)
			scale_card(card, trans.get_scale(), 0.1)
		else:
			rotate_card(card, trans.get_rotation())
			move_card(card, trans.get_origin())
			scale_card(card, trans.get_scale(), 0.5)


func order_cards() -> void:
	var cards = %Cards.get_children()
	cards.sort_custom(func(a: Card, b: Card): return a.value() < b.value())
	for i in cards.size():
		%Cards.move_child(cards[i], i)


func add_card(card: Card, pos: Vector2) -> void:
	%Cards.add_child(card)
	card.global_position = pos
	card.focus.connect(focus_card)
	card.unfocus.connect(unfocus_card)
	card.clicked.connect(clicked_card)
	card.released.connect(released_card)
	order_cards()
	update_hand()


func remove_card(card: Card) -> void:
	%Cards.remove_child(card)
	card.focus.disconnect(focus_card)
	card.unfocus.disconnect(unfocus_card)
	card.clicked.disconnect(clicked_card)
	card.released.disconnect(released_card)
	update_hand()

## Tweens card to a rotaiton.
func rotate_card(card: Card, rot: float, duration: float = 1) -> void:
	rotate_tween.tween_property(card, "rotation", rot, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)


## Tweens card to a position.
func move_card(card: Card, pos: Vector2, duration: float = 1) -> void:
	move_tween.tween_property(card, "position", pos, duration).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)


## Tweens card to a scale.
func scale_card(card: Card, scal: Vector2, duration: float = 1) -> void:
	scale_tween.tween_property(card, "scale", scal, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)


func focus_card(card: Card) -> void:
	if dragging_card != null: return
	focused_card_index = %Cards.get_children().find(card)
	update_hand()


func unfocus_card() -> void:
	if dragging_card != null: return
	focused_card_index = -1
	update_hand()


func clicked_card(card: Card) -> void:
	dragging_card = card
	card.z_index *= 100


func released_card() -> void:
	released.emit(dragging_card)
	dragging_card = null
	focused_card_index = -1
	update_hand()


func get_card_width() -> float:
	return preview_card_texture.get_width()


func get_card_height() -> float:
	return preview_card_texture.get_height()


func get_card_size() -> Vector2:
	return preview_card_texture.get_size()
