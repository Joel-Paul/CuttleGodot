@tool
extends Card

@export var suit: SUIT:
	set(val):
		suit = val
		set_texture()

var rank = RANK.EIGHT

func get_texture() -> Texture2D:
	match suit:
		SUIT.CLUBS:
			return card_texture.clubs_eight
		SUIT.DIAMONDS:
			return card_texture.diamonds_eight
		SUIT.HEARTS:
			return card_texture.hearts_eight
		SUIT.SPADES:
			return card_texture.spades_eight
	return super.get_texture()
