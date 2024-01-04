@tool
extends Card

@export var suit: SUIT:
	set(val):
		suit = val
		set_texture()

var rank = RANK.TWO

func get_texture() -> Texture2D:
	match suit:
		SUIT.CLUBS:
			return card_texture.clubs_two
		SUIT.DIAMONDS:
			return card_texture.diamonds_two
		SUIT.HEARTS:
			return card_texture.hearts_two
		SUIT.SPADES:
			return card_texture.spades_two
	return super.get_texture()
