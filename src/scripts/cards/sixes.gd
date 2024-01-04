@tool
extends Card

@export var suit: SUIT:
	set(val):
		suit = val
		set_texture()

var rank = RANK.SIX

func get_texture() -> Texture2D:
	match suit:
		SUIT.CLUBS:
			return card_texture.clubs_six
		SUIT.DIAMONDS:
			return card_texture.diamonds_six
		SUIT.HEARTS:
			return card_texture.hearts_six
		SUIT.SPADES:
			return card_texture.spades_six
	return super.get_texture()
