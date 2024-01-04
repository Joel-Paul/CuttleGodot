@tool
extends Card

@export var suit: SUIT:
	set(val):
		suit = val
		set_texture()

var rank = RANK.THREE

func get_texture() -> Texture2D:
	match suit:
		SUIT.CLUBS:
			return card_texture.clubs_three
		SUIT.DIAMONDS:
			return card_texture.diamonds_three
		SUIT.HEARTS:
			return card_texture.hearts_three
		SUIT.SPADES:
			return card_texture.spades_three
	return super.get_texture()
