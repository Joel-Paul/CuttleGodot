@tool
class_name CardArea
extends Node2D


const MAX_PREVIEW_CARDS = 52

@export_range(2, MAX_PREVIEW_CARDS, 1, "suffix:cards") var card_spread_limit: int = 8:
	set(val):
		card_spread_limit = val
		queue_redraw()

@export_range(-1.5, 1.5, 0.1, "suffix:% height") var focused_card_y: float = 0:
	set(val):
		focused_card_y = val
		queue_redraw()

#region Hand scaling
@export_group("Scaling", "scale")
@export_range(0, 1) var scale_spacing_x: float = 1:
	set(val):
		scale_spacing_x = val
		queue_redraw()
@export_range(0, 1) var scale_spacing_y: float = 1:
	set(val):
		scale_spacing_y = val
		queue_redraw()
@export_range(0, 90, 0.1, "radians_as_degrees") var scale_rotation: float = 0:
	set(val):
		scale_rotation = val
		queue_redraw()
@export_range(0, 100) var scale_focused_card_spread: float = 50:
	set(val):
		scale_focused_card_spread = val
		queue_redraw()
#endregion

#region Hand curves
@export_group("Curves", "curve")
@export var curve_spacing_x: Curve:
	set(val):
		curve_spacing_x = val
		update_configuration_warnings()
		queue_redraw()
@export var curve_spacing_y: Curve:
	set(val):
		curve_spacing_y = val
		update_configuration_warnings()
		queue_redraw()
@export var curve_rotation: Curve:
	set(val):
		curve_rotation = val
		update_configuration_warnings()
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

@onready var _cards: Node2D = Node2D.new()


var is_dragging = false
var added_card_z_index = 100
var focused_card_z_index = 100

var _added_card: Card
var _focused_card_index: int = -1

var _rotate_tween: Tween
var _move_tween: Tween
var _scale_tween: Tween


#region Private methods
func _ready() -> void:
	add_child(_cards)


func _draw() -> void:
	if Engine.is_editor_hint():
		_draw_preview_cards()
		_draw_preview_curve()
		_draw_preview_focused_card_y()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings = PackedStringArray()
	if curve_spacing_x == null:
		warnings.append("Spacing X curve is null")
	if curve_spacing_y == null:
		warnings.append("Spacing Y curve is null")
	if curve_rotation == null:
		warnings.append("Rotation curve is null")
	return warnings


#region Editor Preview
func _draw_preview_cards() -> void:
	if not preview_show_cards: return
	_focused_card_index = preview_focused_card_index
	
	for i in preview_num_cards:
		if i != _focused_card_index:
			_draw_preview_card(i)
	
	if _focused_card_index > -1:
		_draw_preview_card(_focused_card_index)
	
	draw_set_transform(Vector2.ZERO)


func _draw_preview_card(index: int) -> void:
	var offset: Vector2 = get_card_size() / -2.0  # make centre of card the origin
	
	var trans: Transform2D = get_card_transform(index, preview_num_cards)
	draw_set_transform_matrix(trans)
	
	var rect: Rect2 = Rect2(offset, get_card_size())
	draw_texture_rect(preview_card_texture.back, rect, false)


func _draw_preview_curve() -> void:
	if not preview_show_curve: return
	_focused_card_index = -1
	
	var points: PackedVector2Array = PackedVector2Array()
	for i in card_spread_limit * 2:
		var trans = get_card_transform(i, card_spread_limit * 2)
		points.push_back(trans.get_origin())
	draw_polyline(points, Color.RED, 2)


func _draw_preview_focused_card_y() -> void:
	if not preview_show_focused_card_y: return
	var start_x = get_card_transform(0, card_spread_limit).get_origin().x
	var stop_x = get_card_transform(card_spread_limit - 1, card_spread_limit).get_origin().x
	draw_line(Vector2(start_x, _focused_card_y_pos()), Vector2(stop_x, _focused_card_y_pos()), Color.BLUE, 2)
#endregion


func _reset_tweens() -> void:
	if _rotate_tween: _rotate_tween.kill()
	if _move_tween: _move_tween.kill()
	if _scale_tween: _scale_tween.kill()
	if _cards.get_child_count() > 0:
		_rotate_tween = create_tween().set_parallel()
		_move_tween = create_tween().set_parallel()
		_scale_tween = create_tween().set_parallel()


func _reset_added_card() -> void:
	if _added_card == null: return
	_added_card.z_index -= added_card_z_index
	_added_card = null


func _focused_card_y_pos() -> float:
	return focused_card_y * get_card_height()
#endregion

