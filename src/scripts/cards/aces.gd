@tool
extends Card

@export var suit: SUIT:
	set(val):
		suit = val
		set_texture()

var rank = RANK.ACE

func get_texture() -> Texture2D:
	match suit:
		SUIT.CLUBS:
			return card_texture.clubs_ace
		SUIT.DIAMONDS:
			return card_texture.diamonds_ace
		SUIT.HEARTS:
			return card_texture.hearts_ace
		SUIT.SPADES:
			return card_texture.spades_ace
	return super.get_texture()
