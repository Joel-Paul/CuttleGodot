extends Node2D

@onready var hand: Hand = $Hand
@onready var deck: Deck = $Deck

var count = 0

func _ready() -> void:
	deck.reset_deck()


func _process(delta: float) -> void:
	if not deck.is_empty() and count % 10 == 0:
		var card = deck.draw_card()
		hand.add_card(card)
	count += 1
