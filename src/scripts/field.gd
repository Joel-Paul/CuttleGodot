extends Node2D

@onready var hand: Hand = %Hand
@onready var deck: Deck = %Deck
@onready var play_area: PlayArea = %PlayArea

var count = -100

func _ready() -> void:
	deck.reset_deck()


func _process(_delta: float) -> void:
	if not deck.is_empty() and count > 0 and count % 45 == 0:
		var card = deck.draw_card()
		card.flipped.connect(send_to_hand)
	count += 1


func send_to_hand(card: Card):
	var pos: Vector2 = card.global_position
	deck.remove_child(card)
	hand.add_card(card, pos)


func _on_hand_released(card: Card) -> void:
	play_area.is_dragging = false
	if play_area.inside_play_area(play_area.get_local_mouse_position()):
		var pos: Vector2 = card.global_position
		hand.remove_card(card)
		
		add_child(card)
		card.global_position = pos
		var center = get_viewport_rect().size / 2
		await create_tween().tween_property(card, "position", center, 1).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT).finished
		
		pos = card.global_position
		remove_child(card)
		play_area.add_card(card, pos)


func _on_hand_dragged(_card: Card) -> void:
	play_area.is_dragging = true
