@tool
class_name PlayArea
extends CardArea


@export_group("Padding", "padding")
@export_range(0, 200, 0.01, "suffix:px") var padding_play_area_top: float = 0:
	set(val):
		padding_play_area_top = val
		queue_redraw()
@export_range(0, 200, 0.01, "suffix:px") var padding_play_area_bottom: float = 0:
	set(val):
		padding_play_area_bottom = val
		queue_redraw()
@export_range(0, 200, 0.01, "suffix:px") var padding_play_area_side: float = 0:
	set(val):
		padding_play_area_side = val
		queue_redraw()


var _play_rect: Rect2
var _new_card: Card


func _ready() -> void:
	super._ready()
	_play_rect = create_play_rect()


func _draw() -> void:
	super._draw()
	if Engine.is_editor_hint():
		_draw_play_area()


func _draw_play_area() -> void:
	_play_rect = create_play_rect()
	draw_rect(_play_rect, Color.SKY_BLUE, false)


func focus_card(card: Card) -> void:
	if _new_card == card: return
	super.focus_card(card)


func create_play_rect() -> Rect2:
	var offset = get_card_size() / 2
	var pos_start = get_card_transform(0, card_spread_limit).get_origin() - offset + Vector2(-padding_play_area_side, -padding_play_area_top)
	var pos_end = get_card_transform(card_spread_limit - 1, card_spread_limit).get_origin() + offset + Vector2(padding_play_area_side, padding_play_area_bottom)
	return Rect2(pos_start, pos_end - pos_start)


func inside_play_area(pos: Vector2) -> bool:
	return _play_rect.has_point(pos)


func add_card(card: Card, pos: Vector2) -> void:
	_new_card = card
	super.add_card(card, pos)
