@tool
extends Card

@export var suit: SUIT:
	set(val):
		suit = val
		set_texture()

var rank = RANK.JACK

func get_texture() -> Texture2D:
	match suit:
		SUIT.CLUBS:
			return card_texture.clubs_jack
		SUIT.DIAMONDS:
			return card_texture.diamonds_jack
		SUIT.HEARTS:
			return card_texture.hearts_jack
		SUIT.SPADES:
			return card_texture.spades_jack
	return super.get_texture()
