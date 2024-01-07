@tool
class_name CardTexture
extends Resource

@export var scale: float = 1

#region Clubs
@export_group("Clubs", "clubs")
@export var clubs_ace: Texture2D
@export var clubs_two: Texture2D
@export var clubs_three: Texture2D
@export var clubs_four: Texture2D
@export var clubs_five: Texture2D
@export var clubs_six: Texture2D
@export var clubs_seven: Texture2D
@export var clubs_eight: Texture2D
@export var clubs_nine: Texture2D
@export var clubs_ten: Texture2D
@export var clubs_jack: Texture2D
@export var clubs_queen: Texture2D
@export var clubs_king: Texture2D
#endregion

#region Diamonds
@export_group("Diamonds", "diamonds")
@export var diamonds_ace: Texture2D
@export var diamonds_two: Texture2D
@export var diamonds_three: Texture2D
@export var diamonds_four: Texture2D
@export var diamonds_five: Texture2D
@export var diamonds_six: Texture2D
@export var diamonds_seven: Texture2D
@export var diamonds_eight: Texture2D
@export var diamonds_nine: Texture2D
@export var diamonds_ten: Texture2D
@export var diamonds_jack: Texture2D
@export var diamonds_queen: Texture2D
@export var diamonds_king: Texture2D
#endregion

#region Hearts
@export_group("Hearts", "hearts")
@export var hearts_ace: Texture2D
@export var hearts_two: Texture2D
@export var hearts_three: Texture2D
@export var hearts_four: Texture2D
@export var hearts_five: Texture2D
@export var hearts_six: Texture2D
@export var hearts_seven: Texture2D
@export var hearts_eight: Texture2D
@export var hearts_nine: Texture2D
@export var hearts_ten: Texture2D
@export var hearts_jack: Texture2D
@export var hearts_queen: Texture2D
@export var hearts_king: Texture2D
#endregion

#region Spades
@export_group("Spades", "spades")
@export var spades_ace: Texture2D
@export var spades_two: Texture2D
@export var spades_three: Texture2D
@export var spades_four: Texture2D
@export var spades_five: Texture2D
@export var spades_six: Texture2D
@export var spades_seven: Texture2D
@export var spades_eight: Texture2D
@export var spades_nine: Texture2D
@export var spades_ten: Texture2D
@export var spades_jack: Texture2D
@export var spades_queen: Texture2D
@export var spades_king: Texture2D
#endregion

@export var joker: Texture2D
@export var back: Texture2D

func get_size() -> Vector2:
	return back.get_size() * scale

func get_height() -> float:
	return back.get_height() * scale

func get_width() -> float:
	return back.get_width() * scale

## Returns all the textures for the Clubs suit from lowest (Ace) to highest (King)
func get_clubs() -> Array[Texture2D]:
	return [clubs_ace, clubs_two, clubs_three, clubs_four, clubs_five, clubs_six, clubs_seven, clubs_eight, clubs_nine, clubs_ten, clubs_jack, clubs_queen, clubs_king]

## Returns all the textures for the Diamonds suit from lowest (Ace) to highest (King)
func get_diamonds() -> Array[Texture2D]:
	return [diamonds_ace, diamonds_two, diamonds_three, diamonds_four, diamonds_five, diamonds_six,diamonds_seven, diamonds_eight, diamonds_nine, diamonds_ten, diamonds_jack, diamonds_queen, diamonds_king]

## Returns all the textures for the Hearts suit from lowest (Ace) to highest (King)
func get_hearts() -> Array[Texture2D]:
	return [hearts_ace, hearts_two, hearts_three, hearts_four, hearts_five, hearts_six, hearts_seven, hearts_eight, hearts_nine, hearts_ten, hearts_jack, hearts_queen, hearts_king]

## Returns all the textures for the Spades suit from lowest (Ace) to highest (King)
func get_spades() -> Array[Texture2D]:
	return [spades_ace, spades_two, spades_three, spades_four, spades_five, spades_six, spades_seven, spades_eight, spades_nine, spades_ten, spades_jack, spades_queen, spades_king]

## Returns all the textures for all 4 suits in order of Clubs, Diamonds, Hearts, and Spades.
## Each suit is ordered from lowest (Ace) to highest (King)
## e.g. Ace of Clubs is at index 0 and King of Spades is at index 51
func get_all() -> Array[Texture2D]:
	return get_clubs() + get_diamonds() + get_hearts() + get_spades()
