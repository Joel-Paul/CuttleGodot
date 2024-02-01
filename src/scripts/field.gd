extends Node2D

@onready var hand: Hand = %Hand
@onready var deck: Deck = %Deck
@onready var play_area: PlayArea = %PlayArea

var count = 0

func _ready() -> void:
	deck.reset_deck()


func _process(_delta: float) -> void:
	if not deck.is_empty() and count > 0 and count % 1 == 0:
		var card = deck.draw_card()
		card.flipped.connect(send_to_hand)
	count += 1


func send_to_hand(card: Card):
	var pos: Vector2 = card.global_position
	deck.remove_child(card)
	hand.add_card(card, pos)


func _on_hand_released(card: Card) -> void:
	if play_area.inside_play_area(play_area.get_local_mouse_position()):
		var pos: Vector2 = card.global_position
		hand.remove_card(card)
		play_area.add_card(card, pos)
