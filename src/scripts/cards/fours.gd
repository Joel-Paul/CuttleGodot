@tool
extends Card

@export var suit: SUIT:
	set(val):
		suit = val
		set_texture()

var rank = RANK.FOUR

func get_texture() -> Texture2D:
	match suit:
		SUIT.CLUBS:
			return card_texture.clubs_four
		SUIT.DIAMONDS:
			return card_texture.diamonds_four
		SUIT.HEARTS:
			return card_texture.hearts_four
		SUIT.SPADES:
			return card_texture.spades_four
	return super.get_texture()
