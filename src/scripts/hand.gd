@tool
class_name Hand
extends CardArea


signal released(card: Card)

var _dragging_card: Card


func clicked_card(card: Card) -> void:
	_dragging_card = card
	card.z_index *= 100


func released_card() -> void:
	released.emit(_dragging_card)
	_dragging_card = null
	_focused_card_index = -1
	update_hand()



#region Overrides
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and _dragging_card != null:
		_dragging_card.global_position += event.relative


func add_card(card: Card, pos: Vector2) -> void:
	card.clicked.connect(clicked_card)
	card.released.connect(released_card)
	super.add_card(card, pos)


func remove_card(card: Card) -> void:
	card.clicked.disconnect(clicked_card)
	card.released.disconnect(released_card)
	super.remove_card(card)


func focus_card(card: Card) -> void:
	if _dragging_card != null: return
	super.focus_card(card)


func unfocus_card() -> void:
	if _dragging_card != null: return
	super.unfocus_card()
#endregion
