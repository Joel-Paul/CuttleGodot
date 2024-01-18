extends Node2D

@onready var hand: Hand = $Hand
@onready var deck: Deck = $Deck

var count = -200

func _ready() -> void:
	deck.reset_deck()


func _process(_delta: float) -> void:
	if not deck.is_empty() and count > 0 and count % 50 == 0:
		var card = deck.draw_card()
		card.flipped.connect(send_to_hand)
	count += 1


func send_to_hand(card: Card):
	var pos: Vector2 = card.global_position
	deck.remove_child(card)
	card.z_index += 1
	hand.add_card(card, pos)