#region Public methods
func get_card_transform(index: int, length: int) -> Transform2D:
	# Normally, cards will distribute themselves evenly on a range
	# between 0 and 1, which is then fed into the Curve functions.
	# However, if there are say, 2 cards, then they will lie on 0 and 1.
	# This corresponds to the ends of the hand curve, causing a large gap between the cards.
	# To reduce the gap, we can pretend there are more cards in the
	# calculation, then add an offset to correctly centre the cards.
	var effective_length: float = maxf(length, card_spread_limit) - 1
	var effective_offset: float = maxf(0, card_spread_limit - length) / effective_length / 2
	var norm_pos = index / effective_length + effective_offset
	
	var x_scale: float = scale_spacing_x * get_viewport_rect().size.x / 2
	
	var x_pos: float = curve_spacing_x.sample(norm_pos) * x_scale
	var y_pos: float = -curve_spacing_y.sample(norm_pos) * scale_spacing_y * get_viewport_rect().size.y / 2
	var rot: float = curve_rotation.sample(norm_pos) * scale_rotation
	var scal = Vector2.ONE
	
	if _focused_card_index == index:
		y_pos = _focused_card_y_pos()
		rot = 0
		scal *= 1.25
	elif _focused_card_index > -1:
		x_pos += sign(index - _focused_card_index) * effective_length * get_card_width() / scale_focused_card_spread
		x_pos = clampf(x_pos, -x_scale, x_scale)
	
	return Transform2D(rot, scal, 0, Vector2(x_pos, y_pos))


func update_hand() -> void:
	_reset_tweens()
	var cards = _cards.get_children()
	for i: int in cards.size():
		var trans = get_card_transform(i, cards.size())
		var card: Card = cards[i]
		card.z_index = i + 1
		
		if card == _added_card:
			card.z_index += added_card_z_index
			tween_added(card, trans)
			get_tree().create_timer(0.5).timeout.connect(_reset_added_card)
		elif _focused_card_index == i:
			tween_focused(card, trans)
		else:
			tween_unfocused(card, trans)


func order_cards() -> void:
	var cards = _cards.get_children()
	cards.sort_custom(func(a: Card, b: Card): return a.value() < b.value())
	for i in cards.size():
		_cards.move_child(cards[i], i)


func add_card(card: Card, pos: Vector2) -> void:
	_added_card = card
	_cards.add_child(card)
	card.global_position = pos
	card.focus.connect(focus_card)
	card.unfocus.connect(unfocus_card)
	order_cards()
	update_hand()


func remove_card(card: Card) -> void:
	_cards.remove_child(card)
	card.focus.disconnect(focus_card)
	card.unfocus.disconnect(unfocus_card)
	update_hand()


#region Tweens
func tween_added(card: Card, trans: Transform2D) -> void:
	rotate_card(card, trans.get_rotation())
	move_card(card, trans.get_origin())
	scale_card(card, trans.get_scale())


func tween_focused(card: Card, trans: Transform2D) -> void:
	tween_added(card, trans)


func tween_unfocused(card: Card, trans: Transform2D) -> void:
	tween_focused(card, trans)


func rotate_card(card: Card, rot: float, duration: float = 1,
		trans_type: Tween.TransitionType = Tween.TRANS_LINEAR, ease_type: Tween.EaseType = Tween.EASE_OUT) -> void:
	_rotate_tween.tween_property(card, "rotation", rot, duration).set_trans(trans_type).set_ease(ease_type)


func move_card(card: Card, pos: Vector2, duration: float = 1,
		trans_type: Tween.TransitionType = Tween.TRANS_LINEAR, ease_type: Tween.EaseType = Tween.EASE_OUT) -> void:
	_move_tween.tween_property(card, "position", pos, duration).set_trans(trans_type).set_ease(ease_type)


func scale_card(card: Card, scal: Vector2, duration: float = 1,
		trans_type: Tween.TransitionType = Tween.TRANS_LINEAR, ease_type: Tween.EaseType = Tween.EASE_OUT) -> void:
	_scale_tween.tween_property(card, "scale", scal, duration).set_trans(trans_type).set_ease(ease_type)
#endregion


#region Signals
func focus_card(card: Card) -> void:
	if is_dragging: return
	if _added_card != null and _added_card == card: return
	_focused_card_index = _cards.get_children().find(card)
	update_hand()
	card.z_index += focused_card_z_index


func unfocus_card() -> void:
	if is_dragging: return
	_focused_card_index = -1
	update_hand()
#endregion


#region Card sizes
func calculate_max_width() -> float:
	var width: float = 0
	for child in _cards.get_children():
		if child is Card:
			var card: Card = child
			width += card.get_width()
	return width


func get_card_width() -> float:
	return preview_card_texture.get_width()


func get_card_height() -> float:
	return preview_card_texture.get_height()


func get_card_size() -> Vector2:
	return preview_card_texture.get_size()
#endregion
#endregion
