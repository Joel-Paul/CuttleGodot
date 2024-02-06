@tool
class_name Hand
extends CardArea


signal dragged(card: Card)
signal released(card: Card)

var _dragging_card: Card
 

func clicked_card(card: Card) -> void:
	_dragging_card = card
	is_dragging = true
	card.z_index += 200


func released_card() -> void:
	released.emit(_dragging_card)
	_dragging_card = null
	is_dragging = false
	_focused_card_index = -1
	update_hand()


#region Overrides
func _ready() -> void:
	added_card_z_index = 0
	super._ready()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and _dragging_card != null:
		_dragging_card.global_position += event.relative
		dragged.emit(_dragging_card)


func add_card(card: Card, pos: Vector2) -> void:
	card.clicked.connect(clicked_card)
	card.released.connect(released_card)
	super.add_card(card, pos)


func remove_card(card: Card) -> void:
	card.clicked.disconnect(clicked_card)
	card.released.disconnect(released_card)
	super.remove_card(card)


func tween_added(card: Card, trans: Transform2D) -> void:
	rotate_card(card, trans.get_rotation())
	move_card(card, trans.get_origin(), 1, Tween.TRANS_QUART)
	scale_card(card, trans.get_scale(), 0.5)


func tween_focused(card: Card, trans: Transform2D) -> void:
	rotate_card(card, trans.get_rotation(), 0.1)
	move_card(card, trans.get_origin(), 0.1, Tween.TRANS_QUART)
	scale_card(card, trans.get_scale(), 0.1)


func tween_unfocused(card: Card, trans: Transform2D) -> void:
	rotate_card(card, trans.get_rotation())
	move_card(card, trans.get_origin(), 1, Tween.TRANS_QUART)
	scale_card(card, trans.get_scale(), 0.5)
#endregion
