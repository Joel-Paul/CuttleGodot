@tool
class_name Hand
extends Node2D

const CURVE_POINTS = 20

@export_range(0, 20) var max_card_expansion: int = 8:
	set(val):
		max_card_expansion = val
		queue_redraw()

#region Hand scaling
@export_group("Scaling", "scale")
@export_range(0, 5) var scale_spacing_x: float = 2.5:
	set(val):
		scale_spacing_x = val
		queue_redraw()
@export_range(0, 5) var scale_spacing_y: float = .5:
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
@export var preview_card_texture: CardTexture = preload("res://src/resources/card_textures/default.tres"):
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
		if preview_show_cards:
			_draw_preview_cards()
		if preview_show_curve:
			_draw_preview_curve()

func _draw_preview_cards() -> void:
	var offset: Vector2 = preview_card_texture.get_size() / -2.0  # make centre of card the origin
	for i in preview_num_cards:
		var trans: Transform2D = get_card_transform(i, preview_num_cards)
		draw_set_transform_matrix(trans)

		var rect: Rect2 = Rect2(offset, preview_card_texture.get_size())
		draw_texture_rect(preview_card_texture.back, rect, false)
	draw_set_transform(Vector2.ZERO)

func _draw_preview_curve() -> void:
	var points: PackedVector2Array = PackedVector2Array()
	for i in CURVE_POINTS:
		var trans = get_card_transform(i, CURVE_POINTS)
		points.push_back(trans.get_origin())
	draw_polyline(points, Color.RED, 2)

func get_card_transform(index: int, length: int) -> Transform2D:
	# Effective length/index serves to "pad out" the hand
	# when the number of cards is below `max_card_expansion`.
	# Without this, the spacing between low amounts of cards is large.
	var length_offset: int = 0 if length % 2 == max_card_expansion % 2 else 1
	var effective_length: int = maxi(length, max_card_expansion - length_offset)
	var effective_index: int = index + roundf((effective_length - length) / 2.0)
	var norm_pos: float = effective_index / (effective_length - 1.0)
	
	var x_pos: float = curve_spacing_x.sample(norm_pos) * scale_spacing_x * preview_card_texture.get_width()
	var y_pos: float = -curve_spacing_y.sample(norm_pos) * scale_spacing_y * preview_card_texture.get_height()
	var rot: float = curve_rotation.sample(norm_pos) * scale_rotation
	
	return Transform2D(rot, Vector2(x_pos, y_pos))
