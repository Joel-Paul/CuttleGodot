@tool
extends Card

@export var suit: SUIT:
	set(val):
		suit = val
		set_texture()

var rank = RANK.NINE

func get_texture() -> Texture2D:
	match suit:
		SUIT.CLUBS:
			return card_texture.clubs_nine
		SUIT.DIAMONDS:
			return card_texture.diamonds_nine
		SUIT.HEARTS:
			return card_texture.hearts_nine
		SUIT.SPADES:
			return card_texture.spades_nine
	return super.get_texture()
