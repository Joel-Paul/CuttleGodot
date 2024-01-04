@tool
extends Card

@export var suit: SUIT:
	set(val):
		suit = val
		set_texture()

var rank = RANK.KING

func get_texture() -> Texture2D:
	match suit:
		SUIT.CLUBS:
			return card_texture.clubs_king
		SUIT.DIAMONDS:
			return card_texture.diamonds_king
		SUIT.HEARTS:
			return card_texture.hearts_king
		SUIT.SPADES:
			return card_texture.spades_king
	return super.get_texture()
