@tool
extends Card

@export var suit: SUIT:
	set(val):
		suit = val
		set_texture()

var rank = RANK.FIVE

func get_texture() -> Texture2D:
	match suit:
		SUIT.CLUBS:
			return card_texture.clubs_five
		SUIT.DIAMONDS:
			return card_texture.diamonds_five
		SUIT.HEARTS:
			return card_texture.hearts_five
		SUIT.SPADES:
			return card_texture.spades_five
	return super.get_texture()
