@tool
extends Node2D

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
@export_range(0, PI / 2) var scale_rotation: float = .25:
	set(val):
		scale_rotation = val
		queue_redraw()
#endregion

#region Hand curves
@export_group("Curves", "curve")
@export var curve_spacing_x: Curve = preload("res://src/curves/hand_spacing_x.tres"):
	set(val):
		curve_spacing_x = val
		queue_redraw()
@export var curve_spacing_y: Curve = preload("res://src/curves/hand_spacing_y.tres"):
	set(val):
		curve_spacing_y = val
		queue_redraw()
@export var curve_rotation: Curve = preload("res://src/curves/hand_rotation.tres"):
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
@export var preview_card_texture: Texture2D = preload("res://addons/Pixel Playing Cards Pack/back_red_basic_white.png"):
	set(val):
		preview_card_texture = val
		queue_redraw()
@export_range(0, 20) var preview_num_cards: int = 8:
	set(val):
		preview_num_cards = val
		queue_redraw()
#endregion

func _draw() -> void:
	if Engine.is_editor_hint():
		_draw_preview()

func _draw_preview() -> void:
	if preview_show_cards:
		var offset = Global.CARD_SIZE / -2.0  # make centre of card the origin
		for i in preview_num_cards:
			var trans = get_card_transform(i, preview_num_cards)
			draw_set_transform_matrix(trans)

			var rect = Rect2(offset, Global.CARD_SIZE)
			draw_texture_rect(preview_card_texture, rect, false)
		draw_set_transform(Vector2.ZERO)
	
	if preview_show_curve:
		var points = PackedVector2Array()
		for i in max_card_expansion:
			var trans = get_card_transform(i, max_card_expansion)
			points.push_back(trans.get_origin())
		draw_polyline(points, Color.RED, 2)

func get_card_transform(index: int, length: int) -> Transform2D:
	# Effective length/index serves to "pad out" the hand
	# when the number of cards is below `max_card_expansion`.
	# Without this, the spacing between low amounts of cards is large.
	var length_offset = 0 if length % 2 == max_card_expansion % 2 else 1
	var effective_length = max(length, max_card_expansion - length_offset)
	var effective_index = index + round((effective_length - length) / 2.0)
	var norm_pos = effective_index / (effective_length - 1.0)
	
	var x_pos = curve_spacing_x.sample(norm_pos) * scale_spacing_x * Global.CARD_SIZE.x
	var y_pos = -curve_spacing_y.sample(norm_pos) * scale_spacing_y * Global.CARD_SIZE.y
	var rot = curve_rotation.sample(norm_pos) * scale_rotation
	
	return Transform2D(rot, Vector2(x_pos, y_pos))
