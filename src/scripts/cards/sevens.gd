@tool
extends Card

@export var suit: SUIT:
	set(val):
		suit = val
		set_texture()

var rank = RANK.SEVEN

func get_texture() -> Texture2D:
	match suit:
		SUIT.CLUBS:
			return card_texture.clubs_seven
		SUIT.DIAMONDS:
			return card_texture.diamonds_seven
		SUIT.HEARTS:
			return card_texture.hearts_seven
		SUIT.SPADES:
			return card_texture.spades_seven
	return super.get_texture()
