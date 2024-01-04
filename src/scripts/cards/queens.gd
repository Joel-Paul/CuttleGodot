@tool
extends Card

@export var suit: SUIT:
	set(val):
		suit = val
		set_texture()

var rank = RANK.QUEEN

func get_texture() -> Texture2D:
	match suit:
		SUIT.CLUBS:
			return card_texture.clubs_queen
		SUIT.DIAMONDS:
			return card_texture.diamonds_queen
		SUIT.HEARTS:
			return card_texture.hearts_queen
		SUIT.SPADES:
			return card_texture.spades_queen
	return super.get_texture()
