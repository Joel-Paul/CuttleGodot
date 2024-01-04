@tool
extends Card

@export var suit: SUIT:
	set(val):
		suit = val
		set_texture()

var rank = RANK.TEN

func get_texture() -> Texture2D:
	match suit:
		SUIT.CLUBS:
			return card_texture.clubs_ten
		SUIT.DIAMONDS:
			return card_texture.diamonds_ten
		SUIT.HEARTS:
			return card_texture.hearts_ten
		SUIT.SPADES:
			return card_texture.spades_ten
	return super.get_texture()
