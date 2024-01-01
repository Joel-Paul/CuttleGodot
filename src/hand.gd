@tool
extends Node2D

@export var curvature: float = 4:
	set(val):
		curvature = val
		queue_redraw()
@export_range(0, 5) var max_spacing: float = 1:
	set(val):
		max_spacing = val
		queue_redraw()
@export_range(0, 0.1) var spacing_scale: float = 0.06:
	set(val):
		spacing_scale = val
		queue_redraw()
@export_range(0, 10) var rotation_scale: float = .4:
	set(val):
		rotation_scale = val
		queue_redraw()

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
@export_range(0, 20) var preview_num_cards: int = 6:
	set(val):
		preview_num_cards = val
		queue_redraw()

func _draw() -> void:
	if Engine.is_editor_hint():
		_draw_preview()

func _draw_preview() -> void:
	var offset = GameManager.CARD_SIZE / -2.0  # make centre of card the origin
	var points = PackedVector2Array()
	
	for i in preview_num_cards:
		var trans = get_card_transform(i, preview_num_cards)
		draw_set_transform_matrix(trans)

		var rect = Rect2(offset, GameManager.CARD_SIZE)
		if preview_show_cards:
			draw_texture_rect(preview_card_texture, rect, false)
		
		points.push_back(trans.get_origin())
	
	draw_set_transform(Vector2.ZERO)
	if preview_show_curve and points.size() > 1:
		draw_polyline(points, Color.RED, 2)

func get_card_transform(index: int, length: int) -> Transform2D:
	# The reciprocal of the exponent is used to decrease the spacing between cards as the
	# number of cards increase, preventing them from going off screen with a large amount
	var spacing = max_spacing * exp(-length * spacing_scale)
	# I don't remember how I derived the below equation
	var x_pos = (index - (length - 1) / 2.0) * GameManager.CARD_SIZE.x * spacing
	var y_pos = pow(x_pos, 2) * curvature / get_viewport_rect().size.x
	var pos = Vector2(x_pos, y_pos)
	
	# Derivative of y_pos (w.r.t. x_pos) * rotation_scale
	var rot = atan(2 * x_pos * curvature / get_viewport_rect().size.x) * rotation_scale
	
	return Transform2D(rot, pos)
